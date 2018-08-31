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
		
		// ---- Filtering module signals --- //
		input start,
		input init,
		input [12:0] threshold, 				
		output wakeUp, 
		output fullImageDone, 
		// ----------------------------------//
		
		// --- Binary Image mem interface --- //
		input binaryDataIn,
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
		
		// ---- Histogram Interface ----- //
		input readHistogram,
		output [7:0] xHistogramOut, 
		output [7:0] yHistogramOut, 
		output xValid, 
		output yValid
		// ------------------------------- //
		);

reg [7:0] xAddressInMedianMemReg;
reg [7:0] yAddressInMedianMemReg;

// Mux controls whether the address is to be subtracted or nlot (this is required to prevent invalid addresses) 
assign xAddressOutFiltered = (filteredMemWriteEnable)?(xAddressInMedianMemReg-8'b00000001):8'b0;
assign yAddressOutFiltered = (filteredMemWriteEnable)?(yAddressInMedianMemReg-8'b00000001):8'b0;

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
				.init(init),
				.threshold(threshold),
				// Outputs
				.binaryMemWriteEnable(binaryMemWriteEnable),
            .wakeUp(wakeUp),  
            .xAddressOut(xAddressOut), 
            .yAddressOut(yAddressOut), 
            .writeMedianMem(filteredMemWriteEnable),
            .writeMedianData(medianData),
				.fullImageDone(fullImageDone)
            );

computeHistogram computeHistogramInst( 
            .clk(clk), 
            .reset(reset),
            .xAddress(xAddressOutFiltered),
            .yAddress(xAddressOutFiltered),
            .pixelData(medianData),
            .startHistogram(start),
            .readHistogram(readHistogram), 
            .xHistogramOut(xHistogramOut), 
            .yHistogramOut(yHistogramOut), 
            .xValid(xValid), 
            .yValid(yValid) 
            );


endmodule

