///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: readImageV2Test.v
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

`timescale 1ns/100ps

module readImageV2Test();

parameter SYSCLK_PERIOD = 10;// 10MHZ

reg SYSCLK;
reg NSYSRESET;

initial
begin
    SYSCLK = 1'b0;
    NSYSRESET = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b1;
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b0;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


//wire [15:0] addressOut;
wire [7:0] xAddressOut;
wire [7:0] yAddressOut;

wire [15:0] rowOffset;
wire [7:0] windowOffset;
wire [1:0] windowColCount;
wire [1:0] windowRowCount;
wire windowRowDone;
wire windowColDone;
wire windowDone;
wire imageRowDone;
wire fullImageDone;
//wire writeMedianMem;
wire medianDataOut;

wire [3:0] windowSum;
wire [12:0] activeWindows;
wire windowDoneReg;
wire [3:0] windowSumWire;
assign windowDoneReg = DUT.windowDoneReg;

assign windowSum = DUT.windowSum;
assign windowSumWire = DUT.windowSumWire;
assign windowOffset = DUT.windowOffset;
assign imageRowDone = DUT.imageRowDone;
assign windowRowDone = DUT.windowRowDone;
assign windowColDone = DUT.windowColDone;
assign windowDone = DUT.windowDone;
assign rowOffset = DUT.rowOffset;
assign windowColCount = DUT.windowColCount;
assign windowRowCount = DUT.windowRowCount;

reg start;
reg dataIn;

readImageV2 DUT( 
        .clk(SYSCLK),
        .reset(NSYSRESET),
        //.addressOut(addressOut),
        .xAddressOut(xAddressOut),
        .yAddressOut(yAddressOut),
        .dataIn(dataIn),
        .activeWindows(activeWindows),
//        .writeMedianMem(writeMedianMem),
        .start(start),
        .fullImageDone(fullImageDone),
        .medianDataOut(medianDataOut)
);
//<statements>
always @ (posedge SYSCLK) begin
    dataIn = $random%2;
	 if (fullImageDone) begin
		start <= 0;
	 end
	 else begin
		start <= start;
	 end	
end

localparam WINDOWSIZE = 3;
localparam MEDIANVALUE = 4; //$floor(WINDOWSIZE*WINDOWSIZE/2);

initial begin
    $display("d=%0d", MEDIANVALUE);
    dataIn = 1'b0;
    start = 0;
    #35 start = 1;
	 #4000000 start = 1;
end

endmodule

