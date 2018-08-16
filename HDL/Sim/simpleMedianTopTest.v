///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: simpleMedianTopTest.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::IGLOO2> <Die::M2GL090T> <Package::484 FBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

`timescale 1ns/100ps

module simpleMedianTopTest();

parameter SYSCLK_PERIOD = 10;// 100MHZ

reg SYSCLK;
reg NSYSRESET;

initial
begin
    SYSCLK = 1'b0;
    NSYSRESET = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b0;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


reg writeMem;
reg dataIn;
reg start;
reg [7:0] xAddressIn;
reg [7:0] yAddressIn;
reg [12:0] threshold;

wire wakeUp;
//wire memDataOut;
//wire [7:0] addressInMemX;   //for PostSyn test
//wire [7:0] addressInMemY;   //for PostSyn test
wire [7:0] xAddressOutMedianMem;     
wire [7:0] yAddressOutMedianMem;     
//wire [11:0] activeWindows;  //for PostSyn test
wire writeMedianMem;
//wire fullImageDone;
wire writeMedianData;


//fifo signals
//wire [7:0] xAddressFIFO_10;
//assign xAddressFIFO_10 = DUT.xAddressFIFO[9];
//wire [7:0] yAddressFIFO_10;
//assign yAddressFIFO_10 = DUT.yAddressFIFO[9];
wire dataFIFO;
assign dataFIFO = DUT.dataFIFO[8];
wire [3:0] counter;
assign counter = DUT.counter;
//wire startCounter;
//assign startCounter = DUT.startCounter;


//Instantiation
simpleMedianTop DUT (
        .clk(SYSCLK),
        .reset(NSYSRESET),
        .writeMem(writeMem),
        .xAddressIn(xAddressIn),
        .yAddressIn(yAddressIn),
        .dataIn(dataIn),
        .wakeUp(wakeUp),
//        .addressInMemX(addressInMemX),              //for PostSyn test
//        .addressInMemY(addressInMemY),              //for PostSyn test
        .xAddressOutMedianMem(xAddressOutMedianMem),                  
        .yAddressOutMedianMem(yAddressOutMedianMem),                  
//        .activeWindows(activeWindows),              //for PostSyn test
        .start(start),
        .threshold(threshold),
        .writeMedianMem(writeMedianMem),
        .writeMedianData(writeMedianData)
);

//<statements>
integer i;
integer j;
initial begin
    #115 
    threshold = 50;
    writeMem = 1;
    start = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressIn = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressIn = j;
            dataIn = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end 
    #10
    writeMem = 0;
    //#5 NSYSRESET = 1;
    //#10 NSYSRESET = 0;
    #15
    start = 1;
end

endmodule

