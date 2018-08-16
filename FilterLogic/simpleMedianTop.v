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
localparam FIFODEPTH = 10;                      //FIFO is depth 10 (not 9 which is appropriate for a window) because we need to delay the address to align with the data and data is already a cycle late due to memory read
localparam WINDOWSIZE = 9;
reg [7:0] xAddressFIFO[0:FIFODEPTH-1];                 
reg [7:0] yAddressFIFO[0:FIFODEPTH-1];
reg [FIFODEPTH-2:0] dataFIFO;                   //data fifo needs to be only of depth 9 to store a window of data

reg [3:0] counter;
reg startCounter;

wire memDataOut;
wire [7:0] addressInMemX;                    //Comment if doing post syn test
wire [7:0] addressInMemY;                    //Comment if doing post syn test
wire [12:0] activeWindows;                   //Comment if doing post syn test

wire [7:0] yAddressOut;               
wire [7:0] xAddressOut; 

assign addressInMemX = (writeMem)?xAddressIn:xAddressOut;
assign addressInMemY = (writeMem)?yAddressIn:yAddressOut;

assign writeMedianData = (counter == 4)?1:dataFIFO[8];
assign writeMedianMem = startCounter;
assign xAddressOutMedianMem = xAddressFIFO[9];
assign yAddressOutMedianMem = yAddressFIFO[9];

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

integer i;
initial begin
    for (i = 0; i < FIFODEPTH; i = i + 1) begin
        xAddressFIFO[i] = 0;
        yAddressFIFO[i] = 0;
        dataFIFO[i] = 0;
    end
end

integer k;
always @ (posedge clk) begin
    if (reset) begin
        startCounter <= 0;
        counter <= 0;
    end
    else if (start) begin
        xAddressFIFO[0] <= xAddressOut;
        yAddressFIFO[0] <= yAddressOut;
        dataFIFO <= {dataFIFO[FIFODEPTH-3:0], memDataOut};
        for(k = 1; k < FIFODEPTH; k = k + 1) begin
            xAddressFIFO[k] <= xAddressFIFO[k-1];
            yAddressFIFO[k] <= yAddressFIFO[k-1];
        end
        if (medianDataOut) begin
            if (counter == 8) begin
                startCounter <= 1;
                counter <= 0;
            end
            else begin
                startCounter <= 1;
            end
        end
        else begin
            if (counter == 8) begin
                counter <= 0;
                startCounter <= 0;
            end
            else begin
                startCounter <= startCounter;
            end
        end
        if (startCounter) begin
            counter <= (counter + 1) % 9;
        end
        else begin
            counter <= 0;
        end
    end
end


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

