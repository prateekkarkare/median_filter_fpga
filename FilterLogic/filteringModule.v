`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:28:46 09/03/2018 
// Design Name: 
// Module Name:    filteringModule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module filteringModule( 
	input clk, 
	input reset, 
	input dataIn, 
	input start,
	output [7:0] xAddressOut, 
	output [7:0] yAddressOut, 
	output reg [12:0] activeWindows,
	output filterDone,
	output filterReady,
	output reg medianDataOut
	);

//Parameters
localparam WINDOWSIZE = 3;
localparam WINDOWSTEP = 1;
localparam IMAGEWIDTH = 240;
localparam IMAGEHEIGHT = 180;
localparam MEDIANVALUE = 4;

reg [1:0] iCounter;
reg [1:0] jCounter;
reg [7:0] xAddressCntr;
reg [7:0] yAddressCntr;

parameter IDLE = 1'b0, FILTER = 1'b1;
localparam WINDOW_SIZE = 3;
localparam IMAGE_WIDTH = 240;
localparam IMAGE_HEIGHT = 180;

// Data sync registers
reg dataValid, dataValidSync;

// State registers
reg state, nextState;

// Status registers
reg iCounterDone, jCounterDone;
reg filterReady;
reg xAddressDone, yAddressDone;

// Assignments
assign xAddressOut = xAddressCntr + jCounter;
assign yAddressOut = yAddressCntr + iCounter;
assign filterDone = xAddressDone && yAddressDone;

always @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end
	else begin
		state <= nextState;
		dataValidSync <= !filterReady;
		dataValid <= dataValidSync;
	end
end

always @ (*) begin
	case (state)
		IDLE: begin 
			if (start) begin
				nextState <= FILTER;
			end
			else begin
				nextState <= IDLE;
			end
		end
		FILTER: begin
			if (xAddressDone && yAddressDone) begin
				nextState <= IDLE;
			end
			else begin
				nextState <= FILTER;
			end
		end
	endcase
end

always @ (posedge clk) begin
		case (state)
			IDLE: begin
				jCounter <= 0;
				iCounter <= 0;
				xAddressCntr <= 0;
				yAddressCntr <= 0;
//				filterDone <= 0;
				filterReady <= 1;
				medianDataOut <= 0;
				xAddressDone <= 0;
				yAddressDone <= 0;
			end
			FILTER: begin
				filterReady <= 0;
				if (jCounter == (WINDOW_SIZE - 1)) begin
					jCounter <= 0;
					jCounterDone <= 1;
				end
				else begin
					jCounterDone <= 0;
					jCounter <= jCounter + 1'b1;
				end
			end
		endcase
end

always @ (posedge jCounterDone) begin
	if (iCounter == (WINDOW_SIZE - 1)) begin
		iCounter <= 0;
		iCounterDone <= 1;
	end
	else begin
		iCounterDone <= 0;
		iCounter <= iCounter + 1'b1;
	end
end

always @ (posedge iCounterDone) begin
	if (xAddressCntr == IMAGE_WIDTH - WINDOW_SIZE) begin
		xAddressCntr <= 0;
		xAddressDone <= 1;
	end
	else begin
		xAddressDone <= 0;
		xAddressCntr <= xAddressCntr + 1'b1;	//Stride step = 1
	end
end

always @ (posedge xAddressDone) begin
	if (yAddressCntr == IMAGE_HEIGHT - WINDOW_SIZE) begin
		yAddressCntr <= 0;
		yAddressDone <= 1;
	end
	else begin
		yAddressCntr <= yAddressCntr + 1'b1;	//Stride step = 1
		yAddressDone <= 0;
	end
end

// Data Processing logic
reg [3:0] sum;
wire [3:0] sumWire; 
reg [3:0] pixelCounter;
reg pixelCounterDone;
reg [7:0] xMedianAddress;
reg [7:0] yMedianAddress;
reg [7:0] xMedianAddressOut;
reg [7:0] yMedianAddressOut;

reg write;

assign sumWire = sum + dataIn; 

always @ (posedge clk) begin
	xMedianAddressOut <= xMedianAddress;
	yMedianAddressOut <= yMedianAddress;
end

always @ (posedge clk) begin
	if (dataValid) begin
		if (pixelCounter == 8) begin
			pixelCounter <= 0;
			pixelCounterDone <= 1;
			sum <= 0;
			xMedianAddress <= xAddressCntr;
			yMedianAddress <= yAddressCntr;
			if (sumWire > 4) begin
				write <= 1;
			end
			else begin
				write <= 0;
			end
		end
		else begin
			pixelCounter <= pixelCounter + 1'b1;
			pixelCounterDone <= 0;
			sum <= sum + dataIn;
			xMedianAddress <= xMedianAddress;
			yMedianAddress <= yMedianAddress;
			write <= 0;
		end
	end
	else begin
		pixelCounter <= 0;
		sum <= 0;
		xMedianAddress <= 0;
		yMedianAddress <= 0;
		write <= 0;
	end
end

endmodule
