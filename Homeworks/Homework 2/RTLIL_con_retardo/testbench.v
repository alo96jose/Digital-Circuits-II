// Para poder instanciar los modulos controlador y tester:
`include "tester.v"
`include "cmos_cells.v"
//`include "controlador.v" // En caso de que ocupe correr el diseño conductual
`include "controlador_synth.v"

// Testbench Code Goes here
module controlador_tb;

  // Modulo del testbench necesita cables para conectar los modulos controlador con tester
  wire clock, reset, sensor_a, sensor_b, pin_validation;
  wire [7:0] pin;
  wire alarma_pin_incorrecto, alarma_bloqueo, senal_abrir_compuerta, senal_cerrar_compuerta;

  initial begin
    // Los resultados del testbench se guardan en resultados.vcd
	  $dumpfile("resultados.vcd");
    // Todas las variables y señales del modulo U0 serán registradas en el archivo resultados.vcd
	  $dumpvars(-1, U0);
    // Para mostrar los valores de variables o expresiones durante la simulación.
	  $monitor ("sensor_a=%b,sensor_b=%b,pin_validation=%b,pin=%b,alarma_pin_incorrecto=%b,alarma_bloqueo=%b,senal_abrir_compuerta=%b,senal_cerrar_compuerta=%b",
    sensor_a,sensor_b,pin_validation,pin,alarma_pin_incorrecto,
    alarma_bloqueo,senal_abrir_compuerta,senal_cerrar_compuerta);
  end

  controlador U0 (

    // Se conectan los cables del modulo controlador con los mismos cables pero del testbench
    .clock (clock),
    .reset (reset),
    .sensor_a (sensor_a),
    .sensor_b (sensor_b),
    .pin_validation (pin_validation), 
    .pin (pin),
    .alarma_pin_incorrecto (alarma_pin_incorrecto), 
    .alarma_bloqueo (alarma_bloqueo), 
    .senal_abrir_compuerta (senal_abrir_compuerta), 
    .senal_cerrar_compuerta (senal_cerrar_compuerta)
  );

  tester P0 (
    // Se conectan los cables del modulo tester con los mismos cables pero del testbench
    .clock (clock),
    .reset (reset),
    .sensor_a (sensor_a),
    .sensor_b (sensor_b),
    .pin_validation (pin_validation),
    .pin (pin),
    .alarma_pin_incorrecto (alarma_pin_incorrecto), 
    .alarma_bloqueo (alarma_bloqueo), 
    .senal_abrir_compuerta (senal_abrir_compuerta), 
    .senal_cerrar_compuerta (senal_cerrar_compuerta)
  );

endmodule
