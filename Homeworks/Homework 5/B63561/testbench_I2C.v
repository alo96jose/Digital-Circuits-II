`include "CPU_I2C.v"
`include "TARGET_I2C.v"

// Testbench Code Goes here
module I2C_tb;

// Regs
reg         CLK, RESET_CPU, RESET_TARGET, START_STB, RNW;
reg  [31:0] transaccion;
reg [6:0]  I2C_ADDR_TARGET;
reg [6:0]  I2C_ADDR_CPU;
reg  [15:0] I2C_data_read, WR_DATA, RD_DATA;

// Wires
wire [15:0] I2C_data_write;
wire [15:0] reg_addr;
wire        SCL, SDA_IN, SDA_OUT, SDA_OE; 

initial begin
	$dumpfile("I2C.vcd");
	$dumpvars(-1, U0);
	$dumpvars(-1, U1);
end


initial begin
  CLK = 0;
  RESET_CPU = 1;
  RESET_TARGET  = 1;
  START_STB = 0;

  /*+++++++++++++++++++++++++++++++ PRUEBA #1 ESCRITURA +++++++++++++++++++++++++++++++*/
  
  #20  RESET_CPU = 0;
       RESET_TARGET  = 0;
  #120 RESET_CPU = 1;
  #180 RESET_TARGET  = 1; 
      START_STB = 1;
	  I2C_ADDR_CPU = 7'b0111101; // Calling TARGET #61
	  I2C_ADDR_TARGET = 7'b0111101;
	  WR_DATA = 16'h07CC;
      transaccion = 32'h5BA73549;
	  RNW = 0;
  #40 START_STB = 0;

  

	/*++++++++++++++++++++++++ PRUEBA #2 ESCRITURA Y RECEPTOR IGNORA ++++++++++++++++++*/

  #5500

  #80  RESET_CPU = 0;
       RESET_TARGET  = 0;
  #120 RESET_CPU = 1;
  #180 RESET_TARGET  = 1; 
      START_STB = 1;
	  I2C_ADDR_CPU = 7'b0000001; // Calling TARGET #01
	  I2C_ADDR_TARGET = 7'b0111101;
	  WR_DATA = 16'h07CC;
      transaccion = 32'h5BA73549;
	  RNW = 0;
  #40 START_STB = 0;
  
  #3000

  /*+++++++++++++++++++++++++++++++ PRUEBA #3 LECTURA +++++++++++++++++++++++++++++++*/
  
  #20  RESET_CPU = 0;
       RESET_TARGET  = 0;
  #120 RESET_CPU = 1;
  #180 RESET_TARGET  = 1; 
      START_STB = 1;
	  I2C_ADDR_CPU = 7'b0111101; // Calling TARGET #61
	  I2C_ADDR_TARGET = 7'b0111101;
	  RD_DATA = 16'h07E8;
      transaccion = 32'h5BA73549;
	  RNW = 1;
  #40 START_STB = 0;

  #5000

    /*+++++++++++++++++++ PRUEBA #4 LECTURA Y RECEPTOR IGNORA ++++++++++++++++++++++++*/
  
  #20  RESET_CPU = 0;
       RESET_TARGET  = 0;
  #120 RESET_CPU = 1;
  #180 RESET_TARGET  = 1; 
      START_STB = 1;
	  I2C_ADDR_CPU = 7'b0000001; // Calling TARGET #61
	  I2C_ADDR_TARGET = 7'b0111101;
	  RD_DATA = 16'h07E8;
      transaccion = 32'h5BA73549;
	  RNW = 1;
  #40 START_STB = 0;


  #16000 $finish;
end

always begin
 #20 CLK = !CLK;
end


CPU_I2C U0 (
/*AUTOINST*/
		   // Outputs
		   .SDA_OUT		(SDA_OUT),
		   .SDA_OE		(SDA_OE),
		   .SCL			(SCL),
		   // Inputs
		   .CLK			(CLK),
		   .RESET		(RESET_CPU),
		   .START_STB		(START_STB),
		   .SDA_IN		(SDA_IN),
		   .transaccion	(transaccion[31:0]),
		   .RNW         (RNW), 
		   .I2C_ADDR 	(I2C_ADDR_CPU),
		   .WR_DATA 	(WR_DATA)
		   );


TARGET_I2C U1 (
/*AUTOINST*/
		  // Outputs
		  .reg_addr		(reg_addr[4:0]),
		  .SDA_IN		(SDA_IN),
		  // Inputs
		  .SCL			(SCL),
		  .CLK			(CLK),
		  .RESET		(RESET_TARGET),
		  .SDA_OUT		(SDA_OUT),
		  .SDA_OE		(SDA_OE),
		  .RD_DATA   	(RD_DATA),
		  .I2C_ADDR  	(I2C_ADDR_TARGET)
		  );


endmodule
