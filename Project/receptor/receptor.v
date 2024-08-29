module receptor(
    // Salidas
    output reg [7:0] RXD,
    output reg RX_DV, RUDI,

    // Entradas
    input CLK, RESET, SYNC_STATUS,
    input [10:0] SUDI
);

  // Estados
  localparam WAIT_FOR_K        = 6'b000001;
  localparam RX_K              = 6'b000010;
  localparam IDLE_D            = 6'b000100;
  localparam START_OF_PACKET   = 6'b001000;
  localparam RECEIVE           = 6'b010000;
  localparam TRI_RRI           = 6'b100000;

  // 8B/10B codificaciones con disparidad  Valor en HEX:
  localparam D27_0_n = 10'b1101100100;        // 1B
  localparam D27_0_p = 10'b0010011011;        // 1B
  localparam D28_0_n = 10'b0011101011;        // 1C
  localparam D28_0_p = 10'b0011100100;        // 1C
  localparam D29_0_n = 10'b1011100100;        // 1D
  localparam D29_0_p = 10'b0100011011;        // 1D
  localparam D30_0_n = 10'b0111100100;        // 1E
  localparam D30_0_p = 10'b1000011011;        // 1E
  localparam D31_0_n = 10'b1010110100;        // 1F 
  localparam D31_0_p = 10'b0101001011;        // 1F
  localparam D0_1_n  = 10'b1001111001;        // 20
  localparam D0_1_p  = 10'b0110001001;        // 20
  localparam D1_1_n  = 10'b0111011001;        // 21
  localparam D1_1_p  = 10'b1000101001;        // 21
  localparam D2_1_n  = 10'b1011011001;        // 22
  localparam D2_1_p  = 10'b0100101001;        // 22
  localparam D3_1    = 10'b1100011001;        // 23
  localparam D4_1_n  = 10'b1101011001;        // 24
  localparam D4_1_p  = 10'b0010101001;        // 24
  localparam D5_6    = 10'b1010010110;        // C5   Dato para IDLE, misma disparidad
  localparam D16_2_n = 10'b0110110101;        // 50   Dato para IDLE
  localparam D16_2_p = 10'b1001000101;        // 50   Dato para IDLE
  localparam K28_5_n = 10'b0011111010;        // BC
  localparam K28_5_p = 10'b1100000101;        // BC
  localparam K23_7_n = 10'b1110101000;        //      /R/ 
  localparam K23_7_p = 10'b0001010111;        //      /R/
  localparam K27_7_n = 10'b1101101000;        //      /S/
  localparam K27_7_p = 10'b0010010111;        //      /S/
  localparam K29_7_n = 10'b1011101000;        //      /T/
  localparam K29_7_p = 10'b0100010111;        //      /T/

  // Variables de estado
  reg [6:0] STATE, NXT_STATE;
  reg RD, NXT_RD; // Running disparity (RD): 0 para disparidad negativa, 1 para disparidad positiva
  reg receiving, NXT_receiving;
  reg NXT_RUDI;
  reg [7:0] NXT_RXD;
  reg NXT_RX_DV;
  reg check_end, NXT_check_end;
  reg [2:0] contador, NXT_contador;

  // Se extrae EVEN/ODD y rx_code_group de SUDI
  wire EVEN = SUDI[0];                             // EVEN ciclo par, !EVEN ciclo impar
  wire [9:0] rx_code_group = SUDI[10:1];

  // Generacion del CLK
  always @(posedge CLK) begin
    if (!RESET) begin
      STATE <= WAIT_FOR_K;
      RD <= 0;                                         // Se inicializa RD en negativo
      RXD <= 0;
      RX_DV <= 0;
      RUDI <= 0;
      receiving <= 0;
      check_end <= 0;
      contador <= 0;
    end else begin
      STATE <= NXT_STATE;
      RXD <= NXT_RXD;
      RUDI <= NXT_RUDI;
      RD <= NXT_RD;
      RX_DV <= NXT_RX_DV;
      receiving <= NXT_receiving;
      check_end <= NXT_check_end;
      contador <= NXT_contador;
    end
  end

  // Logica combinacional
  always @(*) begin
    // Valores por defecto
    NXT_STATE = STATE;
    NXT_RXD = RXD;
    NXT_RUDI = RUDI;
    NXT_RD = RD;
    NXT_RX_DV = RX_DV;
    NXT_receiving = receiving;
    NXT_check_end = check_end;
    NXT_contador = contador;

    case (STATE)
      WAIT_FOR_K: begin

      // Estado inicial donde se espera la primer coma en un ciclo par (/K28.5/*EVEN) para pasar 
      // al siguiente estado. Solo se pasa por el una vez.

            if (rx_code_group == K28_5_n || rx_code_group == K28_5_p) begin
              if (EVEN) NXT_STATE = RX_K;                                       // /K28.5/*EVEN 
              NXT_RD = (rx_code_group == K28_5_p);                              // Se actualiza RD
              NXT_RXD = 0;                                                      // Salida default RXD
              NXT_RX_DV = 0;                                                    // GMII no recibe /D/
              NXT_receiving = 0;                                                // receiving = FALSE

            end
      end

      RX_K: begin
        // 

        NXT_RXD = 0;
        if (rx_code_group == D5_6 || rx_code_group == D16_2_n || rx_code_group == D16_2_p) begin
          NXT_STATE = IDLE_D;
          NXT_RUDI = 1;
        end
      end

      IDLE_D: begin
        NXT_RXD = 0;
        if ((rx_code_group == K27_7_n || rx_code_group == K27_7_p) && SYNC_STATUS) begin // Sii /S/ y existe sincronizacion
          NXT_STATE = START_OF_PACKET;
          NXT_RX_DV = 1;
          NXT_RUDI = 0;
          NXT_receiving = 1;
          NXT_RXD = 8'b01010101;
          NXT_RD = (rx_code_group == K27_7_p);                                  // Se actualiza RD
        end 
        if (rx_code_group == K28_5_n || rx_code_group == K28_5_p) begin // if COMA
          NXT_RUDI = 0;
          NXT_STATE = RX_K;
        end
      end

      START_OF_PACKET: begin
        if (SYNC_STATUS) begin
          NXT_STATE = RECEIVE;
          NXT_RXD = DECODE(rx_code_group, RD); // 10b -> 8b
        end 
      end

      RECEIVE: begin
        // Codigo para condicion: EVEN * check_end = /T/R/K28.5/ 
        if (rx_code_group == K29_7_n || rx_code_group == K29_7_p) begin
          NXT_contador = 1;
          NXT_RX_DV = 0;
        end else if (contador == 1 && (rx_code_group == K23_7_n || rx_code_group == K23_7_p)) begin
          NXT_contador = 2;
        end else if (contador == 2 && (rx_code_group == K28_5_n || rx_code_group == K28_5_p)) begin
          NXT_check_end = 1;
        end else if (check_end) begin 
            NXT_receiving = 0;
            NXT_check_end = 0;
            NXT_RXD = 0;
            NXT_STATE = TRI_RRI;
            NXT_RD = actualizar_disparidad(rx_code_group, RD);
          end

        else begin
          if (rx_code_group != K29_7_p && rx_code_group != K29_7_n &&
              rx_code_group != K23_7_n && K23_7_p != K29_7_n && check_end==0
          ) begin 
            NXT_RXD = DECODE(rx_code_group, RD); // 10b -> 8b
            NXT_RX_DV = 1;
            NXT_STATE = RECEIVE;
            NXT_RD = actualizar_disparidad(rx_code_group, RD);
            end
        end

      end

      TRI_RRI: begin
        // Estado para terminar el paquete de la manera correcta
        if (rx_code_group == K28_5_n || rx_code_group == K28_5_p) begin   // SUDI[/K28.5/]
          NXT_STATE = RX_K; 
        end
      end

      default: begin end

    endcase
  end

  // Función para decodificar 10b a 8b
  function [7:0] DECODE(input [9:0] code_group, input disparidad);
    begin
      case (code_group)
        D27_0_n: DECODE = 8'b00011011;
        D27_0_p: DECODE = 8'b00011011;
        D28_0_n: DECODE = 8'b00011100;
        D28_0_p: DECODE = 8'b00011100;
        D29_0_n: DECODE = 8'b00011101;
        D29_0_p: DECODE = 8'b00011101;
        D30_0_n: DECODE = 8'b00011110;
        D30_0_p: DECODE = 8'b00011110;
        D31_0_n: DECODE = 8'b00011111;
        D31_0_p: DECODE = 8'b00011111;
        D0_1_n:  DECODE = 8'b00100000;
        D0_1_p:  DECODE = 8'b00100000;
        D1_1_n:  DECODE = 8'b00100001;
        D1_1_p:  DECODE = 8'b00100001;
        D2_1_n:  DECODE = 8'b00100010;
        D2_1_p:  DECODE = 8'b00100010;
        D3_1:    DECODE = 8'b00100011;
        D4_1_n:  DECODE = 8'b00100100;
        D4_1_p:  DECODE = 8'b00100100;
        D5_6:    DECODE = 8'b00100101;
        D16_2_n: DECODE = 8'b00101000;
        D16_2_p: DECODE = 8'b00101000;
        default: DECODE = 8'b11111111;
      endcase
      NXT_RD = actualizar_disparidad(code_group, disparidad);
    end
  endfunction

  // Funcion para actualizar la disparidad
  function actualizar_disparidad(input [9:0] code_group, input disparidad);
    begin
      // Se actualiza running disparidad (RD) según el code_group de 10b recibido
      case (code_group)
        K28_5_n, K28_5_p, D5_6: // Code_groups especiales que no requieren cambio en disparidad
          actualizar_disparidad = disparidad; // El retorno de la funcion se asigna a la funcion misma
        default:
          actualizar_disparidad = ~disparidad;
      endcase
    end
  endfunction

endmodule
