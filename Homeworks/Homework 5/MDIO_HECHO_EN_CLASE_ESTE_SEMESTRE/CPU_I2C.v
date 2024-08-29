module CPU_I2C(
   // Outputs
   SDA_OUT, SDA_OE, SCL, RD_DATA,

   // Inputs
   CLK, RESET, START_STB, SDA_IN, transaccion, RNW, I2C_ADDR, WR_DATA
   );

  // Entradas
  input CLK, RESET, START_STB, SDA_IN, RNW;
  input [31:0] transaccion;
  input [6:0] I2C_ADDR;
  input [15:0] WR_DATA;

  // Salidas
  output reg SDA_OUT, SDA_OE;
  output  SCL;
  output reg [15:0] RD_DATA;

  localparam INICIO    = 3'b001;
  localparam ESCRITURA = 3'b010;
  localparam LECTURA   = 3'b100;
  localparam DIV_FREQ  = 2; // 25% del CLK

  // Variables intermedias
  reg [2:0] estado, prox_estado;
  reg [4:0] cuenta_bits, prox_cuenta_bits;
  reg [DIV_FREQ-1:0] div_freq;
  reg START_STB_d, START_STB_reg;
  wire iniciar, escritura, lectura;
  wire posedge_SCL;
  reg SCL_anterior, prox_SDA_OUT, SCL_reg, NXT_SDA_OE;

  assign iniciar   = (transaccion[31:30] == 2'b01);
  assign escritura = (transaccion[29:28] == 2'b01);
  assign lectura = (transaccion[29:28] == 2'b10);

  // SCL es fraccion del CLK
  //if (SDA_OUT) SCL_reg = 1;
  //else begin SCL_reg = div_freq[DIV_FREQ-1]; end
  assign SCL = SCL_reg;

  //assign SCL = div_freq[DIV_FREQ-1];
  //assign posedge_SCL = !SCL_anterior && SCL;
  assign posedge_SCL = !SCL_anterior && SCL;

  // Flip flops
  always @(posedge CLK) begin
    if (!RESET) begin
      estado        <= INICIO;
      cuenta_bits   <= 0;
      div_freq      <= 0;
      SCL_anterior  <= 1;
      SDA_OUT       <= 1;
      SDA_OE        <= 1;
      START_STB_reg <= 0;
      START_STB_d   <= 0;
    end else begin
      estado        <= prox_estado;
      cuenta_bits   <= prox_cuenta_bits;
      SDA_OE        <= NXT_SDA_OE;
      div_freq      <= div_freq+1;
      SCL_anterior  <= SCL;
      SDA_OUT       <= prox_SDA_OUT;
      START_STB_reg <= START_STB;
      START_STB_d   <= START_STB_reg;
    end
  end

  //Logica combinacional

  always @(*) begin
    if (SDA_OE) begin 
            SCL_reg = 1'b1;
        end else begin
            SCL_reg = div_freq[DIV_FREQ-1];
    end
    prox_estado = estado;
    prox_cuenta_bits = cuenta_bits;
    prox_SDA_OUT = SDA_OUT;
    NXT_SDA_OE = SDA_OE;

    case (estado)
	    INICIO: begin
		    SDA_OE = 1'b1;
        SDA_OUT = 1'b1;
		    prox_cuenta_bits = 0;
        if (START_STB && RNW) prox_estado = LECTURA;
        if (START_STB && !RNW) prox_estado = ESCRITURA;
	    end

	    ESCRITURA: 
        begin
		      NXT_SDA_OE = 1'b0;
		      if (posedge_SCL) 
            begin 
              prox_cuenta_bits = cuenta_bits+1;
              prox_SDA_OUT = I2C_ADDR[6-cuenta_bits];
              if (cuenta_bits == 8) begin prox_SDA_OUT = 0; end
              if (SDA_IN) begin end
              //if (cuenta_bits == 15) begin prox_estado = INICIO; end
            end
        end

	    LECTURA: 
        begin
          // if (negedge SDA_OE && SCL) 
          // Debo indicar en transaccion[8] = 1; para que el TARGET sepa que se trata de una lectura.
          SDA_OE = 1'b0;
          if (posedge_SCL) prox_SDA_OUT = transaccion[31-cuenta_bits];
          if (!SDA_OE) RD_DATA[31-cuenta_bits] = SDA_IN;
          if (posedge_SCL) prox_cuenta_bits = cuenta_bits+1;
          if (cuenta_bits == 31) prox_estado = INICIO;
        end
        /*
        begin
          SDA_OE = (cuenta_bits < 16);
          if (posedge_SCL) prox_SDA_OUT = transaccion[31-cuenta_bits];
          if (!SDA_OE) RD_DATA[31-cuenta_bits] = SDA_IN;
          if (posedge_SCL) prox_cuenta_bits = cuenta_bits+1;
          if (cuenta_bits == 31) prox_estado = INICIO;
        end
        */

      default: begin end
    endcase;
  end
endmodule
