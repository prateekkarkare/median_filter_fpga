`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   06:26:18 09/04/2018
// Design Name:   filteringModule
// Module Name:   /home/ise/Share/FilterLogic/filteringModuleTest.v
// Project Name:  FilterLogic
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: filteringModule
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module filteringModuleTest;

	// Inputs
	reg clk;
	reg reset;
	reg dataIn;
	reg start;
	reg init;

	// Outputs
	wire [7:0] xAddressOut;
	wire [7:0] yAddressOut;
	wire [12:0] activeWindows;
	wire filterDone;
	wire medianDataOut;
	wire filterReady;

	// Instantiate the Unit Under Test (UUT)
	filteringModule uut (
		.clk(clk), 
		.reset(reset), 
		.dataIn(dataIn), 
		.start(start), 
		.xAddressOut(xAddressOut), 
		.yAddressOut(yAddressOut), 
		.activeWindows(activeWindows), 
		.filterDone(filterDone), 
		.filterReady(filterReady),
		.medianDataOut(medianDataOut)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		dataIn = 0;
		start = 0;
		init = 0;

		// Wait 100 ns for global reset to finish
		#85;
        
		// Add stimulus here
		reset = 0;
		#15
		start = 1;
		#10
		start = 0;
		#3812950
		start = 1;
		#10
		start = 0;
	end
	
	always
		#5 clk = !clk;
		
		
	always @ (posedge clk) begin
		dataIn = $random % 2;
	end
	
// Internals
wire [7:0] xAddressCntr;
assign xAddressCntr = uut.xAddressCntr;
wire [7:0] yAddressCntr;
assign yAddressCntr = uut.yAddressCntr;
wire [7:0] xMedianAddressOut;
assign xMedianAddressOut = uut.xMedianAddressOut;
wire [7:0] yMedianAddressOut;
assign yMedianAddressOut = uut.yMedianAddressOut;
wire [7:0] xMedianAddress;
assign xMedianAddress = uut.xMedianAddress;
wire [7:0] yMedianAddress;
assign yMedianAddress = uut.yMedianAddress;
wire dataValid;
assign dataValid = uut.dataValid;
wire [3:0] sum;
assign sum = uut.sum;
wire [3:0] sumWire;
assign sumWire = uut.sumWire;
wire [3:0] pixelCounter;
assign pixelCounter = uut.pixelCounter;
wire write;
assign write = uut.write;

endmodule

