//Paulette Pérez Monge- B95916
//Máquina de estados del transmisor OS
//controla el formato del paquete 
module transmisorOS(
    //input
    clk, mr_main_reset, TX_EN,
    //output
    tx_o_set
);
    input clk, mr_main_reset, TX_EN;
    output reg [4:0] tx_o_set;

    localparam R = 5'b00001;  
    localparam S = 5'b00010;
    localparam T = 5'b00100;
    localparam D = 5'b01000;
    localparam I = 5'b10000;

    localparam IDLE = 5'b00001;
    localparam START_OF_PACKET = 5'b00010;
    localparam END_OF_PACKET_NOEXT= 5'b00100;
    localparam EPD2_NOEXT= 5'b01000;
    localparam TX_DATA= 5'b10000;

    localparam K28_5 = 8'b10111100;
    localparam K23_7 = 8'b11110111; 
    localparam K27_7 = 8'b11111011; 
    localparam K29_7 = 8'b11111101; 
    localparam D5_6 = 8'b11000101;
    localparam D16_2 = 8'b01010000;

    reg [4:0] current_state_OS, next_state;

    //  logica de transiciòn de estado
    always @(posedge clk or posedge ~mr_main_reset) begin
        if (~mr_main_reset) begin
            current_state_OS <= IDLE;
        end else begin
            current_state_OS <= next_state;
        end
    end

    // logica de proximo estado
    always @(*) begin
        next_state=current_state_OS;
        case (current_state_OS)
            //es necesario?
            IDLE: begin 
                tx_o_set=I;
                if (TX_EN) next_state = START_OF_PACKET;
            end

            
            START_OF_PACKET: begin
                tx_o_set=S;
                if (TX_EN ) next_state = TX_DATA;
            end
            
            TX_DATA: begin //indica que se transmitira un dato y espera a que la otra màquina lo traduzca y lo envie
                tx_o_set=D;
                if (!TX_EN) next_state = END_OF_PACKET_NOEXT;
            end

            END_OF_PACKET_NOEXT: begin
                next_state = EPD2_NOEXT;
                tx_o_set=T;
            end
            
            EPD2_NOEXT: begin
                tx_o_set=R;
                next_state=IDLE;
            end
            
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end


endmodule