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
		output filterReady,	
		output filterDone, 
		// ----------------------------------//
		
		// --- Binary Image mem interface --- //
		input dataIn,
		output [7:0] xAddressOut,
		output [7:0] yAddressOut,
		// --------------------------------- //
		
		// --- Median Memory Interface --- // 
		output [7:0] xMedianAddress,
		output [7:0] yMedianAddress,
		output writeEnable,
		output dataOut,
		// ------------------------------ //
		
		// ---- Histogram Interface ----- //
		input readHistogram,
		input clearHistogram,
		output [7:0] xHistogramOut, 
		output [7:0] yHistogramOut, 
		output xValid, 
		output yValid,
		output histogramClear,
		output ready
		// ------------------------------- //
		);

//<statements>
filteringModule filterInstance (
		.clk(clk), 
		.reset(reset), 
		.dataIn(dataIn), 
		.start(start),
		.xAddressOut(xAddressOut), 
		.yAddressOut(yAddressOut),
		.xMedianAddress(xMedianAddress),
		.yMedianAddress(yMedianAddress),
		.filterDone(filterDone),
		.filterReady(filterReady),
		.dataOut(dataOut),
		.writeEnable(writeEnable)
	);

computeHistogram computeHistogramInst( 
            .clk(clk), 
            .reset(reset),
            .xAddress(xMedianAddress),
            .yAddress(yMedianAddress),
            .pixelData(dataOut),
            .startHistogram(start),
				.stopHistogram(filterDone),
            .readHistogram(readHistogram), 
				.clearHistogram(clearHistogram),
            .xHistogramOut(xHistogramOut), 
            .yHistogramOut(yHistogramOut), 
            .xValid(xValid), 
            .yValid(yValid),
				.histogramClear(histogramClear),
				.ready(ready)
            );

endmodule

