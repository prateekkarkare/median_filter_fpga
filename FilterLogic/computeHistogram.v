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
		input stopHistogram,
		output reg [7:0] xHistogramOut, 
		output reg [7:0] yHistogramOut, 
		output reg xValid, 
		output reg yValid,
		output reg histogramClear,
		output ready
		);
		
localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

// Register bank for histogram storage
reg [7:0] xHistogram[0:IMWIDTH-1];
reg [7:0] yHistogram[0:IMHEIGHT-1];

// Counters to read histogram
reg [7:0] xCounter;
reg [7:0] yCounter;

// Clear status
reg xClear;
reg yClear;

// Read Status
reg xDone;
reg yDone;
reg readDone;

// Compute status
reg ready;

// State registers
reg [1:0] state;
reg [1:0] nextState;

localparam IDLE = 2'b00, COMPUTE = 2'b01, CLEAR = 2'b10, READ = 2'b11;

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

always @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end
	else begin
		state <= nextState;
	end
end

//always @ (state or startHistogram or clearHistogram or readHistogram or stopHistogram or histogramClear or readDone) begin
always @ (*) begin
	case (state)
		IDLE: begin
			if (startHistogram) begin
				nextState <= COMPUTE;
			end
			else if (clearHistogram) begin
				nextState <= CLEAR;
			end
			else if (readHistogram) begin
				nextState <= READ;
			end
			else begin
				nextState <= IDLE;
			end
		end
		COMPUTE: begin
			if (stopHistogram) begin
				nextState <= IDLE;
			end
			else begin
				nextState <= COMPUTE;
			end
		end
		CLEAR: begin
			if (histogramClear) begin
				nextState <= IDLE;
			end
			else begin
				nextState <= CLEAR;
			end
		end
		READ: begin
			if (readDone) begin
				nextState <= IDLE;
			end
			else begin
				nextState <= READ;
			end
		end
	endcase
end

always @ (posedge clk) begin
	case (state)
		COMPUTE: begin
		    // Accumulate incoming pixel values for the corresponding addresses
			xHistogram[xAddress] <= xHistogram[xAddress] + pixelData;
			yHistogram[yAddress] <= yHistogram[yAddress] + pixelData;
			histogramClear <= 0;
			ready <= 0;
		end
		READ: begin
			// Start a counter for x histogram values
			if (xCounter == IMWIDTH - 1) begin
				xCounter <= xCounter;
                xValid <= 0;
				xDone <= 1;
			end
			else begin
                xCounter <= xCounter + 1;
                xValid <= 1;
				xDone <= xDone;
			end
			// Start a counter for y histogram values
			if (yCounter == IMHEIGHT - 1) begin
                yCounter <= yCounter;
                yValid <= 0;
				yDone <= 1;
			end
			else begin
                yCounter <= yCounter + 1;
                yValid <= 1;
				yDone <= yDone;
			end
			ready <= 0;
			readDone <= xDone && yDone;
			yHistogramOut <= yHistogram[yCounter];
			xHistogramOut <= xHistogram[xCounter];
		end
		CLEAR: begin
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
			ready <= 0;
			histogramClear <= xClear && yClear;
			yHistogram[yCounter] <= 0;
			xHistogram[xCounter] <= 0;
		end
		IDLE: begin
			xCounter <= 0;
			yCounter <= 0;
			xDone <= 0;
			yDone <= 0;
			histogramClear <= histogramClear;
			readDone <= 0;
			ready <= 1;
			xHistogramOut <= 0;
			yHistogramOut <= 0;
			xValid <= 0;
			yValid <= 0;
		end
	endcase
end

endmodule

