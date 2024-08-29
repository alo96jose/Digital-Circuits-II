`include "CPU_I2C.v"
`include "TARGET_I2C.v"

// Testbench Code Goes here
module I2C_tb;

// Regs
reg         CLK, RESET_CPU, RESET_TARGET, START_STB, RNW;
reg  [31:0] transaccion;
reg [6:0]  I2C_ADDR;
reg  [15:0] I2C_data_read, WR_DATA;

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

  /*+++++++++++++++++++++++++++++++ PRUEBA ESCRITURA +++++++++++++++++++++++++++++++*/
  #20  RESET_CPU = 0;
       RESET_TARGET  = 0;
  #120 RESET_CPU = 1;
  #180 RESET_TARGET  = 1; 
      START_STB = 1;
	  I2C_ADDR = 7'b0111101; // Calling TARGET #61
	  WR_DATA = 16'h07CC;
      transaccion = 32'h5BA73549;
	  RNW = 0;
  #40 START_STB = 0;

  /*+++++++++++++++++++++++++++++++ PRUEBA LECTURA +++++++++++++++++++++++++++++++*/
  /*
  #40   START_STB = 0;
  #7800 transaccion = 32'h65557777;
        I2C_data_read = 16'h2468;
  #160  START_STB = 1;
  #40   START_STB = 0;
  */
  #8000 $finish;
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
		   .I2C_ADDR 	(I2C_ADDR),
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
		  .RD_DATA   	(I2C_data_read[15:0]),
		  .I2C_ADDR  	(I2C_ADDR)
		  );


endmodule
