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
reg init;
reg [12:0] threshold;
wire wakeUp;
wire fullImageDone;

// Binary mem interface
wire binaryDataIn;
wire [7:0] xAddressOut;
wire [7:0] yAddressOut;
wire binaryMemWriteEnable;

//Median memory interface
wire [7:0] xAddressOutFiltered; 
wire [7:0] yAddressOutFiltered;
wire filteredMemWriteEnable;
wire medianData;

// Histogram Signlas
reg readHistogram;
wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;
wire xValid;
wire yValid;

//Internal Signals


//Two level signals
wire [12:0] activeWindows;
assign activeWindows = DUT.simpleMedianTopINST.activeWindows;


//Assign Internal signals


//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  histogramTop
//////////////////////////////////////////////////////////////////////
histogramTop DUT (
		// Inputs
		.clk(SYSCLK),
		.reset(NSYSRESET),
		// Filtering Module signals
		.start(start),
		.init(init),			
		.threshold(threshold),
		.wakeUp(wakeUp),
		.fullImageDone(fullImageDone),
		// Binary Image Mem Interface
		.binaryDataIn(binaryDataIn),
		.xAddressOut(xAddressOut),
		.yAddressOut(yAddressOut),
		.binaryMemWriteEnable(binaryMemWriteEnable),
		//Filtered Image Mem interface
		.xAddressOutFiltered(xAddressOutFiltered),
		.yAddressOutFiltered(yAddressOutFiltered),
		.filteredMemWriteEnable(filteredMemWriteEnable),
		.medianData(medianData),
		// Histogram Interface
		.readHistogram(readHistogram),
		.xHistogramOut(xHistogramOut),
		.yHistogramOut(yHistogramOut),
		.xValid(xValid),
		.yValid(yValid)
    );

// For filtered image memory
wire medianDataOut;
wire [7:0] xAddressInMM;
wire [7:0] yAddressInMM;
reg [7:0] xAddressInMedian;
reg [7:0] yAddressInMedian;
reg readMedianMem;

assign xAddressInMM = (readMedianMem)?xAddressInMedian:xAddressOutFiltered;
assign yAddressInMM = (readMedianMem)?yAddressInMedian:xAddressOutFiltered;

flatMem testMemFiltered (
	.clk(SYSCLK), 
	.reset(NSYSRESET),
	.xAddressIn(xAddressInMM),
	.yAddressIn(yAddressInMM), 
	.dataIn(medianData), 
	.write(filteredMemWriteEnable),
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
assign xMemAddressInBM = (start)?xAddressOut:xAddressInBinary;
assign yMemAddressInBM = (start)?yAddressOut:yAddressInBinary;
assign wen = (start)?binaryMemWriteEnable:1;

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
	 init = 1;
    #115 
	 init = 0;
    readMedianMem = 0;
	 readHistogram = 0;
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
#4244905 init = 1;
#10 init = 0;
end

initial begin
    #4244895
    start = 0;
    readMedianMem = 1;
	 readHistogram = 1;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressInMedian = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressInMedian = j;
            #(SYSCLK_PERIOD * 1);
        end
    end 
end


endmodule

