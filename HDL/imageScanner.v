///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: imageScanner.v
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

module imageScanner( clk, reset, nextAddress, xAddress, yAddress, imageDone );
input clk, reset;
input nextAddress;
output reg [7:0] xAddress;
output reg [7:0] yAddress;
output imageDone;

reg xDone;
reg yDone;

localparam XINITIAL = 1;       
localparam YINITIAL = 1;       
localparam IMAGEX = 240;    
localparam IMAGEY = 180;
localparam STEP = 3;

localparam NUMX = $floor((IMAGEX - XINITIAL)/STEP);
localparam NUMY = $floor((IMAGEY - YINITIAL)/STEP);
localparam XMAX = XINITIAL + NUMX*STEP;
localparam YMAX = YINITIAL + NUMY*STEP;


initial begin
    xAddress = XINITIAL;
    yAddress = YINITIAL;
end

//<statements>
reg increment;

assign imageDone = xDone && yDone;

always @ (posedge clk) begin
    if (reset) begin
        xAddress <= XINITIAL;
        yAddress <= YINITIAL;
        xDone <= 0;
        yDone <= 0;
        increment <= 0;
    end
    else if (nextAddress && !imageDone) begin
        increment <= nextAddress;
    end
    else begin
        xAddress <= xAddress;
        yAddress <= yAddress;
        increment <= 0;
    end
end

always @ (posedge clk) begin
    if (increment) begin
        xAddress <= (xAddress + STEP) % IMAGEX; //Count till IMAGEX 
        if (xDone) begin
            yAddress <= (yAddress + STEP) % IMAGEY; // Count IMAGEY 
        end
        else begin
            yAddress <= yAddress;
        end
    end
    else begin
        xAddress <= xAddress;
        yAddress <= yAddress;
    end
end

always @ (*) begin
    if (xAddress == XMAX && yAddress != YMAX) begin
        xDone = 1;
        yDone = 0;
    end
    else if (yAddress == YMAX && xAddress != XMAX) begin
        yDone = 1;
        xDone = 0;
    end
    else if (xAddress == XMAX && yAddress == YMAX) begin
        xDone = 1;
        yDone = 1;
    end
    else begin
        xDone = 0;
        yDone = 0;
    end
end

endmodule

