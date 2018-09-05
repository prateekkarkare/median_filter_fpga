`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:19:55 09/05/2018 
// Design Name: 
// Module Name:    medianProcess 
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
module medianProcess(
	input clk,
	input reset,
	input dataValid,
	input [7:0] xAddressIn,
	input [7:0] yAddressIn,
	input dataIn,
	output writeEnable,
	output [7:0] xMedianAddress,
	output [7:0] yMedianAddress,
	output dataOut
    );

// Data Processing logic
reg [3:0] sum;
wire [3:0] sumWire; 
reg [3:0] pixelCounter;
reg [7:0] xMedianAddress;
reg [7:0] yMedianAddress;

// Sync registers for data and address Sync
reg [7:0] xAddressSync1;
reg [7:0] yAddressSync1;
reg [7:0] xAddressSync2;
reg [7:0] yAddressSync2;
reg [7:0] xAddressSync3;
reg [7:0] yAddressSync3;

reg writeEnable;
wire dataOut;

// Data out and write enable are same since the image is binary
assign dataOut = writeEnable;
assign sumWire = sum + dataIn; 

always @ (posedge clk) begin
	// Address Sync
	xAddressSync1 <= xAddressIn;
	yAddressSync1 <= yAddressIn;
	xAddressSync2 <= xAddressSync1;
	yAddressSync2 <= yAddressSync1;
	xAddressSync3 <= xAddressSync2;
	yAddressSync3 <= yAddressSync2;
	// Assign output address at every 9th data pixel (for 3x3 window)
	// Address is subtracted by 1 each since the Sync addresses are addresses of bottom right
	// pixel of the window
	if (pixelCounter == 8) begin
		xMedianAddress <= xAddressSync3 - 1'b1;
		yMedianAddress <= yAddressSync3 - 1'b1;
	end
	else begin
		xMedianAddress <= 0;
		yMedianAddress <= 0;
	end
end

always @ (posedge clk) begin
	if (dataValid) begin
		// Count 9 pixels (for 3x3 window) after data valid is asserted
		if (pixelCounter == 8) begin
			pixelCounter <= 0;
			sum <= 0;
			// If number of pixels in 3x3 window is greater than 4 then center pixel = 1
			if (sumWire > 4) begin
				writeEnable <= 1;
			end
			else begin
				writeEnable <= 0;
			end
		end
		else begin
			pixelCounter <= pixelCounter + 1'b1;
			sum <= sum + dataIn;
			writeEnable <= 0;
		end
	end
	else begin
		pixelCounter <= 0;
		sum <= 0;
		writeEnable <= 0;
	end
end

endmodule
