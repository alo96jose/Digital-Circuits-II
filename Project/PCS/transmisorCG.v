//Paulette Pérez Monge- B95916
//Máquina de estados del transmisor CG
//traduce los codegroups de 8 bits a 10 bits
module transmisorCG(
    //input
    clk,mr_main_reset,tx_o_set, TXD,
    //output
    tx_code_group
);
    input clk, mr_main_reset;
    input [4:0] tx_o_set;
    input [7:0] TXD;
    output reg [9:0] tx_code_group;
    
    localparam R = 5'b00001;
    localparam S = 5'b00010;
    localparam T = 5'b00100;
    localparam D = 5'b01000;
    localparam I = 5'b10000;

    localparam GENERATE_CODE_GROUPS = 3'b001;
    localparam IDLE_I1B = 3'b010;
    localparam IDLE_I2B = 3'b100;
    

    localparam K28_5 = 8'b10111100;
    localparam K23_7 = 8'b11110111; //R
    localparam K27_7 = 8'b11111011; //S
    localparam K29_7 = 8'b11111101; //T
    localparam D5_6  = 8'b11000101;
    localparam D16_2 = 8'b01010000;

    localparam D27_0 = 8'b00011011;
    localparam D28_0 = 8'b00011100;
    localparam D29_0 = 8'b00011101;
    localparam D30_0 = 8'b00011110;
    localparam D31_0 = 8'b00011111;
    localparam D0_1 = 8'b00100000;
    localparam D1_1 = 8'b00100001;
    localparam D2_1 = 8'b00100010;
    localparam D3_1 = 8'b00100011;
    localparam D4_1 = 8'b00100100;

    reg [2:0] current_state_CG, next_state;
    reg tx_disparity, next_tx_disparity;
    reg tx_even, next_tx_even;

    
    always @(posedge clk or posedge ~mr_main_reset) begin
        if (~mr_main_reset) begin
            current_state_CG <= GENERATE_CODE_GROUPS;
            tx_disparity  <= 0;
            tx_even  <= 1; //pensando en los idle
        end else begin
            current_state_CG <= next_state;
            tx_disparity  <= next_tx_disparity;
            tx_even  <= next_tx_even;
        end
    end

    //logica de proximo estado
    always @(*) begin
        next_state=current_state_CG;
        next_tx_disparity=tx_disparity;
        next_tx_even = tx_even;
        
        case (current_state_CG)
            GENERATE_CODE_GROUPS: begin               
                if((tx_o_set==S)||(tx_o_set==T)||(tx_o_set==R)) begin
                    next_tx_even = ~tx_even;
                    if(tx_o_set==S) tx_code_group=ENCODE(TXD,tx_disparity);
                    else if (tx_o_set==T) tx_code_group=ENCODE(K29_7,tx_disparity);
                    else if(tx_o_set==R) begin
                        tx_code_group=ENCODE(K23_7,tx_disparity);
                        next_tx_even=1; //el siguiente paquete es idle, debe tener paridad positiva
                    end                         
                end

                else if (tx_o_set==I) begin
                    tx_code_group = ENCODE(K28_5,tx_disparity);
                    next_tx_even = 0; //para que estè listo en IDLE_I1B o IDLE_I2B
                    if (tx_disparity == 1) next_state = IDLE_I1B;
                    else next_state = IDLE_I2B;
                end            
                
                else if (tx_o_set==D) begin //ya no existe data go, se incorpora aquí
                    tx_code_group = ENCODE(TXD,tx_disparity);   
                    next_tx_even = ~tx_even;
                end   

                next_tx_disparity=DIS(tx_code_group);             
            end
            
            IDLE_I1B: begin
                tx_code_group = ENCODE(D5_6,tx_disparity);
                next_tx_disparity=DIS(tx_code_group);
                next_tx_even = ~tx_even; //sin importar que pase despuès el siguiente resultado tendrà que tener paridad contraria
                next_state = GENERATE_CODE_GROUPS;
            end

            IDLE_I2B: begin
                tx_code_group = ENCODE(D16_2,tx_disparity);
                next_tx_disparity=DIS(tx_code_group);
                next_tx_even = ~tx_even;
                next_state = GENERATE_CODE_GROUPS;
            end

            default: begin
                next_state = current_state_CG;
            end
        endcase
    end

    function DIS(input [9:0] tx_code_group);
        begin //si los últimos 4 bits del còdigo terminan con una cantidad dispar de 1s y 0s, la siguiente disparidad dependerà de estos
            if ((tx_code_group[3:0]==1)||(tx_code_group[3:0]==2)||(tx_code_group[3:0]==4)||(tx_code_group[3:0]==8)||(tx_code_group[3:0]==12)) DIS = 0; //disparidad negativa
                //disparidad positiva
                else if ((tx_code_group[3:0]==3)||(tx_code_group[3:0]==7)||(tx_code_group[3:0]==11)||(tx_code_group[3:0]==13)||(tx_code_group[3:0]==14)||(tx_code_group[3:0]==15)) DIS = 1;
                else begin //si la cantidad es igual, la disparidad dependerá de los primeros 6 bits
                    case (tx_code_group[9:4])
                        6'b000000: DIS = 0;
                        6'b000001: DIS = 0;
                        6'b000010: DIS = 0;
                        6'b000011: DIS = 0;
                        6'b000100: DIS = 0;
                        6'b000101: DIS = 0;
                        6'b000110: DIS = 0;
                        6'b001000: DIS = 0;
                        6'b001001: DIS = 0;
                        6'b001010: DIS = 0;
                        6'b001100: DIS = 0;
                        6'b001111: DIS = 1;
                        6'b010000: DIS = 0;
                        6'b010001: DIS = 0;
                        6'b010010: DIS = 0;
                        6'b010100: DIS = 0;
                        6'b010111: DIS = 1;
                        6'b011000: DIS = 0;
                        6'b011011: DIS = 1;
                        6'b011101: DIS = 1;
                        6'b011110: DIS = 1;
                        6'b011111: DIS = 1;
                        6'b100000: DIS = 0;
                        6'b100001: DIS = 0;
                        6'b100010: DIS = 0;
                        6'b100100: DIS = 0;
                        6'b100111: DIS = 1;
                        6'b101000: DIS = 0;
                        6'b101011: DIS = 1;
                        6'b101101: DIS = 1;
                        6'b101110: DIS = 1;
                        6'b101111: DIS = 1;
                        6'b110000: DIS = 0;
                        6'b110011: DIS = 1;
                        6'b110101: DIS = 1;
                        6'b110110: DIS = 1;
                        6'b110111: DIS = 1;
                        6'b111001: DIS = 1;
                        6'b111010: DIS = 1;
                        6'b111011: DIS = 1;
                        6'b111100: DIS = 1;
                        6'b111101: DIS = 1;
                        6'b111110: DIS = 1;
                        6'b111111: DIS = 1;
                        6'b000111: DIS = 1;
                        6'b111000: DIS = 0;
                        default: DIS = tx_disparity;
                    endcase
                end
        end
    endfunction

    function [9:0] ENCODE(input [7:0] TXD, input tx_disparity); //usando las tablas
        begin
            case (TXD)
                    D27_0:begin
                        if (tx_disparity==0) ENCODE = 10'b1101100100;
                        else ENCODE = 10'b0010011011;
                    end
                    D28_0:begin
                        if (tx_disparity==0) ENCODE = 10'b0011101011;
                        else ENCODE = 10'b0011100100;
                    end
                    D29_0:begin
                        if (tx_disparity==0) ENCODE = 10'b1011100100;
                        else ENCODE = 10'b0100011011;
                    end
                    D30_0:begin
                        if (tx_disparity==0) ENCODE = 10'b0111100100;
                        else ENCODE = 10'b1000011011;
                    end
                    D31_0:begin
                        if (tx_disparity==0) ENCODE = 10'b1010110100;
                        else ENCODE = 10'b0101001011;
                    end
                    D0_1:begin
                        if (tx_disparity==0) ENCODE = 10'b1001111001;
                        else ENCODE = 10'b0110001001;
                    end
                    D1_1:begin
                        if (tx_disparity==0) ENCODE = 10'b0111011001;
                        else ENCODE = 10'b1000101001;
                    end
                    D2_1:begin
                        if (tx_disparity==0) ENCODE = 10'b1011011001;
                        else ENCODE = 10'b0100101001;
                    end
                    D3_1:begin
                        if (tx_disparity==0) ENCODE = 10'b1100011001;
                        else ENCODE = 10'b1100011001;
                    end
                    D4_1: begin
                        if (tx_disparity==0) ENCODE = 10'b1101011001;
                        else ENCODE = 10'b0010101001;
                    end
                    K23_7:begin
                        if (tx_disparity==0) ENCODE = 10'b1110101000;
                        else ENCODE = 10'b0001010111;
                    end
                    K27_7:begin
                        if (tx_disparity==0) ENCODE = 10'b1101101000;
                        else ENCODE = 10'b0010010111;
                    end
                    K29_7:begin
                        if (tx_disparity==0) ENCODE = 10'b1011101000;
                        else ENCODE = 10'b0100010111;
                    end
                    D5_6:begin
                        if (tx_disparity==0) ENCODE = 10'b1010010110;
                        else ENCODE = 10'b1010010110;
                    end
                    D16_2:begin
                        if (tx_disparity==0) ENCODE = 10'b0110110101;
                        else ENCODE = 10'b1001000101;
                    end
                    K28_5:begin
                        if (tx_disparity==0) ENCODE = 10'b0011111010;
                        else ENCODE = 10'b1100000101;
                    end
                    default: ENCODE = 10'b0011111010;
                endcase
        end
    endfunction


endmodule