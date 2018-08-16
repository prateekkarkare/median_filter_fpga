///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: median_filter.v
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

module median_filter( clk, reset, startFilter, xAddress, yAddress, eventIn, eventout, write);
input clk, reset;
input eventIn;
input startFilter;
output eventOut;
output [7:0] xAddress;
output [7:0] yAddress;
output write;

//<statements>

initial begin
    active = 0;
end

//wire [2:0] bitSum;
//assign bitSum = windowIn[0] + windowIn[1] + windowIn[2] + windowIn[3] + windowIn[4] + windowIn[5] + windowIn[6] + windowIn[7] + windowIn[8];

reg [7:0] rowCounter;
reg [7:0] colCounter;


always @(posedge clk) begin
    if (reset) begin
        rowCounter <= 0;
        colCounter <= 0;
    end
    else if (incrementRow) begin
        rowCounter <= rowCounter + 1;
    end
end

always @ (posedge clk) begin
    if (reset) begin
        active <= 0;
    end else if (bitSum > 3'b100) begin
        active <= 1'b1;
    end else begin
        active <= 0;
    end
end



endmodule

