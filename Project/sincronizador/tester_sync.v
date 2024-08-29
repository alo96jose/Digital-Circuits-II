/*
********************************************************
*** Universidad de Costa Rica.                       ***
*** Circuitos Digitales II - IE0523.                 ***
*** Creadora: Daniela Ulloa Barboza. B77748.         ***
*** Proyecto Final: Bloque de PCS tipo 1000BASE-X.   ***
*** Fecha: 6 de julio de 2024.                       ***
********************************************************

*** TESTER DEL SINCRONIZADOR DEL BLOQUE PCS ***/

// Se define el módulo con sus puertos.
module tester_sync (clk, reset, rx_cg, // Salidas.
    SUDI, sync_status); // Entradas.
    
    // Se declaras las entradas y salidas.
    input wire [10:0] SUDI; // Señal de salida que contiene rx_code_group y rx_even.
    input wire sync_status; // Señal que indica si se está sincronizado.
    output reg clk; // Reloj.
    output reg reset; // Señal de reseteo de la máquina.
    output reg [9:0] rx_cg; // Señal proveniente del transmisor con los code groups. (rx_code_group).
    
    // Sección de pruebas:
    initial begin
        clk = 0;
        reset = 0;
        rx_cg = 10'b0000000000;
      #20 reset = 1;
      
      // ** Pruebas para Sincronización **
      // Caso donde no se recibe la comma inmediatamente:
      #15 rx_cg = 10'b1011111110; // Dato incorrecto inventado. LOSS_OF_SYNC.
      #10 rx_cg = 10'b0011111010; // Comma: K28_5_n.
      // Caso donde se recibe un dato incorrecto luego de una comma y un dato especial sin comma antes:
      #10 rx_cg = 10'b1011101110; // Dato incorrecto inventado. LOSS_OF_SYNC.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE D5_6, pero sin haber recibido comma (error). LOSS_OF_SYNC.
      // Caso donde no se recibe una comma luego del primer IDLE completo:
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa primer IDLE).
      #10 rx_cg = 10'b0100011011; // Dato incorrecto inválido: D29_0_p. LOSS_OF_SYNC.
      // Caso cuando después de completar un IDLE se recibe un dato válido pero no comma cuando debería
      // ser una comma y luego se recibe comma y se continúa proceso sin perder avance de sincronización.
      #10 rx_cg = 10'b0011111010; // Comma: K28_5_n.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa primer IDLE).
      #10 rx_cg = 10'b0110110101; // Dato especial de IDLE: D16_2_n (Debería ser una comma). No LOSS_OF_SYNC.
      // Se concluye la sincronización sin errores:
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b0110110101; // Dato especial de IDLE: D16_2_n (Se completa segundo IDLE).
      #10 rx_cg = 10'b0011111010; // Comma: K28_5_n.
      #10 rx_cg = 10'b1001000101; // Dato especial de IDLE: D16_2_p (Se completa tercer IDLE).
      // ** Finalización de pruebas para Sincronización. **

      // ** Análisis de errores estando en sincronía. **
      // Se ingresa un Start: (Permanece en el mismo estado):
      #10 rx_cg = 10'b0010010111; // /S/: K27_7_p.
      // Se ingresa un error y luego un dato válido:
      #10 rx_cg = 10'b1100110011; // D24_3_n (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b1101100100; // Dato válido: D27_0_n.
      // Se agregan tres errores y tres datos válidos:
      #10 rx_cg = 10'b0011010010; // D12_4_p (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b1100110011; // D24_3_n (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b1011111110; // Dato incorrecto inventado.
      #10 rx_cg = 10'b0010011011; // Dato válido: D27_0_p.
      #10 rx_cg = 10'b0011101011; // Dato válido: D28_0_n.
      #10 rx_cg = 10'b0011100100; // Dato válido: D28_0_p. // Vuelve a sincronización normal estado: 001000.
      // Caso de tres errores, luego un dato válido y por último otro error para perder sincronización:
      #10 rx_cg = 10'b1011111110; // Dato incorrecto inventado.
      #10 rx_cg = 10'b0011010010; // D12_4_p (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b1100110011; // D24_3_n (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b0111100100; // Dato válido: D30_0_n.
      #10 rx_cg = 10'b0011010010; // D12_4_p (Dato inválido, no pertenece a los escogidos).
      // Caso en el que cuando hay sincronización se dan 4 errores seguidos, se pierde sincronización.
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa primer IDLE).
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa segundo IDLE).
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa tercer IDLE).
      #10 rx_cg = 10'b0010010111; // /S/: K27_7_p. Se inicia el paquete.
      #10 rx_cg = 10'b0011010010; // D12_4_p (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b0011010010; // D12_4_p (Dato inválido, no pertenece a los escogidos).
      #10 rx_cg = 10'b1011111110; // Dato incorrecto inventado.
      #10 rx_cg = 10'b1100110011; // D24_3_n (Dato inválido, no pertenece a los escogidos).
      // ** Final de análisis de errores estando en sincronía. **
      
      // ** Prueba completa correcta **
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa primer IDLE).
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa segundo IDLE).
      #10 rx_cg = 10'b1100000101; // Comma: K28_5_p.
      #10 rx_cg = 10'b1010010110; // Dato especial de IDLE: D5_6 (Se completa tercer IDLE).
      #10 rx_cg = 10'b0010010111; // /S/: K27_7_p. Se inicia el paquete.
      // Ahora se envían los datos:
      #10 rx_cg = 10'b1000101001; // Dato válido: D1_1_p. 
      #10 rx_cg = 10'b0100101001; // Dato válido: D2_1_p.
      #10 rx_cg = 10'b1101011001; // Dato válido: D4_1_n.
      #10 rx_cg = 10'b0111100100; // Dato válido: D30_0_n.
      #10 rx_cg = 10'b0010011011; // Dato válido: D27_0_p.
      #10 rx_cg = 10'b0100101001; // Dato válido: D2_1_p.
      // Se terminan los datos.
      #10 rx_cg = 10'b1011101000; // /T/: K29_7_n.
      #10 rx_cg = 10'b0001010111; // /R/: K23_7_p.
      #10 rx_cg = 10'b0011111010; // Comma: K28_5_n.
      #10 rx_cg = 10'b1001000101; // Dato especial de IDLE: D16_2_p
      // ** Final de prueba completa correcta **
      
      #50 $finish; // Se termina la simulación.
    end
    
    always begin // Se crea el reloj.
        #5 clk = !clk;
    end
endmodule


