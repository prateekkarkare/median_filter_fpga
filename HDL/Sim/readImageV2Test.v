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

wire fullImageDone;
//wire writeMedianMem;
wire medianDataOut;


wire [12:0] activeWindows;
wire windowDoneReg;
assign windowDoneReg = DUT.windowDoneReg;
wire [3:0] windowSum;
assign windowSum = DUT.windowSum;
wire [3:0] windowSumWire;
assign windowSumWire = DUT.windowSumWire;
wire [7:0] windowOffset;
assign windowOffset = DUT.windowOffset;
wire imageRowDone;
assign imageRowDone = DUT.imageRowDone;
wire windowRowDone;
assign windowRowDone = DUT.windowRowDone;
wire windowColDone;
assign windowColDone = DUT.windowColDone;
wire windowDone;
assign windowDone = DUT.windowDone;
wire [15:0] rowOffset;
assign rowOffset = DUT.rowOffset;
wire [1:0] windowColCount;
assign windowColCount = DUT.windowColCount;
wire [1:0] windowRowCount;
assign windowRowCount = DUT.windowRowCount;
wire dataInSync1;
assign dataInSync1 = DUT.dataInSync1;
wire dataInSync2;
assign dataInSync2 = DUT.dataInSync2;


reg start;
reg dataIn;
reg init;

readImageV2 DUT( 
        .clk(SYSCLK),
        .reset(NSYSRESET),
		  .init(init),
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
		init <= 1;
	 end
	 else begin
		init <= 0;
	 end
end


localparam WINDOWSIZE = 3;
localparam MEDIANVALUE = 4; //$floor(WINDOWSIZE*WINDOWSIZE/2);

initial begin
    $display("d=%0d", MEDIANVALUE);
    dataIn = 0;
    start = 0;
	 init = 0;
    #35 start = 1;
end


endmodule

