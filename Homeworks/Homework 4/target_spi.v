module target_spi(
   // Inputs
   MOSI, SCK, SS, CKP, CPH, RESET,
   // Outputs
   MISO
   );

  // Entradas
  input MOSI, SCK, SS, CKP, CPH, RESET;

  // Salidas
  output reg MISO;

  // Parametros
  localparam IDLE = 3'b001;
  localparam ESCRITURA_LECTURA = 3'b010;

  // Variables intermedias
  reg [2:0]  estado, prox_estado;
  reg [4:0] cuenta_bits, prox_cuenta_bits;
  reg NXT_MISO;
  reg [15:0] dato_recibido, prox_dato_recibido;
  reg [15:0] dato_enviado, prox_dato_enviado;
  reg [7:0] quinto_digito;                                // 5th digit of my carnet
  reg [7:0] sexto_digito;                                 // 6th digit of my carnet
  reg SS_d, MISO_d;
  wire posedge_SS;

  // DETECCION DEL FLANCO POSITIVO DE SS
  assign posedge_SS = SS && !SS_d;

  // Fip flops
  always @(posedge SCK) begin
    if (RESET || posedge_SS) begin
      estado        <= IDLE;
      cuenta_bits   <= 0;
      MISO <= 0;
      dato_recibido <= 0;
      dato_enviado <= 16'b0000011000000001;
      SS_d   <= 0;
    end else begin
      estado        <= prox_estado;
      cuenta_bits   <= prox_cuenta_bits;
      MISO          <= NXT_MISO;
      dato_recibido <= prox_dato_recibido;
      dato_enviado  <= prox_dato_enviado;
      SS_d   <= SS;

    end
  end //Fin de los FFs

  //Logica combinacional

  always @(*) begin
    prox_estado = estado;
    prox_cuenta_bits = cuenta_bits;
    NXT_MISO = MISO;

    case (estado)
	    IDLE: 
          begin
            prox_cuenta_bits = 0;
            if (~SS)   prox_estado = ESCRITURA_LECTURA;
          end

      ESCRITURA_LECTURA: 
          begin
              prox_cuenta_bits = cuenta_bits+1;
              NXT_MISO = dato_enviado[15-cuenta_bits];                          // Sending data
              dato_recibido[15-cuenta_bits] = MOSI;                             // Receiving data

            if (cuenta_bits == 15) prox_estado = IDLE;  
          end
      default: begin
                prox_estado = IDLE;
	             end
    endcase;
  end
endmodule
