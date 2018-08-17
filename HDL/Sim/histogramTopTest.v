//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Mon Jul 30 15:22:09 2018
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: histogramTopTest.v
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

module histogramTopTest;

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
reg [7:0] xAddressIn;
reg [7:0] yAddressIn;
reg dataIn;
reg start;
reg [12:0] threshold;
reg readMedianImage;
reg readHistogram;

wire wakeUp;
wire fullImageDone;
wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;
wire xValid;
wire yValid;

//Internal Signals
wire [7:0] xAddressInMedianMem;
wire [7:0] yAddressInMedianMem;
wire [7:0] xAddressOutMedianMem;
wire [7:0] yAddressOutMedianMem;
wire writeMedianMem;
wire dataInMedianMem;
wire medianDataOut;

//Two level signals
wire [12:0] activeWindows;
assign activeWindows = DUT.simpleMedianTopINST.activeWindows;

wire memDataOut;
assign memDataOut = DUT.simpleMedianTopINST.flatMemInst.dataOut;

//Assign Internal signals
assign xAddressInMedianMem = DUT.xAddressInMedianMem;
assign yAddressInMedianMem = DUT.yAddressInMedianMem;
assign xAddressOutMedianMem = DUT.xAddressOutMedianMem;
assign yAddressOutMedianMem = DUT.yAddressOutMedianMem;
assign writeMedianMem = DUT.writeMedianMem;
assign dataInMedianMem = DUT.filteredImageMem.dataIn;
assign medianDataOut = DUT.medianDataOut;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  histogramTop
//////////////////////////////////////////////////////////////////////
histogramTop DUT (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .writeMem(writeMem),
    .xAddressIn(xAddressIn),
    .yAddressIn(yAddressIn),
    .dataIn(dataIn),
    .start(start),
    .threshold(threshold),
    .readMedianImage(readMedianImage),
	 .readHistogram(readHistogram),

    // Outputs
    .wakeUp(wakeUp),
	 .fullImageDone(fullImageDone),
	 .xHistogramOut(xHistogramOut),
	 .yHistogramOut(yHistogramOut),
	 .xValid(xValid),
	 .yValid(yValid)

    // Inouts

);


integer i;
integer j;
initial begin
    #115 
    readMedianImage = 0;
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
    start = 1;
end

initial begin
    #4244885
    start = 0;
    readMedianImage = 1;
	 readHistogram = 1;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressIn = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressIn = j;
            #(SYSCLK_PERIOD * 1);
        end
    end 
end


endmodule

