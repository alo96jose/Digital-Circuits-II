/*
********************************************************
*** Universidad de Costa Rica.                       ***
*** Circuitos Digitales II - IE0523.                 ***
*** Proyecto Final: Bloque de PCS tipo 1000BASE-X.   ***
*** Fecha: 6 de julio de 2024.                       ***
*** Creadores: Alonso Jiménez Anchía. B63561.        ***
***            Daniela Ulloa Barboza. B77748.        ***
***            Paulette Pérez Monge. B95916.         ***
********************************************************

*** TESTER PCS ***

Descripción: En este archivo se genera un módulo de prueba llamado tester, el cual se encarga de determinar
los datos que se quieren enviar desde la etapa GMII para ser recibidos nuevamente a esta misma etapa;
también se agregan otros para demostrar el adecuado funcionamiento general del bloque PCS el cual recibe
datos solo si la señal TX_EN está activa y devuelve los mismos solo si en el receptor posee la señal 
TX_DV en alto.*/

// ** Inicio del código **

// Se define el módulo con sus puertos.
module tester (
    CLK, 
    RESET, 
    TX_EN_,
    TXD_); 

// Regs
output reg CLK, RESET, TX_EN_;
output reg [7:0] TXD_;


// Parametros
localparam K27_7 = 8'b11111011; // /S/
localparam D27_0 = 8'b00011011;
localparam D28_0 = 8'b00011100;
localparam D29_0 = 8'b00011101;
localparam D30_0 = 8'b00011110;
localparam D31_0 = 8'b00011111;
localparam D0_1  = 8'b00100000;
localparam D1_1  = 8'b00100001;
localparam D2_1  = 8'b00100010;
localparam D3_1  = 8'b00100011;
localparam D4_1  = 8'b00100100;

    
initial begin

  //Prueba 1: Modo0
    CLK = 0;
    RESET = 1;
    TX_EN_=0;
    TXD_= D27_0;
    #15 RESET=0;
    #10 RESET=1;
    
    // Enviamos 5 codigos de prueba al inicio
    #10 TXD_= D27_0;   
    #10 TXD_= D28_0;  
    #10 TXD_= D29_0;
    #10 TXD_= D30_0;
    #10 TXD_= D31_0;

    #10 TXD_= D27_0; // Enviamos datos

    #10 TXD_= K27_7; // /S/
        TX_EN_=1;
    #10 TXD_= D28_0; // 1C
    #10 TXD_= D29_0; // 1D
    #10 TXD_= D30_0; // 1E
    #10 TXD_= D31_0; // 1F
    #10 TXD_= D0_1;  // 20
    #10 TXD_= D1_1;  // 21
    #10 TXD_= D2_1;  // 22
    #10 TXD_= D3_1;  // 23
    #10 TXD_= D4_1;  // 24

    #10 TXD_= D0_1; // Terminamos con otros 5
        TX_EN_=0; 
    #10 TXD_= D1_1;
    #10 TXD_= D2_1;
    #10 TXD_= D3_1;
    #10 TXD_= D4_1;
    
  // Finaliza la simulacion
  #16000 $finish;

end

always begin
 #5 CLK = !CLK;  
end

endmodule
