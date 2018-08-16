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

wire [7:0] xHistogramOut;
wire [7:0] yHistogramOut;

wire xValid;
wire yValid;

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
        .readHistogram(readHistogram),
        .xHistogramOut(xHistogramOut),
        .yHistogramOut(yHistogramOut),
        .xValid(xValid),
        .yValid(yValid)
        );

//<statements>
integer i;
integer j;

initial begin
    #125
    startHistogram = 1;
    readHistogram = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddress = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddress = j;
            pixelData = $urandom % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end
end

initial begin
    #432135
    readHistogram = 1;
end

endmodule

