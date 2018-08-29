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

module histogramTop ( 
		input clk, 
		input reset, 
		input binaryDataIn, 
		input readHistogram,
		input start,
		input [12:0] threshold, 
				
		output wakeUp, 
		output fullImageDone, 
		
		// --- Binary Image mem interface --- //
		output [7:0] xAddressOut,
		output [7:0] yAddressOut,
		output binaryMemWriteEnable,
		// --------------------------------- //
		
		// --- Median Memory Interface --- // 
		output [7:0] xAddressOutFiltered,
		output [7:0] yAddressOutFiltered,
		output filteredMemWriteEnable,
		output medianData,
		// ------------------------------ //
		
		// ---- Histogram Out Interface --- //
		output [7:0] xHistogramOut, 
		output [7:0] yHistogramOut, 
		output xValid, 
		output yValid
		// ------------------------------- //
		);

wire [7:0] xAddressInMedianMem;
wire [7:0] yAddressInMedianMem;
wire [7:0] xAddressOut;
wire [7:0] yAddressOut;
wire filteredDataOut;
wire writeMedianMemInput;
wire writeMedianMem;

reg [7:0] xAddressInMedianMemReg;
reg [7:0] yAddressInMedianMemReg;

//These muxes control the input to the memory which stores the median filtered image
//1. Mux controlled by readMedianImage signal either lets the top level address in (by user) or the addressdriven by the internal logic
//2. following mux controls whether the address is to be subtracted or not (this is required to prevent invalid addresses) 
assign xAddressInMedianMem = (readMedianImage)?xAddressIn:(writeMedianMemInput)?(xAddressInMedianMemReg-8'b00000001):8'b0;
assign yAddressInMedianMem = (readMedianImage)?yAddressIn:(writeMedianMemInput)?(yAddressInMedianMemReg-8'b00000001):8'b0;
assign writeMedianMemInput = (readMedianImage)?1'b0:writeMedianMem;

always @(posedge clk) begin
    if (reset) begin
        xAddressInMedianMemReg <= 0;
        yAddressInMedianMemReg <= 0;
    end
    else begin
        xAddressInMedianMemReg <= xAddressOut; 
        yAddressInMedianMemReg <= yAddressOut;
    end
end

//<statements>
simpleMedianTop simpleMedianTopINST (
				// Inputs 
            .clk(clk), 
            .reset(reset),  
            .binaryDataIn(binaryDataIn), 
            .start(start),
				.threshold(threshold),
				// Outputs
				.binaryMemWriteEnable(binaryMemWriteEnable),
            .wakeUp(wakeUp),  
            .xAddressOut(xAddressOut), 
            .yAddressOut(yAddressOut), 
            .writeMedianMem(writeMedianMem),
            .writeMedianData(writeMedianData),
				.fullImageDone(fullImageDone)
            );

flatMem filteredImageMem (
            .clk(clk), 
            .reset(reset), 
            .xAddressIn(xAddressInMedianMem), 
            .yAddressIn(yAddressInMedianMem), 
            .dataIn(writeMedianData),                
            .dataOut(filteredDataOut), 
            .write(writeMedianMemInput)                  
            );


computeHistogram computeHistogramInst( 
            .clk(clk), 
            .reset(reset),
            .xAddress(xAddressInMedianMem),
            .yAddress(yAddressInMedianMem),
            .pixelData(writeMedianData),
            .startHistogram(start),
            .readHistogram(readHistogram), 
            .xHistogramOut(xHistogramOut), 
            .yHistogramOut(yHistogramOut), 
            .xValid(xValid), 
            .yValid(yValid) 
            );


endmodule

