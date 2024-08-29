//Paulette Pérez Monge- B95916
//Máquina de estados del transmisor general
//junta las dos máquinas de estado
`include "transmisorOS.v"
`include "transmisorCG.v"

module transmisor(
    //INPUT
    clk_, main_reset_,TX_EN_,TXD_, //El guión bajo son los de la màquina completa
    //OUTPUT
    tx_code_group_
);

    //INPUT
    input clk_,main_reset_,TX_EN_;
    input [7:0] TXD_;
    //OUTPUT
    output [9:0] tx_code_group_; //sin re

    wire [9:0] tx_code_group;
    wire [4:0] tx_o_set;


    transmisorOS OS(
        //input
        .clk(clk_),
        .mr_main_reset(main_reset_),
        .TX_EN(TX_EN_),
        //output
        .tx_o_set(tx_o_set));

    transmisorCG CG(
        //input
        .clk(clk_),
        .mr_main_reset(main_reset_),
        .tx_o_set(tx_o_set),
        .TXD(TXD_),

        //output
        .tx_code_group(tx_code_group_));
        

endmodule
