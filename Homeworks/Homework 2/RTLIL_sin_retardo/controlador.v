// Maquina de estados para el controlador del estacionamiento
// Autor: Alonso José Jiménez Anchía

// **Declaracion del modulo**

// Argumentos del modulo son todos los puertos
// de entrada y de salida
module controlador (
    clock,
    reset,
    sensor_a,
    sensor_b,
    pin_validation,
    pin,
    alarma_pin_incorrecto,
    alarma_bloqueo,
    senal_abrir_compuerta,
    senal_cerrar_compuerta,
    );

// **Entradas**
input clock, reset, sensor_a, sensor_b, pin_validation;
input [7:0] pin;

// **Salidas**
output reg alarma_pin_incorrecto, alarma_bloqueo;
output reg senal_abrir_compuerta, senal_cerrar_compuerta;

// **Variables Internas**

// Estados de 3 bits tal que 2^3=8 estados posibles en total
reg [2:0] state;

// Para guardar un estado anterior
reg [2:0] old_state;

// Para guardar siguiente estado anterior
reg [2:0] next_old_state;

// Contador de 5 bits => Cuenta hasta 2^5=32
reg [4:0] i;

// Proximo estado tambien es una variable de 3 bits
reg [2:0] nxt_state;

// Siguiente valor de contador tambien de 5 bits
reg [4:0] nxt_i = 0;  

// Siguientes valores de salidas son reg de 1 bit
reg [1:0] next_alarma_pin_incorrecto;
reg [1:0] next_alarma_bloqueo;
reg [1:0] next_senal_abrir_compuerta;
reg [1:0] next_senal_cerrar_compuerta;

// Cable auxiliar para saber cuando sensor a y sensor b están, ambos
// en estado alto y así tener la condición para ingresar al estado e.
wire Y;

//Ambas variables almacenadas en registros hechos con FF de flanco positivo.
// Un FF por bit de cada variable.
always @(posedge clock) begin
  if (reset) begin
    state  <= 3'b000;
    i <= 5'b00000;
    alarma_pin_incorrecto <= 0;
    alarma_bloqueo <= 0;
    senal_abrir_compuerta <= 0;
    senal_cerrar_compuerta <= 0;
    old_state <= 0;
  end else begin
    state  <= nxt_state;
    i <= nxt_i;
    alarma_pin_incorrecto <= next_alarma_pin_incorrecto;
    alarma_bloqueo <= next_alarma_bloqueo;
    senal_abrir_compuerta <= next_senal_abrir_compuerta;
    senal_cerrar_compuerta <= next_senal_cerrar_compuerta;
    old_state <= next_old_state;
  end
end  //Fin de los flip flops

// **Logica combinacional**

always @(*) begin

// Valores por defecto

  nxt_state = state;                                              // Para completar el comportamiento del FF se necesita
                                                                  // que por defecto el nxt_state sostenga el valor del 
                                                                  // estado anterior
  nxt_i = i;                                                      // Igual al caso de state y nxt_state, para garantizar el 
                                                                  // comportamiento del FF. 
  next_alarma_pin_incorrecto = alarma_pin_incorrecto;
  next_alarma_bloqueo = alarma_bloqueo;
  next_senal_abrir_compuerta = senal_abrir_compuerta;
  next_senal_cerrar_compuerta = senal_cerrar_compuerta;
  next_old_state = old_state;

