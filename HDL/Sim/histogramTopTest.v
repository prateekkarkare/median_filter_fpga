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

// Filtering module
reg start;
wire filterDone;
wire filterReady;

// Binary mem interface
wire binaryDataIn;
wire [7:0] xAddressOut;
wire [7:0] yAddressOut;

//Median memory interface
wire [7:0] xMedianAddress; 
wire [7:0] yMedianAddress;
wire writeEnable;

// Histogram Signlas
reg readHistogram;
reg clearHistogram;
wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;
wire xValid;
wire yValid;
wire histogramClear;
wire ready;

//Internal Signals
wire [1:0] state;
assign state = DUT.computeHistogramInst.state;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  histogramTop
//////////////////////////////////////////////////////////////////////
histogramTop DUT (
		// Inputs
		.clk(SYSCLK),
		.reset(NSYSRESET),
		// Filtering Module signals
		.start(start),
		.filterDone(filterDone),
		.filterReady(filterReady),
		// Binary Image Mem Interface
		.dataIn(binaryDataIn),
		.xAddressOut(xAddressOut),
		.yAddressOut(yAddressOut),
		//Filtered Image Mem interface
		.xMedianAddress(xMedianAddress),
		.yMedianAddress(yMedianAddress),
		.writeEnable(writeEnable),
		.dataOut(dataOut),
		// Histogram Interface
		.readHistogram(readHistogram),
		.clearHistogram(clearHistogram),
		.xHistogramOut(xHistogramOut),
		.yHistogramOut(yHistogramOut),
		.xValid(xValid),
		.yValid(yValid),
		.histogramClear(histogramClear),
		.ready(ready)
    );

// For filtered image memory
wire dataOut;
wire [7:0] xAddressInMM;
wire [7:0] yAddressInMM;
reg [7:0] xAddressInMedian;
reg [7:0] yAddressInMedian;
reg readMedianMem;

assign xAddressInMM = (readMedianMem)?xAddressInMedian:xMedianAddress;
assign yAddressInMM = (readMedianMem)?yAddressInMedian:xMedianAddress;

flatMem testMemFiltered (
	.clk(SYSCLK), 
	.reset(NSYSRESET),
	.xAddressIn(xAddressInMM),
	.yAddressIn(yAddressInMM), 
	.dataIn(dataOut), 
	.write(writeEnable),
	.dataOut(medianDataOut) 
	);

// For Binary Image Memory
reg dataIn;
wire [7:0] xMemAddressInBM;
wire [7:0] yMemAddressInBM;
reg [7:0] xAddressInBinary;
reg [7:0] yAddressInBinary;
wire wen;

// Glue logic
assign xMemAddressInBM = (!filterReady)?xAddressOut:xAddressInBinary;
assign yMemAddressInBM = (!filterReady)?yAddressOut:yAddressInBinary;
assign wen = filterReady;

flatMem testMem (
	.clk(SYSCLK), 
	.reset(NSYSRESET),
	.xAddressIn(xMemAddressInBM),
	.yAddressIn(yMemAddressInBM), 
	.dataIn(dataIn), 
	.write(wen),
	.dataOut(binaryDataIn) 
	);

integer i;
integer j;
initial begin
    #115 
    readMedianMem = 0;
	 readHistogram = 0;
    start = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressInBinary = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressInBinary = j;
            dataIn = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end 
    #20
    start = 1;
	 #10 
	 start = 0;
end


initial begin
    #4244895
    start = 0;
    readMedianMem = 1;
	 #20
	 readHistogram = 1;
	 #10 
	 readHistogram = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressInMedian = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressInMedian = j;
            #(SYSCLK_PERIOD * 1);
        end
    end 
	
end


endmodule

