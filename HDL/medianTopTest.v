///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: medianTopTest.v
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

module medianTopTest();

parameter SYSCLK_PERIOD = 10;// 10MHZ

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
    #(SYSCLK_PERIOD * 1000 )
        NSYSRESET = 1'b1;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


reg start;
wire signed [7:0] xOut;
wire signed [7:0] yOut;

wire [7:0] xWindowCenter;
wire [7:0] yWindowCenter;
wire [7:0] xCenterReg;
wire [7:0] yCenterReg;
wire windowOut, imageDone, nextAddress, startWindowGet;

assign windowOut = DUT.windowOut;
assign imageDone = DUT.imageDone;
assign nextAddress = DUT.nextAddress;
assign startWindowGet = DUT.startWindowGet;
assign xWindowCenter = DUT.xWindowCenter;
assign yWindowCenter = DUT.yWindowCenter;

assign xCenterReg = DUT.xCenterReg;
assign yCenterReg = DUT.yCenterReg;


wire [1:0] currentState;
wire [1:0] nextState;
assign currentState = DUT.currentState;
assign nextState = DUT.nextState;

medianTop DUT( 
        .clk(SYSCLK),
        .reset(NSYSRESET),
        .start(start),
        .xWindowAddress(xOut),
        .yWindowAddress(yOut) 
);


//<statements>

initial begin
    #5 NSYSRESET = 1;
    #10 NSYSRESET = 0;
end

initial begin
    #25 start = 1;
end

endmodule

