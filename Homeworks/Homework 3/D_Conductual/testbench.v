// Para poder instanciar los modulos controlador y tester:
`include "tester.v"
`include "cmos_cells.v"
`include "controlador.v" // En caso de que ocupe correr el diseño conductual
//`include "controlador_synth.v"

// Testbench Code Goes here
module controlador_tb;

  // Modulo del testbench necesita cables para conectar los modulos controlador con tester
  wire CLK, RESET, TARJETA_RECIBIDA, TIPO_TRANS, DIGITO_STB, MONTO_STB;
  wire [15:0] PIN;
  wire [3:0] DIGITO;
  wire [31:0] MONTO;
  wire BALANCE_ACTUALIZADO, ENTREGAR_DINERO, PIN_INCORRECTO;
  wire ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES;

  initial begin
    // Los resultados del testbench se guardan en resultados.vcd
	  $dumpfile("resultados.vcd");
    // Todas las variables y señales del modulo U0 serán registradas en el archivo resultados.vcd
	  $dumpvars(-1, U0);
    // Para mostrar los valores de variables o expresiones durante la simulación.
	  $monitor ("TARJETA_RECIBIDA=%b,TIPO_TRANS=%b,DIGITO_STB=%b,MONTO_STB=%b,PIN=%b,DIGITO=%b,MONTO=%b,BALANCE_ACTUALIZADO=%b, ENTREGAR_DINERO=%b, PIN_INCORRECTO=%b, ADVERTENCIA=%b, BLOQUEO=%b, FONDOS_INSUFICIENTES=%b",
    TARJETA_RECIBIDA, TIPO_TRANS, DIGITO_STB, MONTO_STB, PIN, DIGITO, MONTO, BALANCE_ACTUALIZADO, ENTREGAR_DINERO, PIN_INCORRECTO, 
    ADVERTENCIA, BLOQUEO, FONDOS_INSUFICIENTES);
  end

  controlador U0 (

    // Se conectan los cables del modulo controlador con los mismos cables pero del testbench
    .CLK (CLK),
    .RESET (RESET),
    .TARJETA_RECIBIDA (TARJETA_RECIBIDA),
    .TIPO_TRANS (TIPO_TRANS),
    .DIGITO_STB (DIGITO_STB),
    .DIGITO (DIGITO),
    .PIN (PIN),
    .MONTO_STB (MONTO_STB),
    .MONTO (MONTO),
    .BALANCE_ACTUALIZADO (BALANCE_ACTUALIZADO),
    .ENTREGAR_DINERO (ENTREGAR_DINERO),
    .PIN_INCORRECTO (PIN_INCORRECTO),
    .ADVERTENCIA (ADVERTENCIA),
    .BLOQUEO (BLOQUEO),
    .FONDOS_INSUFICIENTES (FONDOS_INSUFICIENTES));

  tester P0 (
    // Se conectan los cables del modulo tester con los mismos cables pero del testbench
    .CLK (CLK),
    .RESET (RESET),
    .TARJETA_RECIBIDA (TARJETA_RECIBIDA),
    .TIPO_TRANS (TIPO_TRANS),
    .DIGITO_STB (DIGITO_STB),
    .DIGITO (DIGITO),
    .PIN (PIN),
    .MONTO_STB (MONTO_STB),
    .MONTO (MONTO),
    .BALANCE_ACTUALIZADO (BALANCE_ACTUALIZADO),
    .ENTREGAR_DINERO (ENTREGAR_DINERO),
    .PIN_INCORRECTO (PIN_INCORRECTO),
    .ADVERTENCIA (ADVERTENCIA),
    .BLOQUEO (BLOQUEO),
    .FONDOS_INSUFICIENTES (FONDOS_INSUFICIENTES));

endmodule
