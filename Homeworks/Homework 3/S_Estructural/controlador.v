// Maquina de estados para el controlador del cajero automatico
// Autor: Alonso José Jiménez Anchía

// **Declaracion del modulo**

// Argumentos del modulo son todos los puertos
// de entrada y de salida
module controlador (
    CLK,
    RESET,
    TARJETA_RECIBIDA,
    TIPO_TRANS,
    DIGITO_STB,
    DIGITO,
    PIN,
    MONTO_STB,
    MONTO,
    BALANCE_ACTUALIZADO,
    ENTREGAR_DINERO,
    PIN_INCORRECTO,
    ADVERTENCIA,
    BLOQUEO,
    FONDOS_INSUFICIENTES
    );

// **Inputs**
input CLK, RESET, TARJETA_RECIBIDA, TIPO_TRANS, DIGITO_STB, MONTO_STB;
input [15:0] PIN;
input [3:0] DIGITO;
input [31:0] MONTO;

// **Outputs**
output reg BALANCE_ACTUALIZADO, ENTREGAR_DINERO, PIN_INCORRECTO;
output reg ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES;

// **Intern variables**
reg [63:0] BALANCE;
reg [1:0] INTENTOS;
reg [5:0] STATE;
reg [4:0] i;                                                            // Counter of 5 bits, 2^5=32
reg [3:0] DIGITO1;
reg [3:0] DIGITO2;
reg [3:0] DIGITO3;
reg [3:0] DIGITO4;
reg [15:0] ALL_DIGITOS;
                                                                        // Intern variables require FFs:
reg [63:0] NXT_BALANCE;
reg [1:0] NXT_INTENTOS;
reg [5:0] NXT_STATE;
reg [4:0] NXT_i;
                                                                        // Outputs require FFs:
reg NXT_BALANCE_ACTUALIZADO;
reg NXT_ENTREGAR_DINERO;
reg NXT_PIN_INCORRECTO;
reg NXT_ADVERTENCIA;
reg NXT_BLOQUEO;
reg NXT_FONDOS_INSUFICIENTES;

reg [3:0] NXT_DIGITO1;
reg [3:0] NXT_DIGITO2;
reg [3:0] NXT_DIGITO3;
reg [3:0] NXT_DIGITO4;
reg [15:0] NXT_ALL_DIGITOS;

reg FLAG;
reg NXT_FLAG;

//Ambas variables almacenadas en registros hechos con FF de flanco positivo.
// Un FF por bit de cada variable.
always @(posedge CLK) begin
  if (RESET==0) begin
      BALANCE <= 64'h55730;                                                // 350 000 colones
      INTENTOS <= 0;
      STATE <= 0;
      i <= 0;

      BLOQUEO <= 0;
      BALANCE_ACTUALIZADO <= 0;
      ENTREGAR_DINERO <= 0;
      PIN_INCORRECTO <= 0;
      ADVERTENCIA <= 0;
      BLOQUEO <= 0;
      FONDOS_INSUFICIENTES <= 0;

      DIGITO1 <= 0;
      DIGITO2 <= 0;
      DIGITO3 <= 0;
      DIGITO4 <= 0;
      ALL_DIGITOS <= 0;

      FLAG <= 0;

  end 
  else begin
      BALANCE <= NXT_BALANCE; 
      INTENTOS <= NXT_INTENTOS;
      STATE <= NXT_STATE;
      i <= NXT_i;
                             
      BLOQUEO <= NXT_BLOQUEO;
      BALANCE_ACTUALIZADO <= NXT_BALANCE_ACTUALIZADO;
      ENTREGAR_DINERO <= NXT_ENTREGAR_DINERO;
      PIN_INCORRECTO <= NXT_PIN_INCORRECTO;
      ADVERTENCIA <= NXT_ADVERTENCIA;
      FONDOS_INSUFICIENTES <= NXT_FONDOS_INSUFICIENTES;

      DIGITO1 <= NXT_DIGITO1;
      DIGITO2 <= NXT_DIGITO2;
      DIGITO3 <= NXT_DIGITO3;
      DIGITO4 <= NXT_DIGITO4;
      ALL_DIGITOS <= NXT_ALL_DIGITOS;

      FLAG <= NXT_FLAG;

   end
end  //Fin de los FFs

// **Logica combinacional**

always @(*) begin

// Valores por defecto

  NXT_STATE = STATE;                                                    // Para completar el comportamiento del FF se necesita
                                                                        // que por defecto el nxt_state sostenga el valor del 
                                                                        // estado anterior
  NXT_i = i;                                                            // Igual al caso de state y nxt_state, para garantizar el 
                                                                        // comportamiento del FF. 
  NXT_BALANCE = BALANCE;
  NXT_INTENTOS = INTENTOS;

  NXT_BLOQUEO = BLOQUEO;
  NXT_BALANCE_ACTUALIZADO = BALANCE_ACTUALIZADO;
  NXT_ENTREGAR_DINERO = ENTREGAR_DINERO;
  NXT_PIN_INCORRECTO = PIN_INCORRECTO; 
  NXT_ADVERTENCIA = ADVERTENCIA;
  NXT_FONDOS_INSUFICIENTES = FONDOS_INSUFICIENTES;

  NXT_DIGITO1 = DIGITO1;
  NXT_DIGITO2 = DIGITO2;
  NXT_DIGITO3 = DIGITO3;
  NXT_DIGITO4 = DIGITO4;
  NXT_ALL_DIGITOS = ALL_DIGITOS;

  NXT_FLAG = FLAG;

