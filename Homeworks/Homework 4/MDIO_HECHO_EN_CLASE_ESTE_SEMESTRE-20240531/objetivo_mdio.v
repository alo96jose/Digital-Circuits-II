module objetivo_mdio(
   // Inputs
   mdio_out, mdio_oe, mdc, dato_leido,
   // Outputs
   reset, mdio_in, reg_addr
   );

  //Entradas y salidas
  output reg mdio_in;
  output     [4:0] reg_addr;
  input reset, mdio_out, mdio_oe, mdc;
  input [15:0] dato_leido;

  localparam INICIO       = 3'b001;
  localparam RECIBIR_BITS = 3'b010;
  localparam ENVIAR_BITS  = 3'b100;

  //Variables intermedias
  reg [2:0] estado, prox_estado;
  reg [4:0] cuenta_bits, prox_cuenta_bits;
  wire escritura, lectura;
  wire [1:0] start, op;
  wire [4:0] phy_addr;
  reg [31:0] transaccion;

  assign escritura = (op[1:0] == 2'b01);
  assign lectura   =   (op == 2'b10);
  assign start     = transaccion[31:30];
  assign op        = transaccion[29:28];
  assign phy_addr  = transaccion[27:24];
  assign reg_addr  = transaccion[24:20];

  //Fip flops
  always @(posedge mdc) begin
    if (reset) begin
      estado       <= INICIO;
      cuenta_bits  <= 0;
    end else begin
      estado       <= prox_estado;
      cuenta_bits  <= prox_cuenta_bits;
    end
  end

  //Logica combinacional

  always @(*) begin
    prox_estado = estado;
    prox_cuenta_bits = cuenta_bits;

    case (estado)
	    INICIO: begin
		    prox_cuenta_bits = 0;
		    if (mdio_oe)   prox_estado = RECIBIR_BITS;
	    end
	    RECIBIR_BITS: begin
	        prox_cuenta_bits = cuenta_bits+1;
		transaccion[31-cuenta_bits] = mdio_out;
	    	if (lectura && (cuenta_bits == 15)) prox_estado = ENVIAR_BITS;
		if (cuenta_bits == 31) prox_estado = INICIO;

            end
	    ENVIAR_BITS: begin
	        prox_cuenta_bits = cuenta_bits+1;
		mdio_in = dato_leido[31-cuenta_bits];
		if (cuenta_bits == 31) prox_estado = INICIO;
	    end
            default: begin
	    end
    endcase;
  end
endmodule
