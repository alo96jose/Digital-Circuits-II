module TARGET_I2C(
   // Inputs
   SDA_OUT, SDA_OE, SCL, RD_DATA, I2C_ADDR, CLK,
   // Outputs
   RESET, SDA_IN, reg_addr, WR_DATA
   );

  //Entradas y salidas
  output reg SDA_IN;
  output reg [15:0] WR_DATA; 
  output     [4:0] reg_addr;
  input RESET, SDA_OUT, SDA_OE, SCL, CLK;
  input [15:0] RD_DATA;
  input [6:0] I2C_ADDR;

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
  reg [6:0] I2C_ADDR_RECIBIDO, NXT_I2C_ADDR_RECIBIDO;
  reg SDA_OUT_reg, SDA_OUT_delay, SCL_anterior, flag, NXT_flag, NXT_SDA_IN;
   reg ACK1, NXT_ACK1, ACK2, NXT_ACK2;

  assign escritura = (op[1:0] == 2'b01);
  assign lectura   =   (op == 2'b10);
  assign start     = transaccion[31:30];
  assign op        = transaccion[29:28];
  assign phy_addr  = transaccion[27:24];
  assign reg_addr  = transaccion[24:20];

  assign posedge_SCL = !SCL_anterior && SCL;

  //Fip flops
  always @(posedge SCL) begin
    if (!RESET) begin
      cuenta_bits    <= 0;
      SDA_OUT_reg    <= 1;
      SDA_OUT_delay  <= 1;
    end else begin
      //cuenta_bits  <= prox_cuenta_bits;
      //I2C_ADDR_RECIBIDO <= NXT_I2C_ADDR_RECIBIDO;
      SDA_OUT_reg <= SDA_OUT;
      SDA_OUT_delay <= SDA_OUT_reg;
    end
  end

  always @(posedge CLK) begin
    if (!RESET) begin
      estado  <= INICIO;
      flag    <= 0;
      ACK1    <= 0;
      ACK2    <= 0;
    end else begin
      estado       <= prox_estado;
      SCL_anterior  <= SCL;
      cuenta_bits   <= prox_cuenta_bits;
      I2C_ADDR_RECIBIDO <= NXT_I2C_ADDR_RECIBIDO;
      flag <= NXT_flag;
      SDA_IN <= NXT_SDA_IN;
      ACK1          <= NXT_ACK1;
      ACK2          <= NXT_ACK2;
    end
  end

  //Logica combinacional

  always @(*) begin
    prox_estado = estado;
    prox_cuenta_bits = cuenta_bits;
    NXT_I2C_ADDR_RECIBIDO = I2C_ADDR_RECIBIDO;
    NXT_flag = flag;
    NXT_SDA_IN = SDA_IN;
    NXT_ACK1 = ACK1;
    NXT_ACK2 = ACK2;


    case (estado)
	    INICIO: 
        begin
          NXT_SDA_IN = 0;
		      prox_cuenta_bits = 0;
		      if (~SDA_OE) begin
		        prox_estado = RECIBIR_BITS;
		      end
	      end

	    RECIBIR_BITS: 
        begin
          if (posedge_SCL) 
            begin
             NXT_flag = 1;
             if (flag) 
              begin
                if (!SDA_IN && !ACK1 && !ACK2) 
                  begin 
                    prox_cuenta_bits = cuenta_bits+1;
                    NXT_I2C_ADDR_RECIBIDO[6-cuenta_bits] = SDA_OUT;
                    if (I2C_ADDR_RECIBIDO == I2C_ADDR)
                      begin 
                        NXT_SDA_IN = 1;
                        prox_cuenta_bits = 0;
                      end
                  end
                if (SDA_IN || ACK1) 
                  begin 
                    if (cuenta_bits < 8) 
                      begin
                        NXT_ACK1 = 1;
                        NXT_SDA_IN = 0;
                        prox_cuenta_bits = cuenta_bits+1;
                        WR_DATA[15-cuenta_bits] = SDA_OUT;
                      end
                    if (cuenta_bits==8) begin 
                      NXT_SDA_IN = 1; 
                      //prox_cuenta_bits = cuenta_bits+1;
                      end
                  end

                  if (SDA_IN || ACK2) 
                  begin 
                    if (cuenta_bits > 7) 
                      begin
                        NXT_ACK2 = 1;
                        NXT_SDA_IN = 0;
                        prox_cuenta_bits = cuenta_bits+1;
                        if (cuenta_bits < 16) WR_DATA[15-cuenta_bits] = SDA_OUT;
                        if (cuenta_bits==15) NXT_SDA_IN = 1;
                        if (SDA_OE) prox_estado = INICIO; 
                      end
                   
                  end
              end
            end
        end

	    ENVIAR_BITS:
        begin
	        prox_cuenta_bits = cuenta_bits+1;
		      SDA_IN = RD_DATA[31-cuenta_bits];
		      if (cuenta_bits == 31) prox_estado = INICIO;
	    end
      
      default: begin end

    endcase;
  end
endmodule
