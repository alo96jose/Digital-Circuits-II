module tester (
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

// **Entradas**
input BALANCE_ACTUALIZADO, ENTREGAR_DINERO, PIN_INCORRECTO;
input ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES;

// **Salidas**
output CLK, RESET, TARJETA_RECIBIDA, TIPO_TRANS, DIGITO_STB, MONTO_STB;
output reg [15:0] PIN;
output reg [3:0] DIGITO;
output reg [31:0] MONTO;

// **Registers and wires**
reg CLK, RESET, TARJETA_RECIBIDA, TIPO_TRANS, DIGITO_STB, MONTO_STB;
wire BALANCE_ACTUALIZADO, ENTREGAR_DINERO, PIN_INCORRECTO;
wire ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES;

initial begin
    // Todas las salidas a su estado inicial
    CLK = 0;
    RESET = 1;
    TARJETA_RECIBIDA = 0;
    TIPO_TRANS = 0;
    DIGITO_STB = 0;
    MONTO_STB = 0;
    PIN = 0;
    DIGITO = 0;
    MONTO = 32'h00000000;

    // Boton reset
    #20 RESET = 0;
    #20 RESET = 1;

    // Nota: Las pruebas se pueden comentar e ir probando una por una.

    // Prueba 1: Funcionamiento normal basico (retiro)  

    #10 {TARJETA_RECIBIDA, PIN} = {1'b1, 16'h9547};               // Ingreso de tarjeta y actualizacion del PIN.
    #20 TIPO_TRANS = 1;                                           // Retiro de efectivo
    #10 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // (1) Ingreso de digito y senal estroboscopica.
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        // Digito y senal estroboscopica a 0.
    #10 {DIGITO,DIGITO_STB} = {4'h5,1'b1};                        // (2) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h4,1'b1};                        // (3) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        // (4) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 TARJETA_RECIBIDA = 1'b0;                                  // Señal solo necesaria en estado a.
    #10 {MONTO,MONTO_STB} = {32'h0000C350,1'b1};                  // Monto = 50 000 y STB
    #10 {MONTO_STB, TIPO_TRANS} = {1'b0,1'b0};                    // monto_STB y TIPO_TRANS a valores default
    #40 {MONTO, PIN} = {32'h00000000,16'h0000};                   // MONTO y PIN a valores por default.

    // Prueba 2: Deposito.

    #50 {TARJETA_RECIBIDA, PIN} = {1'b1, 16'h9547};               // Ingreso de tarjeta y actualizacion del PIN.
    #20 TIPO_TRANS = 0;                                           // Retiro de efectivo
    #10 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // (1) Ingreso de digito y senal estroboscopica.
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        // Digito y senal estroboscopica a 0.
    #10 {DIGITO,DIGITO_STB} = {4'h5,1'b1};                        // (2) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h4,1'b1};                        // (3) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        // (4) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 TARJETA_RECIBIDA = 1'b0;                                  // Señal solo necesaria en estado a.
    #10 {MONTO,MONTO_STB} = {32'h0000C350,1'b1};                  // Monto = 50 000 y STB
    #10 {TIPO_TRANS,MONTO_STB} = {1'b0,1'b0};                     // TIPO_TRANS y STB a valores default
    #40 {MONTO, PIN} = {32'h00000000,16'h0000};                   // MONTO y PIN a valores por default.


    // Prueba 3: Fondos insuficientes.

    #50 {TARJETA_RECIBIDA, PIN} = {1'b1, 16'h9547};               // Ingreso de tarjeta y actualizacion del PIN.
    #20 TIPO_TRANS = 1;                                           // Retiro de efectivo
    #10 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // (1) Ingreso de digito y senal estroboscopica.
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        // Digito y senal estroboscopica a 0.
    #10 {DIGITO,DIGITO_STB} = {4'h5,1'b1};                        // (2) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h4,1'b1};                        // (3) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        // (4) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 TARJETA_RECIBIDA = 1'b0;                                  // Señal solo necesaria en estado a.
    #10 {MONTO,MONTO_STB} = {32'h00064190,1'b1};                  // Monto = 410 000 y STB
    #10 {MONTO_STB, TIPO_TRANS} = {1'b0,1'b0};                    // monto_STB y TIPO_TRANS a valores default
    #40 {MONTO, PIN} = {32'h00000000,16'h0000};                   // MONTO y PIN a valores por default.

    // Prueba 4: Ingreso de pin incorrecto varias veces y bloqueo.

    #50 {TARJETA_RECIBIDA, PIN} = {1'b1, 16'h9547};               // Ingreso de tarjeta y actualizacion del PIN.
    #20 TIPO_TRANS = 1;                                           // Retiro de efectivo
    #10 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // (1) Ingreso de digito y senal estroboscopica.
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        // Digito y senal estroboscopica a 0.
    #10 {DIGITO,DIGITO_STB} = {4'h1,1'b1};                        // (2) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h4,1'b1};                        // (3) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        // (4) ""
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 TARJETA_RECIBIDA = 1'b0;                                  // Señal solo necesaria en estado a.

    #10 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // 2 Pin Incorrecto
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 {DIGITO,DIGITO_STB} = {4'h1,1'b1};
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h7,1'b1};                        
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};

    #30 {DIGITO,DIGITO_STB} = {4'h9,1'b1};                        // 3 Pin Incorrecto
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};
    #10 {DIGITO,DIGITO_STB} = {4'h1,1'b1};                     
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h4,1'b1};                   
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};                        
    #10 {DIGITO,DIGITO_STB} = {4'h3,1'b1};
    #10 {DIGITO,DIGITO_STB} = {4'h0,1'b0};

    #50 RESET = 0;
    #20 RESET = 1;

    #50 $finish;
  end

  // Periodo reloj T = 10s
  always begin
    #5 CLK = !CLK;                                            // Cada 5s cambia de estado (alto o bajo) el clock
  end

endmodule
