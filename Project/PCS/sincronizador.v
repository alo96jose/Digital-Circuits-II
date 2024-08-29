/*
********************************************************
*** Universidad de Costa Rica.                       ***
*** Circuitos Digitales II - IE0523.                 ***
*** Creadora: Daniela Ulloa Barboza. B77748.         ***
*** Proyecto Final: Bloque de PCS tipo 1000BASE-X.   ***
*** Fecha: 6 de julio de 2024.                       ***
********************************************************

*** SINCRONIZADOR DEL BLOQUE PCS ***

Descripción: En este archivo se genera el módulo sincronizador del bloque PCS. En este se reciden los code groups
provenientes del transmisor y son transmitidos hacia el receptor pero con la adición de un bit que determina si
el ciclo del reloj donde fue enviado el dato fue par o impar, y además se encarga de generar una sincronización
entre el transmisor y el receptor para que la comunicación entre ambos sea adecuada. Si no hay sincronía, este
sub-bloque no podrá nunca enviar los datos del GMII de vuelta.*/

// Se define el módulo con sus puertos.
module sincronizador (clk, reset, rx_cg, // Entradas.
    SUDI, sync_status); // Salidas.

// Se declaras las entradas y salidas.
input wire clk; // Reloj.
input wire reset; // Señal de reseteo de la máquina.
input wire [9:0] rx_cg; // Señal proveniente del transmisor con los code groups. (rx_code_group).
output reg [10:0] SUDI; // Señal de salida que contiene rx_code_group y rx_even.
output reg sync_status; // Señal que indica si se está sincronizado.

// Se declaran los estados de la máquina de estados.
localparam LOSS_OF_SYNC               = 6'b000001;
localparam COMMA_DETECT               = 6'b000010;
localparam ACQUIRE_SYNC               = 6'b000100;
localparam SYNC_ACQUIRED              = 6'b001000;
localparam SYNC_ACQUIRED_ERROR        = 6'b010000;
localparam SYNC_ACQUIRED_ERROR_FIXED  = 6'b100000;

// Se declaran las variables internas.
reg [10:0] prox_SUDI; // Valor próximo de SUDI.
reg prox_sync_status; // Valor próximo del estado de sincronización.
reg rx_even, prox_rx_even; // Variable interna que define si el ciclo de reloj es par (Even = 1) o impar (Odd = 0).
reg [5:0] estado, prox_estado; // Indica el estado actual y próximo estado.
reg [2:0] cont_datos, prox_cont_datos; // Contadores de los datos recibidos.
reg [9:0] code_group, prox_code_group; // Variable interna que almacena el dato recibido en rx_code_group (rx_cg).
reg cg_valid; // Señal que indica si el code group recibido es válido luego de entrar en sincronización.
reg [2:0] cont_cgbad, prox_cont_cgbad; // Contador de code groups malos para sección posterior de sincronización.

// Se declaran parámetros locales con los valores válidos de los code groups:
// Nota: n es de disparidad negativa y p es de disparidad positiva.
localparam D27_0_n = 10'b1101100100;
localparam D27_0_p = 10'b0010011011;
localparam D28_0_n = 10'b0011101011;
localparam D28_0_p = 10'b0011100100;
localparam D29_0_n = 10'b1011100100;
localparam D29_0_p = 10'b0100011011;
localparam D30_0_n = 10'b0111100100;
localparam D30_0_p = 10'b1000011011;
localparam D31_0_n = 10'b1010110100;
localparam D31_0_p = 10'b0101001011;
localparam D0_1_n  = 10'b1001111001;
localparam D0_1_p  = 10'b0110001001;
localparam D1_1_n  = 10'b0111011001;
localparam D1_1_p  = 10'b1000101001;
localparam D2_1_n  = 10'b1011011001;
localparam D2_1_p  = 10'b0100101001;
localparam D3_1    = 10'b1100011001; // Ambas disparidades tienen el mismo valor.
localparam D4_1_n  = 10'b1101011001;
localparam D4_1_p  = 10'b0010101001;
// Code groups extra, necesarios para los IDLE:
localparam D5_6    = 10'b1010010110; // Ambas disparidades tienen el mismo valor.
localparam D16_2_n = 10'b0110110101;
localparam D16_2_p = 10'b1001000101;
// Code groups especiales:
localparam K28_5_n = 10'b0011111010; // Comma (-).
localparam K28_5_p = 10'b1100000101; // Comma (+).
localparam K23_7_n = 10'b1110101000; // /R/(-).
localparam K23_7_p = 10'b0001010111; // /R/(+).
localparam K27_7_n = 10'b1101101000; // /S/(-).
localparam K27_7_p = 10'b0010010111; // /S/(+).
localparam K29_7_n = 10'b1011101000; // /T/(-).
localparam K29_7_p = 10'b0100010111; // /T/(+).

