module tester (
  clock, 
  reset, 
  sensor_a,
  sensor_b,
  pin_validation,
  pin,
  alarma_pin_incorrecto,
  alarma_bloqueo,
  senal_abrir_compuerta,
  senal_cerrar_compuerta);

  output clock, reset, sensor_a, sensor_b, pin_validation;
  output reg [7:0] pin;
  input alarma_pin_incorrecto, alarma_bloqueo, senal_abrir_compuerta, senal_cerrar_compuerta;

  reg clock, reset, sensor_a, sensor_b, pin_validation;
  wire alarma_pin_incorrecto, alarma_bloqueo, senal_abrir_compuerta, senal_cerrar_compuerta;

// Periodo T = 20s
  initial begin

    // Todas las senales, salidas y variables internas a su estado inicial
    clock = 0;
    reset = 0;
    sensor_a = 0;
    sensor_b = 0;
    pin = 8'b00000000;
    pin_validation = 0;

    // Boton reset
    #20 reset = 1;
    #20 reset = 0;

    // Nota: Las pruebas se pueden comentar e ir probando una por una.

    // Prueba 1: Funcionamiento normal basico
/*
    #20 sensor_a = 1;                                             // Llega vehiculo, sensor A se activa. Estado a.
    #24 {pin,pin_validation} = {8'b00111101,1'b1};                // Ingreso de pin correcto. Estado b -> c. 
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #10 sensor_a = 0;                                             // Sensor A se desactiva
    #55 sensor_b = 1;                                             // Sensor B se activa. Estado -> f.
    #60 sensor_b = 0;                                             // Sensor B inactivo en este punto indica que 
                                                                  // se regresa a estado a.

    // Prueba 2: Ingreso de pin incorrecto menos de 3 veces

    #20 sensor_a = 1;                                             // Llega vehiculo, sensor A se activa. Estado a.
                                                                  // Estado b:
    #30 {pin,pin_validation} = {8'b00111111,1'b1};                // Ingreso de pin incorrecto (primera) + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #30 {pin,pin_validation} = {8'b01111101,1'b1};                // Ingreso de pin correcto (segunda) + señal para leer pin
    #19 pin_validation = 1'b0;                                    // Para que no vuelva a leer el pin
    #30 {pin,pin_validation} = {8'b00111101,1'b1};                // Ingreso de pin correcto + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #20 sensor_a = 0;                                              // Sensor A se desactiva
    #50 sensor_b = 1;                                             // Sensor B se activa
    #60 sensor_b = 0;                                             // Sensor B inactivo en este punto indica que 
                                                                  // se regresa a estado a.
*/
    // Prueba 3: Ingreso de pin incorrecto 3 veces o más
  
    #40 sensor_a = 1;                                             // Llega vehiculo, sensor A se activa. Estado a.
                                                                // Estado b:
    #25 {pin,pin_validation} = {8'b00111111,1'b1};                // Ingreso de pin incorrecto (primera) + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #30 {pin,pin_validation} = {8'b01111101,1'b1};                // Ingreso de pin correcto (segunda) + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #30 {pin,pin_validation} = {8'b11111101,1'b1};                // Ingreso de pin correcto (tercera) + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
                                                                  // Se ingresa a estado d:
    #30 {pin,pin_validation} = {8'b01111111,1'b1};                // Ingreso de pin correcto (cuarta) + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
    #30 {pin,pin_validation} = {8'b00111101,1'b1};                // Ingreso de pin correcto + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
                                                                  // Se ingresa a estado c:
    #20 sensor_a = 0;                                              // Sensor A se desactiva
    #60 sensor_b = 1;                                             // Sensor B se activa
    #60 sensor_b = 0;                                             // Sensor B inactivo en este punto indica que 
                                                                  // se regresa a estado a.
/*
    // Prueba 4: Alarma de bloqueo.

    #45 sensor_a = 1;                                             // Llega vehiculo, sensor A se activa. Estado a.
                                                                  // Estado b:
    #30 {pin,pin_validation} = {8'b00111101,1'b1};                // Ingreso de pin correcto + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
                                                                  // Se ingresa a estado c:
    #20 sensor_a = 0;                                              // Sensor A se desactiva de forma rutinaria
    #20 sensor_a = 1;                                              // Sensor A se activa de pronto
    #10 sensor_b = 1;                                             // Sensor B se activa
                                                                  // Ambos sensores encendidos al mismo tiempo:
                                                                  // Se ingresa al estado e:
    #30 {pin,pin_validation} = {8'b00111111,1'b1};                // Ingreso de pin incorrecto + señal para leer pin
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin

    #30 {pin,pin_validation,sensor_a} = {8'b00111101,1'b1,1'b0};  // Ingreso de pin correcto + señal para leer pin 
                                                                  // + desactivacion sensor A
    #19 {pin,pin_validation} = {8'b00000000,1'b0};                // Para que no vuelva a leer el pin
                                                                  // Continua el funcionamiento normal basico:
    #60 sensor_b = 0;                                             // Sensor B inactivo en este punto indica que
                                                                  // se regresa a estado a.
*/
    #80 $finish;
  end

  always begin
    #10 clock = !clock;                                            // Cada 5s cambia de estado (alto o bajo) el clock
  end

endmodule
