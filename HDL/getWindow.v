///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: getWindow.v
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

module getWindow( clk, reset, xCenter, yCenter, startGet, xWindow, yWindow, windowOut);
input clk, reset;
input signed [7:0] xCenter; 
input signed [7:0] yCenter;
input startGet;
output reg signed [7:0] xWindow;
output reg signed [7:0] yWindow;
output reg windowOut;

//<statements>

reg nextState, currentState;

wire signed [1:0] xCount; 
wire signed [1:0] yCount;

windowCounter wCounter (
        .clk(clk),
        .reset(reset),
        .start(startGet),
        .countX(xCount),
        .countY(yCount),
        .windowValid(windowValid)
);

localparam IDLE = 1'b0;
localparam GETWINDOW = 1'b1;

always @ (posedge clk) begin
    if (reset) begin
        currentState <= IDLE;
    end
    else begin
        currentState <= nextState;
    end
end

always @ (posedge clk) begin
    case (currentState)
        IDLE: begin
            windowOut <= 0;
        end
        GETWINDOW: begin
            xWindow <= xCenter + xCount;
            yWindow <= yCenter + yCount;
            windowOut <= windowValid;
        end
    endcase
end

always @ (*) begin
    case (currentState)
        IDLE: begin
            if (startGet) begin
                nextState = GETWINDOW;
            end
            else begin
                nextState = IDLE;
            end
        end
        GETWINDOW: begin
            if (!windowValid) begin
                nextState = IDLE;
            end
            else begin
                nextState = GETWINDOW;
            end
        end
    endcase
end

endmodule

