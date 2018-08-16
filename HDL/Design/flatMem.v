///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: flatMem.v
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

module flatMem( clk, reset, xAddressIn, yAddressIn, dataIn, dataOut, write );
input clk, reset;
input [7:0] xAddressIn;
input [7:0] yAddressIn;
input write;
input dataIn;
output reg dataOut;

localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

//Image RAM
reg imageArray [0:IMWIDTH*IMHEIGHT - 1];    // synthesis syn_ramstyle = rw_check
//reg [15:0] addressReg

wire [15:0] flatAddress;
assign flatAddress = yAddressIn*IMWIDTH + xAddressIn;   //Convert the x,y address to a 1D memaddress

integer i;
initial begin 
    for(i = 0; i < IMWIDTH*IMHEIGHT; i = i+1) begin
        imageArray[i] = 1'b0;
    end
end

always @ (posedge clk) begin
    if (write) begin
        imageArray[flatAddress] <= dataIn;
    end
    else begin
        dataOut <= imageArray[flatAddress];
    end
end

endmodule

