/*
********************************************************
*** Universidad de Costa Rica.                       ***
*** Circuitos Digitales II - IE0523.                 ***
*** Proyecto Final: Bloque de PCS tipo 1000BASE-X.   ***
*** Fecha: 6 de julio de 2024.                       ***
*** Creadores: Alonso Jiménez Anchía. B63561.        ***
***            Daniela Ulloa Barboza. B77748.        ***
***            Paulette Pérez Monge. B95916.         ***
********************************************************

*** TESTBENCH PCS ***

Descripción: En este archivo se genera el módulo testbench para el módulo PCS y el módulo tester,
y tiene como objetivo realizar la unión entre ambos y poder generar los resultados necesarios
para poder ser visualizados en una herramienta de simulación como GTKWave.*/

// ** Inicio del código **

`include "tester.v"
`include "PCS.v"

module PCS_tb;

// General
wire CLK, RESET;

// Cables Al Transmisor
wire TX_EN_;
wire [7:0] TXD_;
wire [9:0] tx_code_group_; 

// Cables Al Receptor
wire SYNC_STATUS;
wire [7:0] RXD;
wire RX_DV; 


initial begin
	    $dumpfile("PCS.vcd");
	    $dumpvars(-1, P0);
            $dumpvars(-1, TE0);
end

    PCS P0 (
        // Inputs
	.CLK	  (CLK),
	.RESET	  (RESET),
        .TX_EN_   (TX_EN_),
	.TXD_	  (TXD_),
        // Outputs
	.RXD	  (RXD),
        .RX_DV    (RX_DV)
    );

    tester TE0 (
        // Outputs
        .CLK      (CLK),
        .RESET    (RESET),
        .TX_EN_   (TX_EN_),
        .TXD_     (TXD_)
    );

endmodule
