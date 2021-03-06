///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: computeHistgramTest.v
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

//`timescale <time_units> / <precision>

`timescale 1ns/100ps

module computeHistgramTest();

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

reg [7:0] xAddress;
reg [7:0] yAddress;
reg pixelData;
reg readHistogram;
reg startHistogram;
reg clearHistogram;
reg stopHistogram;

wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;
wire histogramClear;

wire xValid;
wire yValid;

/*
wire xClear;
wire yClear;
assign xClear = DUT.xClear;
assign yClear = DUT.yClear;

wire [7:0] xCounter;
wire [7:0] yCounter;
assign xCounter = DUT.xCounter;
assign yCounter = DUT.yCounter;

wire [1:0] state;
assign state = DUT.state;

wire readDone;
assign readDone = DUT.readDone;
wire xDone;
assign xDone = DUT.xDone;
wire yDone;
assign yDone = DUT.yDone;
*/
//Internal signals
//wire [7:0] xHistogram_0;
//assign xHistogram_0 = DUT.xHistogram[0];
//wire [7:0] xHistogram_1;
//assign xHistogram_1 = DUT.xHistogram[1];
//wire [7:0] xHistogram_2;
//assign xHistogram_2 = DUT.xHistogram[2];
//wire [7:0] xCounter;
//assign xCounter = DUT.xCounter;
//wire [7:0] yCounter;
//assign yCounter = DUT.yCounter;

computeHistogram DUT ( 
        .clk(SYSCLK),
        .reset(NSYSRESET), 
        .xAddress(xAddress), 
        .yAddress(yAddress),
        .pixelData(pixelData), 
        .startHistogram(startHistogram),
		  .clearHistogram(clearHistogram),
        .readHistogram(readHistogram),
		  .stopHistogram(stopHistogram),
        .xHistogramOut(xHistogramOut),
        .yHistogramOut(yHistogramOut),
        .xValid(xValid),
        .yValid(yValid),
		  .histogramClear(histogramClear)
        );

//<statements>
integer i;
integer j;

initial begin
	 clearHistogram = 0;
    #125
    startHistogram = 1;
	 #10
	 startHistogram = 0;
    readHistogram = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddress = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddress = j;
            pixelData = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end
	 stopHistogram = 1;
	 #20
	 stopHistogram = 0;
	 #10
	 readHistogram = 1;
	 #10
	 readHistogram = 0;
end

initial begin
	#434645
	clearHistogram = 1;
	#10
	clearHistogram = 0;
end

initial begin
	#437100
	readHistogram = 1;
	#10
	readHistogram = 0;
end

initial begin
#439565
    startHistogram = 1;
	 #10
	 startHistogram = 0;
    readHistogram = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddress = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddress = j;
            pixelData = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end
end

endmodule

