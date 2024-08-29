`include "tester.v"
`include "receptor.v"
//`include "transmisor.v"
//`include "sintonizador.v"

module PCS_tb;

wire CLK, RESET, SYNC_STATUS;
wire [10:0] SUDI;
wire [7:0] RXD;
wire RX_DV; 


initial begin
	$dumpfile("PCS.vcd");
	$dumpvars(-1, R0);
end


receptor R0 (
/*AUTOINST*/
		   // Outputs
		   .RXD			(RXD),
		   .RX_DV		(RX_DV),
		   // Inputs
		   .CLK			(CLK),
		   .RESET		(RESET),
		   .SYNC_STATUS	(SYNC_STATUS),
		   .SUDI		(SUDI[10:0])
		   );

tester P0 (
    // Se conectan los cables del modulo tester con los mismos cables pero del testbench
    .CLK (CLK),
    .RESET (RESET), 
    .SYNC_STATUS (SYNC_STATUS),
    .SUDI (SUDI),
    .RXD (RXD),
    .RX_DV (RX_DV) 
  );


endmodule
