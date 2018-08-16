///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: readImageV2.v
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

module readImageV2( clk, reset, xAddressOut, yAddressOut, dataIn, start, activeWindows, fullImageDone, medianDataOut );
input clk, reset;
input start;
input dataIn;
//output reg [15:0] addressOut;
output reg [7:0] xAddressOut;
output reg [7:0] yAddressOut; 
output reg [12:0] activeWindows;
//output writeMedianMem;
output fullImageDone;
output medianDataOut;

//Parameters
localparam WINDOWSIZE = 3;
localparam WINDOWSTEP = WINDOWSIZE;
localparam IMAGEWIDTH = 240;
localparam IMAGEHEIGHT = 180;
localparam MEDIANVALUE = 4; // $floor(WINDOWSIZE*WINDOWSIZE/2);         
//<statements>

reg [15:0] rowOffset;
reg [1:0] windowColCount;
reg [1:0] windowRowCount;
reg [7:0] windowOffset;
reg [3:0] windowSum;

wire [3:0] windowSumWire;

//status registers
reg windowColDone, windowRowDone, windowDone, imageRowDone, fullImageDone, windowDoneReg;

assign windowSumWire = windowSum + dataIn;
//assign writeMedianMem = windowDone;
assign medianDataOut = (windowSumWire > MEDIANVALUE)?windowDoneReg:0;

initial begin
    windowColDone = 0;
    windowRowDone = 0;
    windowDone = 0;
    imageRowDone = 0;
    fullImageDone = 0;
    windowDoneReg = 0;
    rowOffset = 0;
    windowColCount = 0;
    windowRowCount = 0;
    windowOffset = 0;
    windowSum = 0;
end

always @ (posedge clk) begin
    if (reset) begin
        rowOffset <= 0;
        windowColCount <= 0;
        windowRowCount <= 0;
        windowOffset <= 0;
        windowSum <= 0;
        activeWindows <= 0;
        windowDoneReg <= 0;
    end
    else if (start) begin
        if (windowColCount == WINDOWSIZE - 1) begin
            windowColCount <= 0;
        end
        else begin 
            windowColCount <= (windowColCount + 1);                     //Counter to count number of columns in a window of interest (max 3 for a 3x3 window)
        end
    
        windowDoneReg <= windowDone;                                    //Register to determine that a single window computation is done
    
        if (windowColDone) begin
            if (rowOffset == IMAGEHEIGHT - 1) begin
                rowOffset <= 0;
            end
            else begin
                rowOffset <= (rowOffset + 1);                             //If iteration through the (3) columns of window is done then move to the next row of image
            end
            
            if (windowRowCount == WINDOWSIZE - 1) begin
                windowRowCount <= 0;
            end
            else begin
                windowRowCount <= (windowRowCount + 1);                  //Counter to count number of rows in a window of interest (max 3 for a 3x3 window)
            end            
        end
        else begin
            rowOffset <= rowOffset;
            windowOffset <= windowOffset;
        end

        if (imageRowDone) begin
            if (windowOffset == IMAGEWIDTH - WINDOWSTEP) begin
                windowOffset <= 0;
            end
            else begin
                windowOffset <= (windowOffset + WINDOWSTEP);       //windowOffset increases by 3 to move to the next window if window computation for all rows are done
            end
        end
        else begin
            windowOffset <= windowOffset;
        end

        if (windowOffset == (IMAGEWIDTH - WINDOWSIZE) && imageRowDone && windowDone) begin    //Median filter for the whole image is done
            fullImageDone <= 1;
        end
        else begin
            fullImageDone <= fullImageDone;
        end

        //Logic to count the number of active windows
        if (windowDoneReg) begin
            windowSum <= 0;
            if (windowSumWire > MEDIANVALUE) begin                                //WindowSumWire counts the number of active pixels in a window
                activeWindows <= activeWindows + 1;                     //TODO: parameterize the threshold for active pixels
            end
            else if (fullImageDone) begin
                activeWindows <= 0;
            end
            else begin
                activeWindows <= activeWindows;
            end
        end
        else begin
            windowSum <= windowSumWire;
        end

    end
    else begin
        rowOffset <= rowOffset;
        windowColCount <= windowColCount;
        windowRowCount <= windowRowCount;
        windowOffset <= windowOffset;
        activeWindows <= activeWindows;
        windowDoneReg <= windowDoneReg;
    end
end

//Combo logic to update status registers
//TODO: parameterize all the hardcoded values
always @ (*) begin
    xAddressOut = windowColCount + windowOffset;
    yAddressOut = rowOffset;
    //addressOut = rowOffset + windowColCount + windowOffset;

    if (windowColCount == (WINDOWSIZE-1)) begin
        windowColDone = 1;
    end
    else begin
        windowColDone = 0;
    end
    
    if (windowRowCount == (WINDOWSIZE-1)) begin
        windowRowDone = 1;
    end
    else begin
        windowRowDone = 0;
    end
    
    if (windowRowDone && windowColDone) begin
        windowDone = 1;
    end
    else begin
        windowDone = 0;
    end

    if (rowOffset == (IMAGEHEIGHT-1) && windowDone) begin
        imageRowDone = 1;
    end
    else begin
        imageRowDone = 0;
    end       
end

endmodule

