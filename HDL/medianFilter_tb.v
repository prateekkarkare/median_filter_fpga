///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: medianFilter_tb.v
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

module medianFilter_tb();

reg [8:0] windowIn;
reg clk;
reg reset;
wire active;

wire [2:0] bitSum;

assign bitSum = dut.bitSum;

median_filter dut(
    .windowIn(windowIn),
    .clk(clk),
    .reset(reset),
    .active(active)
);

initial begin 
    clk = 0; 
    reset = 0; 
    windowIn = 9'b0;
    #600 $stop;
end 
 
always forever begin 
    #10  clk = ~clk;
end

always @ (posedge clk) begin
    windowIn = windowIn + 1;
end


endmodule

