///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: simpleMedianTopTest.v
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

module simpleMedianTopTest();

parameter SYSCLK_PERIOD = 10;// 100MHZ

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
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b0;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;

reg start;
reg [12:0] threshold;
reg init;

wire memDataOut;
wire wakeUp;
wire [7:0] xAddressOut;     
wire [7:0] yAddressOut;     
//wire [11:0] activeWindows;  //for PostSyn test
wire writeMedianMem;
wire fullImageDone;
wire binaryMemWriteEnable;
wire wen;
wire writeMedianData;

//Instantiation
simpleMedianTop DUT (
			// Inputs
        .clk(SYSCLK),
        .reset(NSYSRESET),
        .binaryDataIn(memDataOut),                  
        .start(start),
		  .init(init),
        .threshold(threshold),
		  // Outputs
		  .wakeUp(wakeUp),
        .writeMedianMem(writeMedianMem),
        .writeMedianData(writeMedianData),
		  .fullImageDone(fullImageDone),
		  .xAddressOut(xAddressOut),                  
        .yAddressOut(yAddressOut),
		  .binaryMemWriteEnable(binaryMemWriteEnable)
);

// For Memory
reg dataIn;
wire [7:0] xMemAddressIn;
wire [7:0] yMemAddressIn;
reg [7:0] xAddressIn;
reg [7:0] yAddressIn;

// Glue logic
assign xMemAddressIn = (start)?xAddressOut:xAddressIn;
assign yMemAddressIn = (start)?yAddressOut:yAddressIn;
assign wen = (start)?binaryMemWriteEnable:1;

flatMem testMem (
	.clk(SYSCLK), 
	.reset(NSYSRESET),
	.xAddressIn(xMemAddressIn),
	.yAddressIn(yMemAddressIn), 
	.dataIn(dataIn), 
	.write(wen),
	.dataOut(memDataOut) 
	);

//<statements>
integer i;
integer j;
initial begin
	 init = 1;
    #115 
    threshold = 50;
    start = 0;
	 init = 0;
    for (i = 0; i < 240; i = i + 1) begin
        xAddressIn = i;
        for (j = 0; j < 180; j = j + 1) begin
            yAddressIn = j;
            dataIn = $random % 2;
            #(SYSCLK_PERIOD * 1);
        end
    end 
    #10
    start = 1;
end

initial begin
	#4244925 start = 0;
	#10 init = 1;
	#10 init = 0;
	#50 start = 1;
end

endmodule

