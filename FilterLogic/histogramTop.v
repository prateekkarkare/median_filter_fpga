///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: histogramTop.v.v
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

module histogramTop( clk, reset, writeMem, xAddressIn, yAddressIn, dataIn, start, wakeUp, threshold, readMedianImage  );
input clk;
input reset;
input writeMem;
input [7:0] xAddressIn;
input [7:0] yAddressIn;
input dataIn;
input start;
input [12:0] threshold;
input readMedianImage;

output wakeUp;

wire [7:0] xAddressInMedianMem;
wire [7:0] yAddressInMedianMem;
wire [7:0] xAddressOutMedianMem;
wire [7:0] yAddressOutMedianMem;
//wire medianDataOut;
wire writeMedianMemInput;
wire writeMedianMem;

reg [7:0] xAddressInMedianMemReg;
reg [7:0] yAddressInMedianMemReg;

//These muxes control the input to the memory which stores the median filtered image
//1. Mux controlled by readMedianImage signal either lets the top level address in (by user) or the addressdriven by the internal logic
//2. following mux controls whether the address is to be subtracted or not (this is required to prevent invalid addresses) 
assign xAddressInMedianMem = (writeMedianMemInput)?(xAddressInMedianMemReg-1):xAddressInMedianMemReg;
assign yAddressInMedianMem = (writeMedianMemInput)?(yAddressInMedianMemReg-1):yAddressInMedianMemReg;
assign writeMedianMemInput = (!readMedianImage)?writeMedianMem:0;

//<statements>
simpleMedianTop simpleMedianTopINST (
            .clk(clk), 
            .reset(reset), 
            .writeMem(writeMem), 
            .xAddressIn(xAddressIn), 
            .yAddressIn(yAddressIn), 
            .dataIn(dataIn), 
            .start(start), 
            .wakeUp(wakeUp), 
            .threshold(threshold), 
            .xAddressOutMedianMem(xAddressOutMedianMem), 
            .yAddressOutMedianMem(yAddressOutMedianMem), 
            .writeMedianMem(writeMedianMem),
            .writeMedianData(writeMedianData)
            );

flatMem filteredImageMem (
            .clk(clk), 
            .reset(reset), 
            .xAddressIn(xAddressInMedianMem), 
            .yAddressIn(yAddressInMedianMem), 
            .dataIn(writeMedianData),                
            .dataOut(dataOut), 
            .write(writeMedianMemInput)                  
            );


computeHistogram computeHistogramInst( 
            .clk(clk), 
            .reset(reset),
            .xAddress(xAddressInMedianMem),
            .yAddress(yAddressInMedianMem),
            .pixelData(medianDataOut),
            .startHistogram(start),
            .readHistogram(readHistogram), 
            .xHistogramOut(xHistogramOut), 
            .yHistogramOut(yHistogramOut), 
            .xValid(xValid), 
            .yValid(yValid) 
            );

always @(posedge clk) begin
    if (reset) begin
        xAddressInMedianMemReg <= 0;
        yAddressInMedianMemReg <= 0;
    end
    else begin
        xAddressInMedianMemReg <= (readMedianImage)?xAddressIn:xAddressOutMedianMem; 
        yAddressInMedianMemReg <= (readMedianImage)?yAddressIn:yAddressOutMedianMem;
    end
end
endmodule

