module CPU_spi(
   // Outputs
   MOSI, SCK, CS,
   // Inputs
   CLK, RESET, CKP, CPH, MISO, START_STB, transaccion, trans_finalizada
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
  //wire posedge_SCK;
  wire trans_finalizada;
  
  // ASSIGNS
  assign trans_finalizada = (cuenta_bits_d == 15);

  // SCK a fraccion del CLK
  //assign SCK = div_freq[DIV_FREQ-1];
  //assign posedge_SCK = !SCK_anterior && SCK;

/*******************************************************/
// Generación del reloj de salida SCK 
reg clk_div2; 
wire clk_div4;
reg [1:0] count_clock;
assign clk_div4 = count_clock[1];
assign SCK = clk_div2;
/*******************************************************/

// Flip flops
  always @(posedge CLK) begin
    if (RESET) begin
      estado        <= IDLE;
      div_freq      <= 0;
      SCK_anterior <= 0;
      CS <= 1;
      dato_recibido <= 0; /**/
      dato_enviado <=0; /**/
      MOSI <= 0; /**/

      clk_div2    <= 0;
      count_clock <= 0;
    end else begin
      estado        <= prox_estado;
      div_freq      <= div_freq+1;
      SCK_anterior <= SCK;
      CS <= NXT_CS;
      dato_recibido <= prox_dato_recibido; /**/
      dato_enviado <= prox_dato_enviado; /**/
      MOSI <= NXT_MOSI; /**/

      clk_div2    <= ~clk_div2;
      count_clock <= count_clock+1;

    end
  end //Fin de los FFs

// Incremento de cuenta_bits
always @(posedge SCK) begin
   if (RESET || START_STB) begin
     cuenta_bits   <= 0;
     cuenta_bits_d <= 0;
     CS            <= 0;
     MOSI          <= 0;
     dato_recibido <= 0;
     dato_enviado <= 0;
   end else begin
     cuenta_bits   <= prox_cuenta_bits;
     cuenta_bits_d <= cuenta_bits;
     //MOSI      <= transaccion[31-cuenta_bits];
     CS       <= NXT_CS;
     MOSI <= NXT_MOSI;
     dato_recibido <= prox_dato_recibido;
     dato_enviado <= prox_dato_enviado;
   end
 end

  //Logica combinacional
  always @(*) begin

    // Valores por defecto
    prox_estado = estado;
    prox_dato_recibido = dato_recibido;
    prox_dato_enviado = prox_dato_enviado;
    prox_cuenta_bits   = cuenta_bits;
    NXT_CS = CS;
    NXT_MOSI = MOSI;
 
    case (estado)
      IDLE:
        begin
          NXT_CS = 1; 
          prox_cuenta_bits = 0;
          NXT_MOSI = 0;
          if (START_STB) 
              begin
                  prox_estado = ESCRITURA_LECTURA; 
              end
	      end

      ESCRITURA_LECTURA: 
        begin
          NXT_CS = 0; 
          prox_cuenta_bits = cuenta_bits + 1;
          NXT_MOSI = transaccion[15-cuenta_bits];                          // Sending data
          //if ()
          prox_dato_recibido[15-cuenta_bits_d] = MISO;                       // Receiving data
          if (cuenta_bits == 15) prox_cuenta_bits = 0;
          if (trans_finalizada) prox_estado = IDLE;
        end

      default:  
        begin
          prox_estado = IDLE;
          prox_dato_recibido = 0;
        end
    endcase;
  end

endmodule
