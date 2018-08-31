///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: computeHistogram.v
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

module computeHistogram ( 
		input clk, 
		input reset, 
		input [7:0] xAddress, 
		input [7:0] yAddress, 
		input pixelData, 
		input startHistogram, 
		input readHistogram, 
		input clearHistogram,
		output reg [7:0] xHistogramOut, 
		output reg [7:0] yHistogramOut, 
		output reg xValid, 
		output reg yValid,
		output histogramClear
		);
		
localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

reg [7:0] xHistogram[0:IMWIDTH-1];
reg [7:0] yHistogram[0:IMHEIGHT-1];

reg [7:0] xCounter;
reg [7:0] yCounter;

reg xClear;
reg yClear;

assign histogramClear = xClear && yClear;

integer i;
integer j;
initial begin
    for (i = 0; i < IMWIDTH; i = i + 1) begin
        xHistogram[i] = 0;
    end
    for (j = 0; j < IMHEIGHT; j = j + 1) begin
        yHistogram[j] = 0;
    end
end
//<statements>
always @ (posedge clk) begin
    if (reset) begin
        xCounter <= 0;
        yCounter <= 0;
        xValid <= 0;
        yValid <= 0;
    end
    else if (startHistogram) begin
        xHistogram[xAddress] <= xHistogram[xAddress] + pixelData;
        yHistogram[yAddress] <= yHistogram[yAddress] + pixelData;
    end
    else begin
        xHistogram[xAddress] <= xHistogram[xAddress];
        yHistogram[yAddress] <= yHistogram[yAddress];
    end

    if (readHistogram) begin
        if (xCounter == IMWIDTH - 1) begin
            xCounter <= xCounter;
            xValid <= 0;
        end
        else begin
            xCounter <= xCounter + 1;
            xValid <= 1;
        end

        if (yCounter == IMHEIGHT - 1) begin
            yCounter <= yCounter;
            yValid <= 0;
        end
        else begin
            yCounter <= yCounter + 1;
            yValid <= 1;
        end

        yHistogramOut <= yHistogram[yCounter];
        xHistogramOut <= xHistogram[xCounter];
    end
	 else if (clearHistogram) begin
		  if (xCounter == IMWIDTH - 1) begin
				xCounter <= xCounter;
				xClear <= 1;
        end
        else begin
            xCounter <= xCounter + 1;
				xClear <= 0;
        end
		  
		  if (yCounter == IMHEIGHT - 1) begin
            yCounter <= yCounter;
				yClear <= 1;
        end
        else begin
            yCounter <= yCounter + 1;
				yClear <= 0;
        end
		  
		  yHistogram[yCounter] <= 0;
        xHistogram[xCounter] <= 0;
		  
	 end
    else begin
        xHistogramOut <= 0;
        yHistogramOut <= 0;
        xCounter <= 0;
        yCounter <= 0;
        xValid <= 0;
        yValid <= 0;
		  xClear <= 0;
		  yClear <= 0;
    end
end

endmodule

