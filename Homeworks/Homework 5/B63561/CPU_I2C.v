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
  localparam START     = 3'b000;
  localparam ESCRITURA = 3'b010;
  localparam LECTURA   = 3'b100;
  localparam STOP      = 3'b111;   
  localparam DIV_FREQ  = 2; // 25% del CLK

  // Variables intermedias
  reg [2:0] estado, prox_estado;
  reg [4:0] cuenta_bits, prox_cuenta_bits;
  reg [4:0] cuenta_bits_STOP, prox_cuenta_bits_STOP;
  reg [DIV_FREQ-1:0] div_freq;
  reg START_STB_d, START_STB_reg;
  wire iniciar, escritura, lectura;
  wire posedge_SCL;
  reg SCL_anterior, prox_SDA_OUT, SCL_reg, NXT_SDA_OE;
  reg SDA_OUT_anterior;
  reg ACK1, NXT_ACK1, ACK2, NXT_ACK2;
  reg START_CONDITION_ACTIVADA;
  reg BYTE1, NXT_BYTE1;
  reg NXT_posedge_SCL_1, posedge_SCL_1;
  reg NXT_posedge_SCL_2, posedge_SCL_2;

  // Condiciones de inicio y parada
  wire START_CONDITION;
  wire STOP_CONDITION;

  assign iniciar   = (transaccion[31:30] == 2'b01);
  assign escritura = (transaccion[29:28] == 2'b01);
  assign lectura = (transaccion[29:28] == 2'b10);

  // SCL es fraccion del CLK
  assign SCL = SCL_reg;

  assign posedge_SCL = !SCL_anterior && SCL;
  assign negedge_SDA_OUT = SDA_OUT_anterior && !SDA_OUT;
  assign posedge_SDA_OUT = !SDA_OUT_anterior && SDA_OUT;

  assign START_CONDITION = SCL && negedge_SDA_OUT;
  assign STOP_CONDITION  = SCL && posedge_SDA_OUT;

  // Flip flops
  always @(posedge CLK) begin
    if (!RESET) begin
      estado        <= INICIO;
      cuenta_bits   <= 0;
      cuenta_bits_STOP <= 0;
      div_freq      <= 0;
      SCL_anterior  <= 1;
      SDA_OUT_anterior <= 1;
      SDA_OUT       <= 1;
      SDA_OE        <= 0;
      START_STB_reg <= 0;
      START_STB_d   <= 0;
      ACK1 <= 0;
      ACK2 <= 0;
      BYTE1 <= 0;
    end else begin
      estado        <= prox_estado;
      cuenta_bits   <= prox_cuenta_bits;
      cuenta_bits_STOP <= prox_cuenta_bits_STOP;
      SDA_OE        <= NXT_SDA_OE;
      div_freq      <= div_freq+1;
      SCL_anterior  <= SCL;
      SDA_OUT_anterior <= SDA_OUT;
      SDA_OUT       <= prox_SDA_OUT;
      START_STB_reg <= START_STB;
      START_STB_d   <= START_STB_reg;
      ACK1          <= NXT_ACK1;
      posedge_SCL_1 <= NXT_posedge_SCL_1;
      posedge_SCL_2 <= NXT_posedge_SCL_2;
      ACK2          <= NXT_ACK2;
      BYTE1         <= NXT_BYTE1;
    end
  end

  //Logica combinacional

  always @(*) begin
    
    if (START_CONDITION || START_CONDITION_ACTIVADA)
      begin 
        START_CONDITION_ACTIVADA = 1;
        SCL_reg = div_freq[DIV_FREQ-1];
      end 
        else begin SCL_reg = 1'b1; end

    
    prox_estado = estado;
    prox_cuenta_bits = cuenta_bits;
    prox_cuenta_bits_STOP = cuenta_bits_STOP;
    prox_SDA_OUT = SDA_OUT;
    NXT_SDA_OE = SDA_OE;
    NXT_ACK1 = ACK1;
    NXT_posedge_SCL_1 = posedge_SCL_1;
    NXT_posedge_SCL_2 = posedge_SCL_2;
    NXT_ACK2 = ACK2;
    NXT_BYTE1 = BYTE1;


    case (estado)
	    INICIO: begin
		    NXT_SDA_OE = 1'b0;
        SDA_OUT = 1'b1;
		    prox_cuenta_bits = 0;
        NXT_posedge_SCL_1 = 0;
        RD_DATA = 0;
        
        if (START_STB) 
          begin
            prox_estado = START;
          end
        
	    end

      START: 
        begin
          prox_SDA_OUT = 0;
          if (RNW) prox_estado = LECTURA; 
          if (!RNW)  prox_estado = ESCRITURA;
        end

	    ESCRITURA: 
        begin
              if (!BYTE1) 
                begin 
                  NXT_SDA_OE = 1'b1;
                  if (posedge_SCL)
                    begin
                      prox_cuenta_bits = cuenta_bits+1;
                      prox_SDA_OUT = I2C_ADDR[6-cuenta_bits];
                      if (cuenta_bits == 7) 
                        begin  
                          prox_SDA_OUT = 0; 
                          prox_cuenta_bits = cuenta_bits+1;
                        end
                      if (cuenta_bits == 8) 
                        begin 
                          NXT_SDA_OE = 0; 
                          prox_SDA_OUT = 0; 
                          prox_cuenta_bits = 0;
                          NXT_BYTE1 = 1;
                        end
                      end
                end

              if (SDA_IN && BYTE1 && posedge_SCL) NXT_posedge_SCL_1 = 1;              // Pasa 1er posedge_SCL
              if (SDA_IN && BYTE1 && posedge_SCL_1 && !ACK1) prox_estado = STOP;      // No se recibio ACK1

              //if (SDA_IN && BYTE1 && posedge_SCL) NXT_posedge_SCL_1 = 1;              // Pasa 1er posedge_SCL
              //if (SDA_IN && BYTE1 && posedge_SCL_1 && !ACK1) NXT_posedge_SCL_2 = 1;   // No se recibio ACK1
              //if (SDA_IN && BYTE1 && posedge_SCL_2 && !ACK1) prox_estado = STOP; 

                                                                                      // Enviando Primer Byte
              if (!SDA_IN || ACK1 )  
                begin
                  if (cuenta_bits < 9)
                  begin
                    NXT_SDA_OE = 1'b1;
                    NXT_ACK1 = 1;
                    if (posedge_SCL) 
                    begin
                      prox_cuenta_bits = cuenta_bits+1;
                      prox_SDA_OUT = WR_DATA[15-cuenta_bits];
                      if (cuenta_bits == 8) NXT_SDA_OE = 0;
                    end
                  end
                end
                                                      // Enviando Segundo Byte
              if (!SDA_IN || ACK2)  
                begin
                  if (cuenta_bits > 8)
                    begin
                      NXT_SDA_OE = 1'b1;
                      NXT_ACK2 = 1;
                      if (posedge_SCL) 
                      begin
                        prox_cuenta_bits = cuenta_bits+1;
                        if (cuenta_bits < 16) prox_SDA_OUT = WR_DATA[15-cuenta_bits];
                      end
                    end
                end
              if (!SDA_IN) 
                begin 
                  if (cuenta_bits > 16) 
                    begin 
                      //prox_estado = STOP;
                      prox_SDA_OUT = 1;
                      SCL_reg = 1'b1;
                    end
                  if (STOP_CONDITION) prox_estado = STOP;
                end 
        end

	    LECTURA: 
        begin
          begin
              if (!BYTE1) 
                begin 
                  NXT_SDA_OE = 1'b1;
                  if (posedge_SCL)
                    begin
                      prox_cuenta_bits = cuenta_bits+1;
                      prox_SDA_OUT = I2C_ADDR[6-cuenta_bits];
                      if (cuenta_bits == 7) 
                        begin  
                          prox_SDA_OUT = 1; 
                          prox_cuenta_bits = cuenta_bits+1;
                        end
                      if (cuenta_bits == 8) 
                        begin 
                          NXT_SDA_OE = 0; 
                          prox_SDA_OUT = 0;
                          prox_cuenta_bits = 0;
                          NXT_BYTE1 = 1;
                        end
                      end
                end

              if (SDA_IN && BYTE1 && posedge_SCL) NXT_posedge_SCL_1 = 1;              // Pasa 1er posedge_SCL
              if (SDA_IN && BYTE1 && posedge_SCL_1 && !ACK1) prox_estado = STOP;      // No se recibio ACK1
              //if (SDA_IN && BYTE1 && posedge_SCL && !ACK1) prox_estado = STOP;      // No se recibio ACK1


                                                      // Recibo Primer Byte
              if (!SDA_IN || ACK1 )  
                begin
                  prox_SDA_OUT = 1;
                  if (posedge_SCL) NXT_ACK1 = 1;
                  if (ACK1 && cuenta_bits < 9)
                  begin
                    if (cuenta_bits == 8)
                      begin
                        NXT_SDA_OE = 1'b1;
                        prox_SDA_OUT = 0; 
                      end
                    if (posedge_SCL) 
                    begin
                      prox_cuenta_bits = cuenta_bits+1;
                      RD_DATA[15-cuenta_bits] = SDA_IN;
                    end
                  end

                end
                                                      // Recibo Segundo Byte
              if (!SDA_OUT || ACK2)  
                begin
                  if (cuenta_bits > 8)
                    begin
                      NXT_SDA_OE = 1'b0;
                      NXT_ACK2 = 1;
                      if (cuenta_bits < 15) prox_SDA_OUT = 1;
                      if (cuenta_bits > 16) prox_SDA_OUT = 0;
                      if (posedge_SCL) 
                        begin
                          //if (cuenta_bits > 15) prox_SDA_OUT = 0;
                          prox_cuenta_bits = cuenta_bits+1;
                          RD_DATA[15-cuenta_bits] = SDA_IN;
                        end
                    end
                end
              if (cuenta_bits > 16) 
                begin 
                  prox_estado = STOP;
                  SCL_reg = 1'b1;
                end
            end
        end

      STOP: 
        begin
          prox_cuenta_bits_STOP = cuenta_bits_STOP + 1;
          SCL_reg = 1'b1;
          START_CONDITION_ACTIVADA = 0;
          prox_SDA_OUT = 0;
          if (cuenta_bits_STOP == 3) begin 
            //prox_estado = INICIO; 
            prox_SDA_OUT = 1;
            prox_cuenta_bits_STOP = 0;
          end
          if (STOP_CONDITION) prox_estado = INICIO; 
        end 


      default: begin end
    endcase;
  end
endmodule
