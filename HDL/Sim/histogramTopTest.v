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

reg [7:0] xAddressIn;
reg [7:0] yAddressIn;
reg start;
reg [12:0] threshold;
reg readMedianImage;
reg readHistogram;

wire [7:0] xAddressOut;
wire [7:0] yAddressOut;
wire wakeUp;
wire fullImageDone;
wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;
wire xValid;
wire yValid;

//Internal Signals
wire [7:0] xAddressInMedianMem;
wire [7:0] yAddressInMedianMem;
wire writeMedianMem;
wire filteredDataOut;

wire binaryDataIn;
wire binaryMemWriteEnable;

//Two level signals
wire [12:0] activeWindows;
assign activeWindows = DUT.simpleMedianTopINST.activeWindows;

wire dataInMedianMem;
assign dataInMedianMem = DUT.filteredImageMem.dataIn;

//Assign Internal signals
assign xAddressInMedianMem = DUT.xAddressInMedianMem;
assign yAddressInMedianMem = DUT.yAddressInMedianMem;
assign writeMedianMem = DUT.writeMedianMem;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  histogramTop
//////////////////////////////////////////////////////////////////////
histogramTop DUT (
		// Inputs
		.clk(SYSCLK),
		.reset(NSYSRESET),
		.xAddressIn(xAddressIn),
		.yAddressIn(yAddressIn),
		.binaryDataIn(binaryDataIn),
		.start(start),
		.threshold(threshold),
		.readMedianImage(readMedianImage),
		.readHistogram(readHistogram),

		// Outputs
		.xAddressOut(xAddressOut),
		.yAddressOut(yAddressOut),
		.binaryMemWriteEnable(binaryMemWriteEnable),
		.wakeUp(wakeUp),
		.fullImageDone(fullImageDone),
		.xHistogramOut(xHistogramOut),
		.yHistogramOut(yHistogramOut),
		.xValid(xValid),
		.yValid(yValid),
		.filteredDataOut(filteredDataOut)
    );

// For Memory
reg dataIn;
wire [7:0] xMemAddressInBM;
wire [7:0] yMemAddressInBM;
reg [7:0] xAddressInBinary;
reg [7:0] yAddressInBinary;

// Glue logic
assign xMemAddressInBM = (start)?xAddressOut:xAddressInBinary;
assign yMemAddressInBM = (start)?yAddressOut:yAddressInBinary;

flatMem testMem (
	.clk(SYSCLK), 
	.reset(NSYSRESET),
	.xAddressIn(xMemAddressInBM),
	.yAddressIn(yMemAddressInBM), 
	.dataIn(dataIn), 
	.write(binaryMemWriteEnable),
	.dataOut(binaryDataIn) 
	);

integer i;
integer j;
initial begin
    #115 
    readMedianImage = 0;
    threshold = 50;
    start = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressInBinary = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressInBinary = j;
            dataIn = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end 
    #10
    start = 1;
end

initial begin
    #4244985
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

