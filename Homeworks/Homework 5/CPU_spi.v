module CPU_spi(
   // Outputs
   MOSI, CS, SCK, SCK_anterior,
   CLK, RESET, START_STB, MISO, transaccion, trans_finalizada, CKP, CPH
   );

  // Entradas y salidas
  input CLK,RESET,START_STB,MISO, trans_finalizada, CKP, CPH;
  input [15:0] transaccion;
  output reg MOSI, CS;
  output SCK, SCK_anterior;

  // Variables intermedias
  reg [1:0]  estado, prox_estado;
  reg [15:0] dato_leido, prox_dato_leido;
  reg [4:0]  cuenta_bits_d, cuenta_bits, prox_cuenta_bits;
  reg NXT_CS, MISO_d;
  reg [4:0] aux;
  reg SCK_anterior;  
  reg PROX_MOSI;
  
  localparam INICIO    = 2'b01;
  localparam ESCRITURA_LECTURA = 2'b10;

  localparam MODE0 = 2'b00;   
  localparam MODE1 = 2'b01; 
  localparam MODE2 = 2'b10;   
  localparam MODE3 = 2'b11;    

  wire posedge_SCK;
  wire negedge_SCK;

  //Flip flops
  always @(posedge CLK) begin
    if (RESET==0) begin
      estado        <= INICIO;
      dato_leido <= 0;
      cuenta_bits <= 0;
      aux <= 0;
    end else begin
      estado <= prox_estado;
    end
  end

  // Logica combinacional
  always @(*) begin

  if (START_STB) flag = 1;
  prox_estado        = estado;
  prox_dato_leido    = dato_leido;
  NXT_CS = CS;
  prox_cuenta_bits = cuenta_bits;
  PROX_MOSI = MOSI;
  
    case (estado)
      INICIO:
        begin
          prox_cuenta_bits = 0;
          NXT_CS = !START_STB;
	        if (START_STB) 
              begin
                  prox_estado = ESCRITURA_LECTURA;
              end 
	      end
      ESCRITURA_LECTURA: 
        begin
            if (cuenta_bits == 18)
              begin
                prox_estado = INICIO;
                flag = 0;
              end
            else 
                begin
                  NXT_CS = 0;
                  case ({CKP, CPH})
                    MODE0:      
                        begin
                          if (posedge_SCK) 
                              begin 
                                PROX_MOSI <= transaccion[15-cuenta_bits];
                                if (MISO == 0 || MISO == 1) 
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    aux = cuenta_bits_d - 1;
                                    if (aux > 15) aux = 0; 
                                    prox_dato_leido[15-aux] = MISO;
                                  end
                              end
                        end
                    MODE1:  
                        begin
                          if (negedge_SCK) 
                              begin 
                                PROX_MOSI <= transaccion[15-cuenta_bits];
                                if (MISO == 0 || MISO == 1) 
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    aux = cuenta_bits_d - 1;
                                    if (aux > 15) aux = 0; 
                                    prox_dato_leido[15-aux] = MISO;
                                  end
                              end
                        end
                    MODE2:    
                        begin
                          if (negedge_SCK) 
                              begin 
                                PROX_MOSI <= transaccion[15-cuenta_bits];
                                if (MISO == 0 || MISO == 1) 
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    aux = cuenta_bits_d - 1;
                                    if (aux > 15) aux = 0; 
                                    prox_dato_leido[15-aux] = MISO;
                                  end
                              end
                        end
                    MODE3:  
                        begin
                          if (posedge_SCK) 
                              begin 
                                PROX_MOSI <= transaccion[15-cuenta_bits];
                                if (MISO == 0 || MISO == 1) 
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    aux = cuenta_bits_d - 1;
                                    if (aux > 15) aux = 0; 
                                    prox_dato_leido[15-aux] = MISO;
                                  end
                              end
                        end
                    default: begin end
                  endcase
                end
            
	      end
      default:  
        begin
          prox_estado = INICIO;
          prox_dato_leido = 0;
	      end
    endcase;
  end

// Generación del reloj de salida SCK
reg clk_div2;
wire clk_div4;
reg [1:0] count_clock;
reg SCK_reg, flag;

always @(posedge CLK) begin
  if (RESET==0) begin
    clk_div2    <= 0;
    count_clock <= 0;
    SCK_anterior <= 0;
  end 
  else if (flag) begin
    clk_div2    <= ~clk_div2;
    count_clock <= count_clock+1;
    SCK_anterior <= SCK;
  end
  else begin
    clk_div2    <= 0;
    count_clock <= 0;
  end

end

assign clk_div4 = count_clock[1];

always @(*) begin
    case ({CKP, CPH})
      MODE0: SCK_reg = clk_div2;
      MODE1: SCK_reg = ~clk_div2;
      MODE2: SCK_reg = clk_div2;
      MODE3: SCK_reg = ~clk_div2;
      default: SCK_reg = CKP;
    endcase
end

assign SCK = SCK_reg;
assign posedge_SCK = SCK & ~SCK_anterior;   // MODO 0 y 3
assign negedge_SCK = ~SCK & SCK_anterior;     // MODO 1 y 2


always @(posedge SCK) begin
  CS <= 1;
  if (RESET==0 || START_STB) 
    begin
        if (MODE0 || MODE3) begin
          cuenta_bits   <= 0;
          cuenta_bits_d <= 0;
          MISO_d  <= 0;
        end
    end 
  else 
  begin
      CS       <= NXT_CS;
      if (MODE0 || MODE3) begin
          cuenta_bits   <= prox_cuenta_bits;
          cuenta_bits_d <= cuenta_bits;
          dato_leido <= prox_dato_leido;
          MISO_d  <= MISO;
          PROX_MOSI <= transaccion[15-cuenta_bits];
          MOSI <= PROX_MOSI;
        end
  end
end

always @(negedge SCK) begin
  CS <= 1;
  if (RESET==0 || START_STB) 
    begin
        if (MODE1 || MODE2) begin
          cuenta_bits   <= 0;
          cuenta_bits_d <= 0;
        end
    end 
  else 
  begin
      CS <= NXT_CS;
      if (MODE1 || MODE2) begin
          cuenta_bits   <= prox_cuenta_bits;
          cuenta_bits_d <= cuenta_bits;
          dato_leido <= prox_dato_leido;
          MISO_d  <= MISO;
          MOSI <= PROX_MOSI;
        end
  end
end


endmodule
