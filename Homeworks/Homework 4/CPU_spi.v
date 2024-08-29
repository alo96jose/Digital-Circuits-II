module CPU_spi(/*AUTOARG*/
   // Outputs
   MOSI, SCK, CS,
   // Inputs
   CLK, RESET, CKP, CPH, MISO, START_STB, transaccion
   );

  // Entradas
  input CLK, RESET, CKP, CPH, MISO, START_STB;
  input [15:0] transaccion;

  // Salidas
  output reg MOSI, CS;
  output SCK;


  // Parametros
  localparam IDLE = 3'b001;
  localparam ESCRITURA_LECTURA = 3'b010;
  localparam DIV_FREQ = 2;


  // Variables intermedias
  reg [2:0]  estado, prox_estado;
  reg [4:0] cuenta_bits_d, cuenta_bits, prox_cuenta_bits;
  reg NXT_CS, NXT_MOSI;
  reg [DIV_FREQ-1:0] div_freq;
  reg SCK_anterior;
  reg [15:0] dato_recibido, prox_dato_recibido;
  reg [15:0] dato_enviado, prox_dato_enviado;

  // WIRES
  wire posedge_SCK;
  wire trans_finalizada;
  
  // ASSIGNS
  assign trans_finalizada = (cuenta_bits_d == 31);

  // MDC a fraccion del CLK
  assign SCK = div_freq[DIV_FREQ-1];
  assign posedge_SCK = !SCK_anterior && SCK;

  // Flip flops
  always @(posedge CLK) begin
    if (RESET) begin
      estado        <= IDLE;
      cuenta_bits   <= 0;
      div_freq      <= 0;
      SCK_anterior <= 0;
      CS <= 1;
      MOSI <= 0;
      dato_recibido <= 0;
      dato_enviado <=0;
    end else begin
      estado        <= prox_estado;
      cuenta_bits   <= prox_cuenta_bits;
      div_freq      <= div_freq+1;
      SCK_anterior <= SCK;
      CS <= NXT_CS;
      MOSI <= NXT_MOSI;
      dato_recibido <= prox_dato_recibido;
      dato_enviado <= prox_dato_enviado;

    end
  end //Fin de los FFs

  //Logica combinacional
  always @(*) begin

    // Valores por defecto
    prox_estado = estado;
    prox_cuenta_bits   = cuenta_bits;
    NXT_CS = CS;
    NXT_MOSI = MOSI;
    prox_dato_recibido = dato_recibido;
    prox_dato_enviado = dato_enviado;
    
 
    case (estado)
      IDLE:
        begin
          NXT_CS = 1; 
          prox_cuenta_bits = 0;
          NXT_MOSI = 0;
          if (START_STB) begin
            prox_estado = ESCRITURA_LECTURA; 
          end
          /*
          nxt_mdio_oe = start_stb;
	        if (start_stb && write) begin
              prox_estado = ESCRITURA;
          end else if (start_stb && ~write) begin
            prox_estado = LECTURA;
	        end */
	      end

      ESCRITURA_LECTURA: 
        begin
          NXT_CS = 0;  
          if (posedge_SCK)
                      begin
                      prox_cuenta_bits = cuenta_bits + 1;
                      NXT_MOSI = transaccion[15-cuenta_bits];                          // Sending data
                      dato_recibido[15-cuenta_bits] = MISO;                            // Receiving data
                      end
          if (cuenta_bits == 15) prox_estado = IDLE;
          
          /*
          if (trans_finalizada) prox_estado = INICIO;
          nxt_mdio_oe = 1;
          prox_cuenta_bits = cuenta_bits+1;*/
        end

      default:  
        begin
          prox_estado = IDLE;
          prox_dato_recibido = 0;
      end
    endcase;
  end

/*
//Generación del reloj de salida MDC  
reg clk_div2; 
wire clk_div4;
reg [1:0] count_clock; */
/*
always @(posedge CLK) begin
  if (RESET) begin
    clk_div2    <= 0;
    count_clock <= 0;
  end else begin
    clk_div2    <= ~clk_div2;
    count_clock <= count_clock+1;
  end
end*/

//assign clk_div4 = count_clock[1];
//assign mdc = clk_div2;

/*
// Incremento de cuenta_bits
always @(posedge mdc) begin
   if (reset || start_stb) begin
     cuenta_bits   <= 0;
     cuenta_bits_d <= 0;
     mdio_oe       <= 0;
   end else begin
     cuenta_bits   <= prox_cuenta_bits;
     cuenta_bits_d <= cuenta_bits;
     mdio_out      <= transaccion[31-cuenta_bits];
     //mdio_oe       <= nxt_mdio_oe;
   end
 end */

endmodule
