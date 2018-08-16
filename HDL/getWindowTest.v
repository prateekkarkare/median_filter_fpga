///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: getWindowTest.v
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

module getWindowTest();

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

reg [7:0] xCenter;
reg [7:0] yCenter;
reg startGet;
wire [7:0] xWindow;
wire [7:0] yWindow;
wire windowOut;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test
//////////////////////////////////////////////////////////////////////
getWindow DUT(
        .clk(SYSCLK),
        .reset(NSYSRESET),
        .xCenter(xCenter),
        .yCenter(yCenter),
        .startGet(startGet),
        .xWindow(xWindow),
        .yWindow(yWindow),
        .windowOut(windowOut)
);

wire CS, NS;
wire signed [1:0] xCount;
wire signed [1:0] yCount;

assign xCount = DUT.xCount;
assign yCount = DUT.yCount;

//assign startGetReg = DUT.startGetReg;
assign CS = DUT.currentState;
assign NS = DUT.nextState;



initial begin
    NSYSRESET = 1;
    #15;
    NSYSRESET = 0;
    xCenter = 30;
    yCenter = 30;
    startGet = 1;
end

initial begin
    #115;
    startGet = 0;
    xCenter = 33;
    yCenter = 33;
    #10;
    startGet = 1;
end


//<statements>

endmodule