// Comportamiento de la maquina de estados
// Define las transiciones de proximo estado segun el diagrama ASM
// visto en clase y el comportamiento de "valid" y "count0" en el 
// ultimo estado, segun la especificacion.

  case(STATE)
    6'b000000: begin
                                                                          // Estado a, #0
                  NXT_BALANCE_ACTUALIZADO = 0;

                  if (TARJETA_RECIBIDA) begin
                     NXT_STATE = 6'b000001;
                       
                  end       
    end

    6'b000001: begin                                                      // Estado b, #1
                  if (DIGITO_STB) begin
                        if (i==0) begin
                           NXT_DIGITO1 = DIGITO;
                           NXT_i = i + 1;
                        end
                        else if (i==1) begin
                           NXT_DIGITO2 = DIGITO;
                           NXT_i = i + 1;
                        end
                        else if (i==2) begin
                           NXT_DIGITO3 = DIGITO;
                           NXT_i = i + 1;
                        end
                        else if (i==3) begin
                           NXT_DIGITO4 = DIGITO;
                           NXT_i = i + 1;
                        end
                  end
                  else if (i==4) begin
                        NXT_ALL_DIGITOS = {DIGITO1, DIGITO2, DIGITO3, DIGITO4};
                        NXT_FLAG = 1;
                        if (ALL_DIGITOS == PIN && FLAG==1) begin
                           NXT_STATE = 6'b000010; 
                           NXT_i = 0;
                           NXT_INTENTOS = 0;
                           NXT_FLAG = 0;
                           NXT_DIGITO1 = 0;
                           NXT_DIGITO2 = 0;
                           NXT_DIGITO3 = 0;
                           NXT_DIGITO4 = 0;
                           NXT_ALL_DIGITOS = 0;
                        end
                        else if (ALL_DIGITOS != PIN && FLAG==1) begin
                           NXT_PIN_INCORRECTO = 1'b1;
                           NXT_INTENTOS = INTENTOS + 1;
                           NXT_i = 0;
                           NXT_FLAG = 0;
                           NXT_DIGITO1 = 0;
                           NXT_DIGITO2 = 0;
                           NXT_DIGITO3 = 0;
                           NXT_DIGITO4 = 0;
                           NXT_ALL_DIGITOS = 0;
                        end
                  end
                  else if (INTENTOS==2) begin
                     NXT_ADVERTENCIA = 1;
                     //NXT_i = 0;
                  end
                  else if (INTENTOS>=3) begin
                     NXT_BLOQUEO = 1;
                     NXT_STATE = 6'b000011;
                     NXT_DIGITO1 = 0;
                     NXT_DIGITO2 = 0;
                     NXT_DIGITO3 = 0;
                     NXT_DIGITO4 = 0;
                     NXT_ALL_DIGITOS = 0;
                  end

   end

    6'b000010: begin                                                       // Estado c, #2
                  if (TIPO_TRANS == 0 && FLAG == 0) begin                  // Deposit
                  //if monto_stb begin
                        NXT_BALANCE = BALANCE + MONTO;
                        NXT_BALANCE_ACTUALIZADO = 1;
                        NXT_FLAG = 1;
                  end
                  else if (TIPO_TRANS == 1) begin                           // Retiro
                     if (MONTO_STB && FLAG == 0) begin
                        if (MONTO < BALANCE) begin
                        NXT_BALANCE = BALANCE - MONTO;
                        NXT_BALANCE_ACTUALIZADO = 1;
                        NXT_ENTREGAR_DINERO = 1;
                        NXT_FLAG = 1;
                        end
                        else begin
                        NXT_FONDOS_INSUFICIENTES = 1;
                        NXT_FLAG = 1;
                        end
                     end
                  end
                  if (FLAG == 1 && MONTO == 0) begin
                     NXT_STATE = 6'b000000;
                     NXT_FLAG=0;
                     NXT_ENTREGAR_DINERO = 0;
                     NXT_BALANCE_ACTUALIZADO = 0;
                     NXT_FONDOS_INSUFICIENTES = 0;
                     NXT_DIGITO1 = 0;
                     NXT_DIGITO2 = 0;
                     NXT_DIGITO3 = 0;
                     NXT_DIGITO4 = 0;
                     NXT_ALL_DIGITOS = 0;
                  end

   end

    6'b000011: begin                                                       // Estado d, #3
                
   end                      
    default:   NXT_STATE = 6'b000000;                               // Si la maquina entrara en un estado 
                                                                    // inesperado, regrese al inicio.
  endcase

end                                                                 // Este end corresponde al always @(*)
                                                                    // de la logica combinacional


endmodule