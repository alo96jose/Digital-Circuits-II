module target_spi(/*AUTOARG*/
   // Outputs
   MISO, trans_finalizada,
   // Inputs
   SCK, RESET, MOSI, SS, dato_enviado, CKP, CPH, SCK_anterior
   );
  input SCK,RESET,MOSI,SS, CKP, CPH, SCK_anterior;
  input [15:0] dato_enviado;
  output reg MISO, trans_finalizada;

  //ESTADOS
  localparam INICIO = 2'b01;
  localparam ESCRITURA_LECTURA = 2'b10;

  localparam MODE0 = 2'b00;   
  localparam MODE1 = 2'b01; 
  localparam MODE2 = 2'b10;   
  localparam MODE3 = 2'b11;   

  //VARIABLES INTERMEDIAS
  reg [15:0] dato_leido,prox_dato_leido;
  reg [1:0] estado, prox_estado;
  reg [4:0] cuenta_bits, cuenta_bits_d, prox_cuenta_bits;
  reg SS_d, MOSI_d;  
  wire negedge_SS;

  wire posedge_SCK;
  wire negedge_SCK; 
  
  assign posedge_SCK = SCK & ~SCK_anterior;   // MODO 0 y 3
  assign negedge_SCK = ~SCK & SCK_anterior;   // MODO 1 y 2

  //DETECCION DEL FLANCO POSITIVO DE SS
  assign negedge_SS = !SS && SS_d;

  //FLIP FLOPS PARA LAS TRANSACCIONES
  always @(posedge SCK) begin
	  if (RESET==0 || negedge_SS) begin
	  //estado        <= ESCRITURA_LECTURA;
    estado        <= INICIO;
		dato_leido   <= 0;
		cuenta_bits   <= 0;
		cuenta_bits_d <= 0;
	  end else begin      
		estado        <= prox_estado;
		dato_leido   <= prox_dato_leido;
		cuenta_bits_d <= cuenta_bits;
	  end
  end 

  always @(posedge SCK) begin
          if (RESET==0) 
                begin
                  if (MODE0 || MODE3) 
                    begin
                      SS_d    <= 1;
                      MOSI_d  <= 0;
                    end
                end 
          else 
                begin
                  if (MODE0 || MODE3) 
                    begin
                      SS_d   <= SS;
                      MOSI_d  <= MOSI;
                      MISO <= dato_enviado[15-cuenta_bits]; 
                    end
                end
  end

  always @(negedge SCK) begin
          if (RESET==0) 
            begin
                if (MODE1 || MODE2) 
                    begin
                      SS_d    <= 1;
                      MOSI_d  <= 0;
                    end
              end 
          else 
                begin
                if (MODE1 || MODE2) 
                    begin
                      SS_d   <= SS;
                      MOSI_d  <= MOSI;
                      MISO <= dato_enviado[15-cuenta_bits];
                    end
                end
  end

    //Logica combinacional
    always @(*) begin
      prox_estado        = estado;
      prox_dato_leido = dato_leido; 
      prox_cuenta_bits = cuenta_bits;

      case (estado)
        INICIO:
          begin
            prox_cuenta_bits = 0;
            trans_finalizada = 0;
            if (SS==0) begin
              prox_estado = ESCRITURA_LECTURA;
            end
          end
        ESCRITURA_LECTURA: 
          begin
              if (cuenta_bits == 18)
                begin
                  prox_estado = INICIO;
                end
              else 
                  begin
                    case ({CKP, CPH})
                      MODE0:      
                          begin
                            if (posedge_SCK) 
                              begin 
                                if (MOSI == 0 || MOSI ==1)
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    prox_dato_leido[15-cuenta_bits] = MOSI;
                                      if (cuenta_bits==30) 
                                        begin
                                          trans_finalizada = 1;
                                          prox_estado = INICIO;
                                        end 
                                  end
                             end
                          end
                      MODE1:  
                           begin
                            if (negedge_SCK) 
                               begin 
                                if (MOSI == 0 || MOSI ==1)
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    prox_dato_leido[15-cuenta_bits] = MOSI;
                                      if (cuenta_bits==30) 
                                        begin
                                          trans_finalizada = 1;
                                          prox_estado = INICIO;
                                        end 
                                  end
                              end
                          end
                      MODE2:    
                          begin
                            if (negedge_SCK) 
                              begin 
                                if (MOSI == 0 || MOSI ==1)
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    prox_dato_leido[15-cuenta_bits] = MOSI;
                                      if (cuenta_bits==30) 
                                        begin
                                          trans_finalizada = 1;
                                          prox_estado = INICIO;
                                        end 
                                  end
                              end
                          end
                      MODE3:  
                          begin
                            if (posedge_SCK) 
                              begin
                                if (MOSI == 0 || MOSI ==1)
                                  begin
                                    prox_cuenta_bits = cuenta_bits+1;
                                    prox_dato_leido[15-cuenta_bits] = MOSI;
                                      if (cuenta_bits==30) 
                                        begin
                                          trans_finalizada = 1;
                                          prox_estado = INICIO;
                                        end 
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

  always @(posedge SCK) begin
  if (!RESET) 
    begin
        if (MODE0 || MODE3) begin
          cuenta_bits   <= 0;
          cuenta_bits_d <= 0;
        end
    end 
  else 
  begin
      if (MODE0 || MODE3) begin
          cuenta_bits   <= prox_cuenta_bits;
          cuenta_bits_d <= cuenta_bits;
          dato_leido <= prox_dato_leido;
        end
  end
end

always @(negedge SCK) begin
  if (!RESET) 
    begin
        if (MODE1 || MODE2) begin
          cuenta_bits   <= 0;
          cuenta_bits_d <= 0;
        end
    end 
  else 
  begin
      if (MODE1 || MODE2) begin
          cuenta_bits   <= prox_cuenta_bits;
          cuenta_bits_d <= cuenta_bits;
          dato_leido <= prox_dato_leido;
        end
  end
end

endmodule
