///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: imageROM.v
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

module imageROM( xAddr, yAddr, eventIn, clk, write, eventOut );
input [7:0] xAddr;
input [7:0] yAddr;
input eventIn;
input clk;
input write;
output reg eventOut;

//<statements>
localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

reg imageArray [0:(IMWIDTH+2)*(IMHEIGHT+2) - 1];    // synthesis syn_ramstyle = rw_check
reg [15:0] addressReg;
wire [15:0] flattenedAddr;

assign flattenedAddr = yAddr*IMWIDTH + xAddr;

always @ (posedge clk) begin
    addressReg = flattenedAddr;
    if (write) begin
        imageArray[addressReg] <= eventIn;
    end
    else begin
        eventOut <= imageArray[addressReg];
    end
end

endmodule

