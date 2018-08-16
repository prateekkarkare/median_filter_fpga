//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Mon Jun 11 16:09:34 2018
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: ramTest.v
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

module ramTest;

parameter SYSCLK_PERIOD = 1;// 10MHZ

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
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b1;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


reg [7:0] xAddress;
reg [7:0] yAddress;
reg eventIn;
reg writeEnable;
wire pixelOut;


initial begin
    xAddress = 0;
    yAddress = 0;
    writeEnable = 0;
    eventIn = 0;
end

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  imageROM
//////////////////////////////////////////////////////////////////////
imageROM imageROM_0 (
    // Inputs
    .xAddr(xAddress),
    .yAddr(yAddress),
    .eventIn(eventIn),
    .clk(SYSCLK),
    .write(writeEnable),

    // Outputs
    .pixelValue(pixelOut)
);

localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

integer i;
integer j;


initial begin
    writeEnable = 1;
    #1.5;
    for (i = 0; i < IMWIDTH; i = i + 1) begin
        xAddress = xAddress + 1;
        #1;
        if (i%3 == 0) begin
            eventIn = 1;
        end
        else begin
            eventIn = 0;
        end
    end
    writeEnable = 0;
    xAddress = 0;
    for (i = 0; i < IMWIDTH; i = i + 1) begin
        xAddress = xAddress + 1;
        #1;
    end
end


endmodule

