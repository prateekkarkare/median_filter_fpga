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

	// Outputs
	wire [7:0] xAddressOut;
	wire [7:0] yAddressOut;
	wire [7:0] xMedianAddress;
	wire [7:0] yMedianAddress;
	wire [12:0] activeWindows;
	wire filterDone;
	wire dataOut;
	wire filterReady;
	wire writeEnable;

	// Instantiate the Unit Under Test (UUT)
	filteringModule uut (
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

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		dataIn = 0;
		start = 0;

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
//wire [7:0] xAddressCntr;
//assign xAddressCntr = uut.xAddressCntr;
//wire [7:0] yAddressCntr;
//assign yAddressCntr = uut.yAddressCntr;
//wire [7:0] xMedianAddress;
//assign xMedianAddress = uut.xMedianAddress;
//wire [7:0] yMedianAddress;
//assign yMedianAddress = uut.yMedianAddress;
//wire dataValid;
//assign dataValid = uut.dataValid;
//wire [3:0] counter;
//assign counter = uut.dataProcessInst.pixelCounter;
//wire [3:0] sum;
//assign sum = uut.dataProcessInst.sum;
//wire [3:0] sumWire;
//assign sumWire = uut.dataProcessInst.sumWire;
//wire writeEnable;
//assign writeEnable = uut.writeEnable;

//wire [7:0] xSync;
//assign xSync = uut.dataProcessInst.xAddressSync1;
//wire [7:0] ySync;
//assign ySync = uut.dataProcessInst.yAddressSync1;

endmodule