// Lógica secuencial
always @(posedge clk) begin
    if (~reset) begin // Se resetean todas las salidas y variables internas, con reset = 0.
        SUDI        <= 11'b00000000000;
        sync_status <= 0;
        rx_even     <= 1;
        estado      <= LOSS_OF_SYNC;
        cont_datos  <= 0;
        code_group  <= 0;
        cont_cgbad  <= 0;
    end else begin
        SUDI        <= prox_SUDI;
        sync_status <= prox_sync_status;
        rx_even     <= prox_rx_even;
        estado      <= prox_estado;
        cont_datos  <= prox_cont_datos;
        code_group  <= prox_code_group;
        cont_cgbad  <= prox_cont_cgbad;
    end
end // Fin de los flip flops.

// Bloque de código que se ejecuta cada vez que alguna señal cambia.
always @(*) begin
    
    // Expresiones necesarias para almacenar los valores.
    prox_SUDI        = SUDI;
    prox_sync_status = sync_status;
    prox_rx_even     = rx_even;
    prox_estado      = estado;
    prox_cont_datos  = cont_datos;
    prox_code_group  = code_group;
    prox_cont_cgbad  = cont_cgbad;
    
    case(estado) // Se utiliza definición de estados "one hot".
    
        LOSS_OF_SYNC: begin
            prox_sync_status = 0; // Sincronización: Fail.
            prox_cont_cgbad = 0; // Se limpia el contador de datos inválidos.
            cg_valid = 0; // Se inicializa el cg_valid.
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            if (rx_cg == K28_5_n || rx_cg == K28_5_p) begin // Si se recibe una comma:
                prox_rx_even = 1; // Se pone en True ya que el siguiente ciclo de reloj debe ser Even por la comma.
            	prox_estado = COMMA_DETECT; // Se accede al estado donde ya se detectó una comma.
            	prox_code_group = rx_cg; // Se guarda el valor de la comma recibida para ser transmitida.
            end else begin // Si no se recibe comma se sigue invirtiendo rx_even y permanece en LOSS_OF_SYNC.
                prox_rx_even = !rx_even; // Se invierte porque no se sabe cuál es.
                prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
            end
        end // Fin del estado #1.
        
        COMMA_DETECT: begin // Estado en el que ya se detectó una comma.
            prox_rx_even = !rx_even; // Se invierte para que el próximo ciclo del reloj sea impar o Odd.
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            // Caso en el que se recibe el dato válido necesario para completar un IDLE.
            if (rx_cg == D5_6 || rx_cg == D16_2_n || rx_cg == D16_2_p) begin
            	if (cont_datos < 2) begin
                    prox_estado = ACQUIRE_SYNC; // Se va al estado donde ya se detectó el dato de I1 o I2.
                    prox_cont_datos = cont_datos + 1; // Con este dato se completa un /I/.
                    prox_code_group = rx_cg; // Se guarda el valor para ser transmitido.
                end else begin // Caso en el que ya se lograron los 3 /I/.
                    prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
                    prox_cont_datos = cont_datos + 1; // Con este dato se completa el último /I/.
                    prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
                    prox_rx_even = !rx_even; // Se invierte para que el próximo ciclo del reloj sea par o Even.
                    prox_estado = SYNC_ACQUIRED; // Se logró la sincronización.
                    prox_sync_status = 1; // Sincronización: OK.
                end
            end else begin
                prox_estado = LOSS_OF_SYNC;
                prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
                prox_cont_datos = 0; // Se reinicia el conteo de datos.
            end
        end // Fin del estado #2.
        
        ACQUIRE_SYNC: begin
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            prox_rx_even = 1; // Se queda en 1 para no perder avance de sincronización al recibir dato válido pero no comma.
            // Se analiza si se recibe una comma:
            if (rx_cg == K28_5_n || rx_cg == K28_5_p) begin
                prox_estado = COMMA_DETECT; // Continúa a detectar la siguiente comma.
                prox_code_group = rx_cg; // Se guarda el valor de la comma recibida para ser transmitida.
            end else begin // Caso en el que no sea una comma:
                if (rx_cg == D5_6 || rx_cg == D16_2_n || rx_cg == D16_2_p) begin // Verificación dato válido.
                    // Si no es un dato inválido se permanece en el estado hasta obtener una comma.
                    prox_estado = ACQUIRE_SYNC;
                    prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
                end else begin
                    // Si no se recibió comma y el dato es inválido, se pierde avance de sincronización.
                    prox_estado = LOSS_OF_SYNC; // Vuelve a comenzar todo el proceso.
                    prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
                    prox_cont_datos = 0; // Se reinicia el conteo de datos.
                end
            end
        end // Fin del estado #3.
        
        SYNC_ACQUIRED: begin
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            prox_cont_datos = 0; // Se reinicia el conteo de datos.
            if (rx_cg == K28_5_n || rx_cg == K28_5_p) begin
                // Caso especial para cuando se recibe la última comma:
                prox_rx_even = 1; // La comma debe ser en ciclo de reloj Even.
            end else prox_rx_even = !rx_even; // Se intercalan los ciclos par e impar del reloj.
            prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
            // Se llama a la función para verificacr si rx_cg es válido y se almacena en cd_valid.
            cg_valid = VALID(rx_cg);
            // Se decide si se permanece en este estado o se detectó un error:
            if (cg_valid == 0) begin // Se detectó un error, se recibió un dato inválido.
                prox_estado = SYNC_ACQUIRED_ERROR;
                prox_cont_cgbad = cont_cgbad + 1; // Primer error detectado.
            end else prox_estado = SYNC_ACQUIRED; // Se permanece en el mismo estado. 
        end // Fin del estado #4 y principal del sincronizador.
        
        SYNC_ACQUIRED_ERROR: begin
            // Este es el estado en el que se reciben errores luego de haber tenido datos válidos.
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            prox_rx_even = !rx_even; // Se intercalan los ciclos par e impar del reloj.
            prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
            // Se llama a la función para verificacr si rx_cg es válido y se almacena en cd_valid.
            cg_valid = VALID(rx_cg);
            if (cg_valid == 0) begin // Se detectó un error, se recibió un dato inválido.
                if (cont_cgbad < 3) begin
                    prox_cont_cgbad = cont_cgbad + 1; // Se detectó otro error.
                    prox_estado = SYNC_ACQUIRED_ERROR; // Se permanece en el mismo estado.
                end else begin // Ya que ingresaron 4 datos inválidos seguidos por lo que se pierde sincronización:
                    prox_estado = LOSS_OF_SYNC; // Se reinicia todo el proceso de sincronización.
                    prox_cont_cgbad = cont_cgbad + 1; // Se detectó el cuarto error.
                end
            end else begin // Si el code group recibido es válido, se accede al siguiente estado.
                prox_estado = SYNC_ACQUIRED_ERROR_FIXED;
                prox_cont_datos = cont_datos + 1; // Se utiliza este mismo contador para contar datos válidos.
            end
            
        end // Fin del estado #5.
        
        SYNC_ACQUIRED_ERROR_FIXED: begin
            // Este es el estado donde se deben recibir 3 datos válidos para volver al estado normal de sincronización,
            // si se recibe un error estando en este estado se devuelve al SYNC_ACQUIRED_ERROR, pero si se ingresar 3
            // errores seguidos se pierde la sincronización.
            prox_SUDI = (((11'b00000000000) | code_group) << 1) | rx_even; // Salida de datos.
            prox_rx_even = !rx_even; // Se intercalan los ciclos par e impar del reloj.
            prox_code_group = rx_cg; // Se guarda el valor a ser transmitido para que no se pierda.
            // Se llama a la función para verificacr si rx_cg es válido y se almacena en cd_valid.
            cg_valid = VALID(rx_cg);
            if (cg_valid == 0) begin // Se detectó un error, se recibió un dato inválido.
                if (cont_cgbad == 3) begin // Se ingresa un cuarto valor inválido luego de haber almacenado 3 malos seguidos.
                    prox_estado = LOSS_OF_SYNC; // Se pierde la sincronización.
                    prox_cont_cgbad = cont_cgbad + 1; // Se detectó el cuarto error.
                    prox_cont_datos = 0; // Se pierden los datos válidos.
                end else begin // Menos de 3 errores seguidos:
                    prox_estado = SYNC_ACQUIRED_ERROR; // Estado de errores.
                    // Como todavía no hay 3 errores seguidos, se reinicia la oportunidad, solo se registra este error.
                    prox_cont_cgbad = 1;
                    prox_cont_datos = 0; // Se pierde el avance de obtener 3 datos válidos para volver a SYNC_ACQUIRED.
                end
            end else begin // Caso en el que el dato es válido:
                if (cont_datos < 2) begin // Todavía no se logran los 3 datos válidos.
                    prox_estado = SYNC_ACQUIRED_ERROR_FIXED; // Se permanece en el mismo estado.
                    prox_cont_datos = cont_datos + 1; // Se aumentan los datos válidos recibidos.
                end else begin // Se vuelve a la sincronización normal, se recibieron los 3 datos válidos.
                    prox_estado = SYNC_ACQUIRED; // Sincronización normal.
                    prox_cont_datos = cont_datos + 1; // Se aumentan los datos válidos recibidos (3).
                    prox_cont_cgbad = 0; // Ya no hay errores.
                end
            end
            
        end // Fin del estado #6.
        
        default: prox_estado = LOSS_OF_SYNC; // Si no cae en ningún estado, reempezar.
    
    endcase
end // Fin del always.

// Bloque de función:
function VALID(input [9:0] cg); // El parámetro de la función es el code group recibido.
    // Cuerpo de la función:
    begin
      // Instrucciones de la función, se verifica si el rx_cg es válido:
      case (cg)
          // Datos /D/ escogidos (10 con su respectiva disparidad):
          D27_0_n: VALID = 1;
          D27_0_p: VALID = 1;
          D28_0_n: VALID = 1;
          D28_0_p: VALID = 1;
          D29_0_n: VALID = 1;
          D29_0_p: VALID = 1;
          D30_0_n: VALID = 1;
          D30_0_p: VALID = 1;
          D31_0_n: VALID = 1;
          D31_0_p: VALID = 1;
          D0_1_n:  VALID = 1;
          D0_1_p:  VALID = 1;
          D1_1_n:  VALID = 1;
          D1_1_p:  VALID = 1;
          D2_1_n:  VALID = 1;
          D2_1_p:  VALID = 1;
          D3_1:    VALID = 1;
          D4_1_n:  VALID = 1;
          D4_1_p:  VALID = 1;
          // Datos /D/ para IDLE: 
          D5_6:    VALID = 1;
          D16_2_n: VALID = 1;
          D16_2_p: VALID = 1;
          // Code groups especiales:
          K28_5_n: VALID = 1;
	  K28_5_p: VALID = 1;
	  K23_7_n: VALID = 1;
	  K23_7_p: VALID = 1;
	  K27_7_n: VALID = 1;
	  K27_7_p: VALID = 1;
	  K29_7_n: VALID = 1;
	  K29_7_p: VALID = 1;
          // Finalización de code groups válidos.
          default: VALID = 0; // Si no es ninguno, es inválido el dato.
      endcase
    end
endfunction

endmodule 
// Fin del módulo.
