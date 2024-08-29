`include "CPU_spi.v"
`include "target_spi.v"

// Testbench Code Goes here
module spi_tb;

reg         CLK, RESET, spi_start_stb, CKP, CPH;
reg  [31:0] transaccion;
reg  [15:0] dato_enviado;
wire        SCK, MOSICPU_to_MOSIT1, MISOT1_to_MOSIT2, MISOT2_to_MISOCPU, CS, MISO, SCK_anterior;

initial begin
	$dumpfile("spi.vcd");
	$dumpvars(-1, U0);
	$dumpvars(-1, U1);
	$dumpvars(-1, U2);
end


initial begin
  CLK = 0;
  RESET = 1;

/********************************** Prueba Modo 0 **********************************/
  /*#60 RESET = 0;
  #120 RESET = 1;
	  CKP = 0;
	  CPH = 0; 
      spi_start_stb = 0;
      transaccion = 16'b0000001100000101; // 0305
	  dato_enviado = 16'b0000011000000001; // 0601

  #80 spi_start_stb = 1;
  #45 spi_start_stb = 0;*/
/********************************** Prueba Modo 1 **********************************/
  /*#60 RESET = 0;
  #120 RESET = 1;
	  CKP = 0;
	  CPH = 1; 
      spi_start_stb = 0;
      transaccion = 16'b0000001100000101; // 0305
	  dato_enviado = 16'b0000011000000001; // 0601

  #80 spi_start_stb = 1;
  #45 spi_start_stb = 0;*/
/********************************** Prueba Modo 2 **********************************/
  /*#60 RESET = 0;
  #120 RESET = 1;
	  CKP = 1;
	  CPH = 0; 
      spi_start_stb = 0;
      transaccion = 16'b0000001100000101; // 0305
	  dato_enviado = 16'b0000011000000001; // 0601

  #80 spi_start_stb = 1;
  #45 spi_start_stb = 0;*/

/********************************** Prueba Modo 3 **********************************/

  #60 RESET = 0;
  #120 RESET = 1;
	  CKP = 1;
	  CPH = 1; 
      spi_start_stb = 0;
      transaccion = 16'b0000001100000101; // 0305
	  dato_enviado = 16'b0000011000000001; // 0601

  #80 spi_start_stb = 1;
  #45 spi_start_stb = 0;
  
  #3000 $finish;

end

always begin
 #20 CLK = !CLK;
end


CPU_spi U0 (
/*AUTOINST*/
		   // Outputs
		   .MOSI		 (MOSICPU_to_MOSIT1),
		   .CS			 (CS),
		   .SCK			 (SCK),
		   .SCK_anterior (SCK_anterior),
		   // Inputs
		   .CLK			(CLK),
		   .RESET		(RESET),
		   .START_STB	(spi_start_stb),
		   .MISO		(MISOT2_to_MISOCPU),
		   .transaccion		(transaccion[15:0]),
		   .trans_finalizada (trans_finalizada),
		   .CKP (CKP), 
		   .CPH (CPH)
		   );


target_spi U1 (
/*AUTOINST*/
		  // Outputs
		  .MISO			(MISOT1_to_MOSIT2),
		  .trans_finalizada (trans_finalizada),
		  // Inputs
		  .SCK			(SCK),
		  .SCK_anterior (SCK_anterior),
		  .RESET		(RESET),
		  .MOSI			(MOSICPU_to_MOSIT1),
		  .SS			(CS),
		  .dato_enviado	(dato_enviado[15:0]),
		  .CKP 			(CKP), 
		  .CPH 			(CPH)
		  );

target_spi U2 (
/*AUTOINST*/
		  // Outputs
		  .MISO			(MISOT2_to_MISOCPU),
		  .trans_finalizada (trans_finalizada),
		  // Inputs
		  .SCK			(SCK),
		  .SCK_anterior (SCK_anterior),
		  .RESET		(RESET),
		  .MOSI			(MISOT1_to_MOSIT2),
		  .SS			(CS),
		  .dato_enviado	(dato_enviado[15:0]),
		  .CKP 			(CKP), 
		  .CPH 			(CPH)
		  );

endmodule
