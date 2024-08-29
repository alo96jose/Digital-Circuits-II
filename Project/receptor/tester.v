// Se define el módulo con sus puertos.
module tester (
    CLK, 
    RESET, 
    SYNC_STATUS,
    SUDI,
    RXD,
    RX_DV); 

// Regs
output reg CLK, RESET, SYNC_STATUS;
output reg [10:0] SUDI;

// Wires
input wire [7:0] RXD;
input wire RX_DV; 
    
initial begin
  // Se inicializan las entradas
  CLK = 0;
  RESET = 1;
  SYNC_STATUS = 0;
  SUDI = 11'd0;

  // Se aplica el RESET
  #10 RESET = 0;
  #10 RESET = 1;
  
  //************************
      // ** Prueba completa correcta copiada del tester del sincronizador **
      #10 SUDI = 11'b11000001011; // Comma: K28_5_p.
      #10 SUDI = 11'b10100101100; // Dato especial de IDLE: D5_6 (Se completa primer IDLE).
      #10 SUDI = 11'b11000001011; // Comma: K28_5_p.
      #10 SUDI = 11'b10100101100; // Dato especial de IDLE: D5_6 (Se completa segundo IDLE).
      #10 SUDI = 11'b11000001011; // Comma: K28_5_p.
      #10 SUDI = 11'b10100101100; // Dato especial de IDLE: D5_6 (Se completa tercer IDLE).
          SYNC_STATUS = 1; // SYNC = OK.
      #10 SUDI = 11'b00100101111; // /S/: K27_7_p. Se inicia el paquete.
      // Ahora se envían los datos:
      #10 SUDI = 11'b10001010010; // Dato válido: D1_1_p.  = 21
      #10 SUDI = 11'b01001010011; // Dato válido: D2_1_p.  = 22
      #10 SUDI = 11'b11010110010; // Dato válido: D4_1_n.  = 24
      #10 SUDI = 11'b01111001001; // Dato válido: D30_0_n. = 1E
      #10 SUDI = 11'b00100110110; // Dato válido: D27_0_p. = 1B
      #10 SUDI = 11'b01001010011; // Dato válido: D2_1_p.  = 22
      // Se terminan los datos.
      #10 SUDI = 11'b10111010000; // /T/: K29_7_n.
      #10 SUDI = 11'b00010101111; // /R/: K23_7_p.
      #10 SUDI = 11'b00111110101; // Comma: K28_5_n.
      #10 SUDI = 11'b10010001010; // Dato especial de IDLE: D16_2_p.
      #10 SUDI = 11'b00111110101; // Comma: K28_5_n.
      #10 SUDI = 11'b10010001010; // Dato especial de IDLE: D16_2_p.
      // ** Final de prueba completa correcta **

  // Finaliza la simulacion
  #16000 $finish;
end

always begin
 #5 CLK = !CLK;  
end

endmodule
