///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: windowCounter.v
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

module windowCounter( clk, reset, start, countX, countY, windowValid );
input clk, reset;
input start;
output reg signed [1:0] countX; 
output reg signed [1:0] countY;
output reg windowValid;

//<statements>
reg startReg;

always @ (posedge clk) begin
    if (reset) begin
        countX <= -1;
        countY <= -1;
        windowValid <= 0;
        startReg <= 0;
    end
    else if (start) begin
        startReg <= start;
        windowValid <= 1;
    end
    else begin
        countX <= -1;
        countY <= -1;
        windowValid <= 0;
        startReg <= 0;
    end
end

always @ (posedge clk) begin
    if (startReg) begin
        if (countX == 1) begin
            countX <= -1;
            if (countY == 1) begin
                windowValid <= 0;
                countY <= -1;
            end
            else begin
                countY <= countY + 1'b1;
                windowValid <= 1;
            end
        end
        else begin
            countX <= countX + 1'b1;
            windowValid <= 1;
        end
    end
    else begin
        countX <= -1;
        countY <= -1;
    end
end

endmodule

