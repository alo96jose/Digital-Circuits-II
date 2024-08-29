`include "transmisor.v"
 
module spi_tb;

reg clk_, main_reset_, TX_EN_;
reg [7:0] TXD_;

wire [9:0] tx_code_group_;

localparam K27_7 = 8'b11111011; // S
localparam D27_0 = 8'b00011011;
localparam D28_0 = 8'b00011100;
localparam D29_0 = 8'b00011101;
localparam D30_0 = 8'b00011110;
localparam D31_0 = 8'b00011111;
localparam D0_1 = 8'b00100000;
localparam D1_1 = 8'b00100001;
localparam D2_1 = 8'b00100010;
localparam D3_1 = 8'b00100011;
localparam D4_1 = 8'b00100100;

initial begin
	$dumpfile("resultados.vcd");
	$dumpvars(-1, T1);
end

initial begin
    clk_ = 0;
    main_reset_ = 1;
    TX_EN_=0;
    TXD_= D27_0;
    #15 main_reset_=0;
    #10 main_reset_=1;
    #10 TXD_= D27_0; // Enviamos 5 codigos de prueba al inicio
    #10 TXD_= D28_0;
    #10 TXD_= D29_0;
    #10 TXD_= D30_0;
    #10 TXD_= D31_0;

    #10 TXD_= D27_0; // Enviamos datos
        
    #10 TXD_= K27_7;
        TX_EN_=1;
    #10 TXD_= D28_0;
    #10 TXD_= D29_0;
    #10 TXD_= D30_0;
    #10 TXD_= D31_0;
    #10 TXD_= D0_1;
    #10 TXD_= D1_1;
    #10 TXD_= D2_1;
    #10 TXD_= D3_1;
    #10 TXD_= D4_1;

    #10 TXD_= D0_1; // Terminamos con otros 5
        TX_EN_=0; 
    #10 TXD_= D1_1;
    #10 TXD_= D2_1;
    #10 TXD_= D3_1;
    #10 TXD_= D4_1;

    #70 $finish;
end

always begin
 #5 clk_ = !clk_;
end

transmisor T1(
    //INPUT
    .clk_(clk_),
    .main_reset_(main_reset_),
    .TX_EN_(TX_EN_),
    .TXD_(TXD_),
    //OUTPUT
    .tx_code_group_(tx_code_group_)
);


endmodule
