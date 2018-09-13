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
module filteringModule #(parameter IMAGE_WIDTH = 240, parameter IMAGE_HEIGHT= 180, parameter WINDOW_STEP = 1, parameter WINDOW_SIZE = 3) ( 
	input clk, 
	input reset, 
	input dataIn, 
	input start,
	output [7:0] xAddressOut, 
	output [7:0] yAddressOut,
	output [7:0] xMedianAddress,
	output [7:0] yMedianAddress,
	output filterDone,
	output filterReady,
	output dataOut,
	output writeEnable
	);

function integer clog2;
    input integer value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1) begin
            value = value >> 1;
        end
    end
endfunction

localparam counterWidth = clog2(WINDOW_SIZE);

// i & j counters count inside a window
reg [counterWidth-1:0] iCounter;
reg [counterWidth-1:0] jCounter;
// Increments the addresses
reg [7:0] xAddressCntr;
reg [7:0] yAddressCntr;

localparam IDLE = 1'b0, FILTER = 1'b1;

// Data sync registers
reg dataValid, dataValidSync;

// State registers
reg state, nextState;

// Status registers
reg iCounterDone, jCounterDone;
reg filterReady;
reg xAddressDone, yAddressDone;

// Assignments
// Out address = pixel address + offset for window pixels
assign xAddressOut = xAddressCntr + jCounter;
assign yAddressOut = yAddressCntr + iCounter;
assign filterDone = xAddressDone && yAddressDone;

always @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end
	else begin
		state <= nextState;
		// To account for memory read latency
		dataValidSync <= !filterReady;
		dataValid <= dataValidSync;
	end
end

always @ (*) begin
	case (state)
		IDLE: begin 
			if (start) begin
				nextState = FILTER;
			end
			else begin
				nextState = IDLE;
			end
		end
		FILTER: begin
			if (xAddressDone && yAddressDone) begin
				nextState = IDLE;
			end
			else begin
				nextState = FILTER;
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
			filterReady <= 1;
			xAddressDone <= 0;
			yAddressDone <= 0;
		end
		FILTER: begin
			filterReady <= 0;
			if (jCounter == (WINDOW_SIZE - 1)) begin
				jCounter <= 0;
				if (iCounter == (WINDOW_SIZE - 1)) begin
					iCounter <= 0;
					if (xAddressCntr == (IMAGE_WIDTH - WINDOW_SIZE)) begin
						xAddressCntr <= 0;
						xAddressDone <= 1;
						if (yAddressCntr == (IMAGE_HEIGHT - WINDOW_SIZE)) begin
							yAddressCntr <= 0;
							yAddressDone <= 1;
						end
						else begin
							yAddressDone <= 0;
							yAddressCntr <= yAddressCntr + 1'b1;
						end
					end
					else begin
						xAddressDone <= 0;
						xAddressCntr <= xAddressCntr + 1'b1;
					end
				end
				else begin
					iCounter <= iCounter + 1'b1;
				end
			end
			else begin
				jCounter <= jCounter + 1'b1;
			end
		end
	endcase
end

// Connectors
wire [7:0] xMedianAddress;
wire [7:0] yMedianAddress;
wire writeEnable;
wire dataOut;

medianProcess #(WINDOW_SIZE) dataProcessInst (
	.clk(clk),
	.reset(reset),
	.dataValid(dataValid),
	.xAddressIn(xAddressOut),
	.yAddressIn(yAddressOut),
	.dataIn(dataIn),
	.writeEnable(writeEnable),
	.xMedianAddress(xMedianAddress),
	.yMedianAddress(yMedianAddress),
	.dataOut(dataOut)
	);

endmodule
