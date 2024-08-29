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

*** BLOQUE PCS ***

Descripción: En este archivo se genera un módulo de unión llamado PCS, que corresponde al bloque de interés
de la figura 36-2 de la cláusula 36 del estándar IEEE 802.3. En este módulo se instancia el sub-bloque
Transmisor, el Sincronizador y el Receptor, los cuales son los encargados de generar el correcto envío
y recepción del paquete a comunicar.*/

// ** Inicio del código **

// Se instancian los otros sub-bloques.
`include "receptor.v"
`include "transmisor.v"
`include "sincronizador.v"

module PCS(
    // Inputs
    CLK, RESET, TX_EN_, TXD_,

    // Outputs
    RXD, RX_DV,
);

    // Inputs
    input wire CLK, RESET, TX_EN_;
    input wire [7:0] TXD_;

    // Outputs
    output [7:0] RXD;
    output RX_DV;

    // Transmisor
    wire [9:0] tx_code_group_;

    // Sincronizador
    wire [10:0] SUDI;
    wire sync_status; 

    // Receptor
    wire SYNC_STATUS;


    transmisor T0 (
        // Inputs
        // Originales    PCS
        .clk_            (CLK),
        .main_reset_     (RESET),
        .TX_EN_          (TX_EN_),
        .TXD_	         (TXD_),
        // Outputs
        .tx_code_group_	 (tx_code_group_)
    );

    sincronizador S0 (
        // Inputs
        .clk             (CLK),
        .reset           (RESET),
        .rx_cg           (tx_code_group_),
        // Outputs
        .SUDI            (SUDI[10:0]),
        .sync_status     (SYNC_STATUS)
    );

    receptor R0 (
        // Outputs
        .RXD	         (RXD),
	.RX_DV		 (RX_DV),
        // Inputs
        .CLK		 (CLK),
	.RESET		 (RESET),
        .SYNC_STATUS     (SYNC_STATUS),
	.SUDI	         (SUDI[10:0])
    );
endmodule
