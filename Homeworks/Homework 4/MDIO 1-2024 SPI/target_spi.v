module target_spi(/*AUTOARG*/
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
  reg [4:0] cuenta_bits, cuenta_bits_d, prox_cuenta_bits;
  reg NXT_MISO;
  reg [15:0] dato_recibido, prox_dato_recibido;
  reg [15:0] dato_enviado, prox_dato_enviado;
  reg [7:0] quinto_digito;                                // 5th digit of my carnet
  reg [7:0] sexto_digito;                                 // 6th digit of my carnet
  reg SS_d, MOSI_d;
  wire posedge_SS, trans_finalizada;

  // DETECCION DEL FLANCO NEGATIVO DE SS
  assign negedge_SS = !SS && SS_d;
  assign trans_finalizada  = (cuenta_bits_d == 15);

  // Flip flops
  always @(posedge SCK) begin
    if (RESET || negedge_SS) begin
      estado        <= IDLE;
      cuenta_bits   <= 0;
      cuenta_bits_d   <= 0;
      dato_recibido <= 0;
      dato_enviado <= 16'b0000011000000001;
    end else begin
      estado        <= prox_estado;
      //cuenta_bits   <= cuenta_bits+1;
      cuenta_bits   <= prox_cuenta_bits;
      dato_recibido <= prox_dato_recibido;
      dato_enviado  <= prox_dato_enviado;
      cuenta_bits_d   <= cuenta_bits;
    end
  end //Fin de los FFs

//FLIP FLOP PARA DETECTAR EL FLANCO DE MDIO
//NO PUEDE DEPENDER DE POSEDGE DE MDIO PORQUE
//HACE REFERENCIA CIRCULAR

  always @(posedge SCK) begin
          if (RESET) begin
                SS_d   <= 1;
                MOSI_d  <= 0;
          end else begin
                SS_d   <= SS;
                MOSI_d  <= MOSI;
          end
  end


  //Logica combinacional

  always @(*) begin
    prox_estado = estado;
    prox_dato_enviado = dato_enviado;
    prox_dato_recibido = dato_recibido;

    case (estado)
	    IDLE: 
          begin
            prox_cuenta_bits = 0;
            if (SS==0)   prox_estado = ESCRITURA_LECTURA;
          end

      ESCRITURA_LECTURA: 
          begin
              prox_cuenta_bits = cuenta_bits+1;
              if (SS==0 || SS_d) prox_dato_recibido[15-cuenta_bits] = MOSI_d;
              MISO = dato_enviado[15-cuenta_bits];                          // Sending data
              dato_recibido[15-cuenta_bits] = MOSI;                         // Receiving data
              if (trans_finalizada) prox_estado = IDLE;
          end
      default: begin
                prox_estado = IDLE;
	             end
    endcase;
  end
endmodule