// Comportamiento de la maquina de estados
// Define las transiciones de proximo estado segun el diagrama ASM
// visto en clase y el comportamiento de "valid" y "count0" en el 
// ultimo estado, segun la especificacion.

  case(state)
    3'b000: begin                                                       // Estado a, #0
                 if (Y) begin                                           // Se revisa si sensorA=SensorB=activados
                    next_alarma_bloqueo = 1;                            // Se activa alarma de bloqueo
                    next_senal_abrir_compuerta = 0;                     // Senal abrir compuerta se bloquea
                    next_senal_cerrar_compuerta = 0;                    // Senal cerrar compuerta se bloquea
                    next_old_state = state;                             // Se guarda estado actual
                    nxt_state = 3'b100;                                 // Siguiente estado e, estado bloqueante.
                 end
                 else begin
                    next_senal_cerrar_compuerta = 0;                      // Senal cerrar compuerta en estado bajo
                    next_alarma_pin_incorrecto=0;                         // Alarma pin incorrecto desactivada
                    next_alarma_bloqueo=0;                                // Alarma bloqueo desactivada
                    next_senal_abrir_compuerta=0;                         // Senal abrir compuerta desactivada
                    next_senal_cerrar_compuerta=0;                        // Senal cerrar compuerta desactivada
                    if (sensor_a && ~sensor_b) begin 
                        nxt_state = 3'b001; 
                        end
                    else begin 
                     nxt_state = 3'b000;
                    end
                 end
    end
                                                                   // Solo salimos de este estado cuando sensor_a=1'b1

    3'b001: begin                                                  // Estado b, #1

                 if (Y) begin                                      // Se revisa si sensorA=SensorB=activados
                    next_alarma_bloqueo = 1;                       // Se activa alarma de bloqueo
                    next_senal_abrir_compuerta = 0;                // Senal abrir compuerta se bloquea
                    next_senal_cerrar_compuerta = 0;               // Senal cerrar compuerta se bloquea
                    next_old_state = state;                        // Se guarda estado actual
                    nxt_state = 3'b100;                            // Siguiente estado e, estado bloqueante.
                 end
                 else begin
                     if (pin == 8'b00111101 && pin_validation) begin
                        nxt_state = 3'b010;                              // Estado siguiente -> c
                        nxt_i = 0;                                       // Siguiente flanco i = 0        
                     end
                     if (pin != 8'b00111101 && pin_validation) begin   // Si pin incorrecto + validacion: 
                        nxt_i = i + 1;                                   // i++ en sig. flanco
                     end
                     if (i>=3) begin                                   // Si contador lleva 3 o más pines incorrectos
                        next_alarma_pin_incorrecto = 1;                // Se activa API: Alarma por pin incorrecto.
                        nxt_state = 3'b011;                            // Estado siguiente -> d.
                     end
                 end

               end

    3'b010: begin                                                  // Estado c, #2
                 if (Y) begin                                      // Se revisa si sensorA=SensorB=activados
                    next_alarma_bloqueo = 1;                            // Se activa alarma de bloqueo
                    next_senal_abrir_compuerta = 0;                     // Senal abrir compuerta se bloquea
                    next_senal_cerrar_compuerta = 0;                    // Senal cerrar compuerta se bloquea
                    next_old_state = state;                             // Se guarda estado actual
                    nxt_state = 3'b100;                            // Siguiente estado e, estado bloqueante.
                 end
                 else begin
                    next_alarma_pin_incorrecto = 0;                // Alarma por pin incorrecto se desactiva
                    next_senal_abrir_compuerta = 1;                // Senal para abrir compuerta se activa
                    if (sensor_b && ~sensor_a) begin               // Si sensor A = ON & sensor B = OFF
                    next_alarma_bloqueo = 0;                       // Se desactiva alarma de bloqueo
                    nxt_state = 3'b101;                            // Estado siguiente -> f
                    end
                 end
               end

    3'b011: begin                                                  // Estado d, #3
                 if (Y) begin                                      // Se revisa si sensorA=SensorB=activados
                    next_alarma_bloqueo = 1;                       // Se activa alarma de bloqueo
                    next_senal_abrir_compuerta = 0;                // Senal abrir compuerta se bloquea
                    next_senal_cerrar_compuerta = 0;               // Senal cerrar compuerta se bloquea
                    next_old_state = state;                        // Se guarda estado actual
                    nxt_state = 3'b100;                            // Siguiente estado e, estado bloqueante.
                 end
                 else begin
                    next_alarma_pin_incorrecto = 1;                 // Alarma por pin incorrecto se activa
                    if (pin == 8'b00111101 && pin_validation) begin // Si pin es correcto:
                        nxt_i = 5'b00000;                           // Se reinicia contador
                        nxt_state = 3'b010;                         // Estado siguiente -> c
                    end
                    if (pin != 8'b00111101 && pin_validation) begin
                      nxt_i = i + 1;                                // i++
                    end
                 end
               end
    3'b100: begin                                                   // Estado e, #4
                next_alarma_bloqueo = 1;                            // Se activa alarma de bloqueo
                next_senal_abrir_compuerta = 0;                     // Senal abrir compuerta se bloquea
                if (pin == 8'b00111101 && pin_validation) begin     // Si pin es correcto:
                    nxt_state = old_state;                          // Estado siguiente -> f
                 end

              end

    3'b101: begin                                                   // Estado f, #5
                  if (Y) begin                                      // Se revisa si sensorA=SensorB=activados
                      next_alarma_bloqueo = 1;                      // Se activa alarma de bloqueo
                      next_senal_abrir_compuerta = 0;               // Senal abrir compuerta se bloquea
                      next_senal_cerrar_compuerta = 0;              // Senal cerrar compuerta se bloquea
                      next_old_state = state;                       // Se guarda estado actual
                      nxt_state = 3'b100;                           // Siguiente estado e, estado bloqueante.
                 end
                 else begin
                      next_alarma_bloqueo = 0;                      // Se desactiva alarma de bloqueo
                      next_senal_abrir_compuerta = 0;               // Senal para abrir compuerta se desactiva
                      next_senal_cerrar_compuerta = 1;              // Senal para cerrar compuerta se activa
                      if (~sensor_b) begin                          // Cuando sensor B se inactive:
                                        nxt_state = 3'b000;         // Estado siguiente -> a
                                    end
                 end

              end                                              

    default:   nxt_state = 3'b000;                                  // Si la maquina entrara en un estado 
                                                                    // inesperado, regrese al inicio.
  endcase

end                                                                 // Este end corresponde al always @(*)
                                                                    // de la logica combinacional

                                                                    // Variable Y en estado alto permite ingreso al estado e.
assign Y = sensor_a & sensor_b;                                     // En cualquier momento, si sensor_a=sensor_b=1 entonces Y=1

endmodule