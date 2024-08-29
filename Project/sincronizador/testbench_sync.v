/*
********************************************************
*** Universidad de Costa Rica.                       ***
*** Circuitos Digitales II - IE0523.                 ***
*** Creadora: Daniela Ulloa Barboza. B77748.         ***
*** Proyecto Final: Bloque de PCS tipo 1000BASE-X.   ***
*** Fecha: 6 de julio de 2024.                       ***
********************************************************

*** TESTBENCH DEL SINCRONIZADOR DEL BLOQUE PCS ***/

// Includes del sincronizador y tester:
`include "sincronizador.v" // Módulo de implementación del sincronizador.
`include "tester_sync.v" // Probador.

// Módulo testbench:
module sync_tb;

    // En el testbench todos los puertos son wires.
    wire [10:0] SUDI; // Señal de salida que contiene rx_code_group y rx_even.
    wire sync_status; // Señal que indica si se está sincronizado.
    wire clk; // Reloj.
    wire reset; // Señal de reseteo de la máquina.
    wire [9:0] rx_cg; // Señal proveniente del transmisor con los code groups. (rx_code_group).
    //wire PUDI; // Señal tipo "strobe" que indica que ya el code group está listo para utilizarse.
    
    initial begin
        $dumpfile("resultados.vcd"); // Por estos comando se muestran los resultados.
	$dumpvars(-1, U0);
    end
    
    sincronizador U0 ( // Se hacen instanciaciones del módulo con las variables originales y las de este módulo.
        .clk (clk),
        .reset (reset),
        .rx_cg (rx_cg),
        .SUDI (SUDI),
        .sync_status (sync_status)
    );
    
    tester_sync P0 ( // Se hacen instanciaciones del módulo tester con las variables originales y las de este módulo.
        .clk (clk),
        .reset (reset),
        .rx_cg (rx_cg),
        .SUDI (SUDI),
        .sync_status (sync_status)
    );
endmodule
