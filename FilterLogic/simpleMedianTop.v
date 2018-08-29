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

module simpleMedianTop( 
	input clk, 
	input reset, 
	input binaryDataIn, 
	input start, 
	input [12:0] threshold,
	
	output readBinaryMem, 
	output reg wakeUp, 
	output fullImageDone, 
	output [7:0] xAddressOutMedianMem, 
	output [7:0] yAddressOutMedianMem, 
	output writeMedianData, 
	output writeMedianMem
	);
   //output addressInMemX, 
	//output addressInMemY, 
	//output activeWindows );    //These signals are just for postSynth testing and won't be used in the final design

//for median storage logic
wire memDataOut;
wire [7:0] addressInMemX;                    //Comment if doing post syn test
wire [7:0] addressInMemY;                    //Comment if doing post syn test
wire [12:0] activeWindows;                   //Comment if doing post syn test

wire [7:0] yAddressOut;               
wire [7:0] xAddressOut; 

assign addressInMemX = (writeMem)?xAddressIn:xAddressOut;
assign addressInMemY = (writeMem)?yAddressIn:yAddressOut;

assign xAddressOutMedianMem = xAddressOut;
assign yAddressOutMedianMem = yAddressOut;
assign writeMedianMem = medianDataOut;
assign writeMedianData = medianDataOut;

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
        .dataIn(binaryDataIn), 
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

