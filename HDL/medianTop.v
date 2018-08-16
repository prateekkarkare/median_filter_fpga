///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: medianTop.v
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

module medianTop( clk, reset, start, xWindowAddress, yWindowAddress );
input clk, reset;
input start;
output signed [7:0] xWindowAddress;
output signed [7:0] yWindowAddress;

//Wires to connect different modules
wire [7:0] xWindowCenter;
wire [7:0] yWindowCenter;

reg startWindowGet;
reg nextAddress;
wire imageDone;
wire windowOut;

reg [7:0] xCenterReg;
reg [7:0] yCenterReg;

//Mux to control internal vs external control to image memory
//assign xMemAddress = (loadMem == 1) ? xAddressIn:xWindowAddress;
//assign yMemAddress = (loadMem == 1) ? yAddressIn:yWindowAddress;

//Instantiations
//imageROM imageMem(
        //.xAddr(xMemAddress),
        //.yAddr(yMemAddress),
        //.eventIn(eventIn),
        //.clk(clk),
        //.write(write),
        //.eventOut()
//);

getWindow getWindowModule(
        .clk(clk),
        .reset(reset),
        .xCenter(xCenterReg),
        .yCenter(yCenterReg),
        .startGet(startWindowGet),
        .xWindow(xWindowAddress),
        .yWindow(yWindowAddress),
        .windowOut(windowOut)
);

imageScanner imageScannerModule(
        .clk(clk),
        .reset(reset),
        .nextAddress(nextAddress),
        .xAddress(xWindowCenter),
        .yAddress(yWindowCenter),
        .imageDone(imageDone)
);

localparam IDLE = 2'b00;
localparam WAIT = 2'b10;
localparam INCR = 2'b01;

reg [1:0] currentState;
reg [1:0] nextState;

//<statements>
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
            nextAddress <= 0;
            startWindowGet <= 0;
        end
        INCR: begin
            nextAddress <= 1;
            startWindowGet <= 1;
            xCenterReg <= xWindowCenter;
            yCenterReg <= yWindowCenter;
        end
        WAIT: begin
            nextAddress <= 0;
            if (windowOut) begin
                startWindowGet <= 1;
            end
            else begin
                startWindowGet <= 0;
            end
        end
    endcase
end

always @ (*) begin
    case (currentState)
        IDLE: begin
            if (start) begin
                nextState = INCR;
            end
            else begin
                nextState = IDLE;
            end
        end
        INCR: begin
            if (imageDone) begin
                nextState = IDLE;
            end
            //else if (windowOut) begin
            //    nextState = WAIT;
           // end
            else begin
                nextState = WAIT;
            end
        end
        WAIT: begin
            if (!windowOut) begin
                nextState = INCR;
            end
            else begin
                nextState = WAIT;
            end
        end
    endcase
end



endmodule

