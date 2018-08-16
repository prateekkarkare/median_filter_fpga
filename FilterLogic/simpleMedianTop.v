///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: simpleMedianTop.v
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

module simpleMedianTop( clk, reset, writeMem, xAddressIn, yAddressIn, dataIn, start, wakeUp, threshold, xAddressOutMedianMem, yAddressOutMedianMem, writeMedianData, writeMedianMem);
                       // addressInMemX, addressInMemY, activeWindows );    //These signals are just for testing and won't be used in the final design
input clk, reset;
input dataIn;
input [7:0] xAddressIn;
input [7:0] yAddressIn;
input writeMem;
input start;
input [12:0] threshold;

output reg wakeUp;
//output [7:0] addressInMemX;             //Only for PostSynthTest
//output [7:0] addressInMemY;             //Only for PostSynthTest              
//output [11:0] activeWindows;            //Only for PostSynthTest
output writeMedianData;
output [7:0] xAddressOutMedianMem;
output [7:0] yAddressOutMedianMem;
output writeMedianMem;

//for median storage logic
wire memDataOut;
wire [7:0] addressInMemX;                    //Comment if doing post syn test
wire [7:0] addressInMemY;                    //Comment if doing post syn test
wire [12:0] activeWindows;                   //Comment if doing post syn test

wire [7:0] yAddressOut;               
wire [7:0] xAddressOut; 

reg [7:0] yAddressOutReg;               
reg [7:0] xAddressOutReg; 

assign addressInMemX = (writeMem)?xAddressIn:xAddressOut;
assign addressInMemY = (writeMem)?yAddressIn:yAddressOut;

//assign xAddressOutMedianMem = (writeMedianMem)?(xAddressOut):0;
//assign yAddressOutMedianMem = (writeMedianMem)?(yAddressOut):0;

assign xAddressOutMedianMem = (writeMedianMem)?(xAddressOutReg-1):0;
assign yAddressOutMedianMem = (writeMedianMem)?(yAddressOutReg-1):0;

assign writeMedianMem = medianDataOut;
assign writeMedianData = medianDataOut;

//Glue logic
always @ (posedge clk) begin
	if (reset) begin
		xAddressOutReg <= 0;
		yAddressOutReg <= 0;
	end
	else begin
		xAddressOutReg <= xAddressOut;
		yAddressOutReg <= yAddressOut;
	end
end

//Instantiations
//Memory module to store the image
flatMem flatMemInst (
        .clk(clk), 
        .reset(reset),
        .xAddressIn(addressInMemX),
        .yAddressIn(addressInMemY),
        .dataIn(dataIn), 
        .dataOut(memDataOut), 
        .write(writeMem)
);

//Main logic to read and compute median filtering
readImageV2 readImageInst ( 
        .clk(clk), 
        .reset(reset), 
        .xAddressOut(xAddressOut),
        .yAddressOut(yAddressOut), 
        .dataIn(memDataOut), 
        .activeWindows(activeWindows),
        .start(start),
        .fullImageDone(fullImageDone),
        .medianDataOut(medianDataOut)
);


//The number of active windows above which the FPGA should wake up
//13 bit wide register for threshold. Since the number fo windows is 4800 (maximum)

//Threshold comparator
always @ (posedge clk) begin
    if (reset) begin
        wakeUp <= 0;
    end
    else if ((activeWindows > threshold) && fullImageDone) begin
        wakeUp <= 1;
    end
    else begin
        wakeUp <= wakeUp;
    end
end

endmodule

