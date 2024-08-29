`include "CPU_spi.v"
`include "target_spi.v"
  

// Testbench Code Goes here
module spi_tb;

reg        CLK, RESET, START_STB;
reg  [15:0] transaccion;
//reg  [7:0] spi_data_read;
//wire [7:0] spi_data_write;
wire        SCK, MOSI, MISO, CS;

initial begin
	$dumpfile("spi.vcd");
	$dumpvars(-1, CPU);
	$dumpvars(-1, T1);
	//$dumpvars(-1, T2);
end


initial begin
  CLK = 0;
  RESET = 0;

  #20 RESET = 1;
  #180 RESET = 0;
  	  transaccion = 16'b0000001100000101;
      //START_STB = 0;
      //transaccion = 16'b0000001100000101;
  #80 START_STB = 0;
  #80 START_STB = 1;
  #40 START_STB = 0;
  //#7800 transaccion = 8'b00000101;
        //mdio_data_read = 16'h2468;
  //#160  START_STB = 1;
  //#40   START_STB = 0;
  #8000 $finish;
end

always begin
 #20 CLK = !CLK;
end


CPU_spi CPU (/*AUTOINST*/

		   // Outputs
           .MOSI (MOSI), 
		   .CS (CS),
           .SCK (SCK),
		   // Inputs
		   .CLK	(CLK),
		   .RESET (RESET),
		   .CKP (CKP),
		   .CPH (CPH),
		   .MISO (MISO),
		   .START_STB (START_STB),
		   .transaccion (transaccion[15:0]));

target_spi T1 (/*AUTOINST*/ 

		  // Outputs
		  .MISO		(MISO),
		  // Inputs
		  .MOSI			(MOSI),
		  .SCK			(SCK),
		  .SS			(CS),
		  .CKP			(CKP),
		  .CPH			(CPH),
		  .RESET 		(RESET) 
		  );


endmodule
