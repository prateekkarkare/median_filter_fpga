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
input writeMem;
input [7:0] xAddressIn;
input [7:0] yAddressIn;
input dataIn;
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

wire memDataOut;
wire [7:0] addressInMemX;                    //Uncomment if not doing post syn test
wire [7:0] addressInMemY;                    //Uncomment if not doing post syn test
wire [12:0] activeWindows;                   //Uncomment if not doing post syn test

wire [7:0] yAddressOut;               
wire [7:0] xAddressOut; 

assign addressInMemX = (writeMem)?xAddressIn:xAddressOut;
assign addressInMemY = (writeMem)?yAddressIn:yAddressOut;


//Address out to median memory will always be zero except when we need to write the memory
assign xAddressOutMedianMem = (writeMedianMem)?(xAddressOut-1):0;
assign xAddressOutMedianMem = (writeMedianMem)?(xAddressOut-1):0;
assign writeMedianMem = medianDataOut;

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

