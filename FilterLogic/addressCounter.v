`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:04 09/05/2018 
// Design Name: 
// Module Name:    addressCounter 
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
module addressCounter(
	input clk, 
	input reset, 
	input dataIn, 
	input start,
	output [7:0] xAddressOut, 
	output [7:0] yAddressOut,
	output filterDone,
	output reg filterReady
	);

reg state, nextState;

parameter IDLE = 1'b0, COUNT = 1'b1;

always @ (posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end
	else begin
		state <= nextState;
	end
end

always @ (*) begin
	case (state)
		IDLE: begin
			if (start) begin
				nextState <= COUNT;
			end
			else begin
				nextState <= IDLE;
			end
		end
		COUNT: begin
			if (countDone) begin
				nextState <= IDLE;
			end
			else begin
				nextState <= COUNT;
			end
		end
	endcase
end

always @ (posedge clk) begin
	case (state)
		IDLE: begin
			jCounter <= 0;
		end
		COUNT: begin
			if (jCounter == 2) begin
				jCounter <= 0;
				if (iCounter == 2) begin
					iCounter <= 0;
					if (xAddressCntr == 237) begin
						xAddressCntr <= 0;
						if (yAddressCntr == 177) begin
							yAddressCntr <= 0;
						end
						else begin
							yAddressCntr <= yAddressCntr + 1'b1;
						end
					end
					else begin
						xAddressCntr <= 1'b1;
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

endmodule
