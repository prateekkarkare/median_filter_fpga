//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Thu Jun 14 15:01:38 2018
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: imageScannerTest.v
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

module imageScannerTest;

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
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
    #(SYSCLK_PERIOD * 1 )
        NSYSRESET = 1'b0;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


reg nextAddress;
wire [7:0] xAddress;
wire [7:0] yAddress;
wire imageDone;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  imageScanner
//////////////////////////////////////////////////////////////////////
imageScanner imageScanner_0 (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .nextAddress(nextAddress),

    // Outputs
    .xAddress(xAddress ),
    .yAddress(yAddress ),
    .imageDone(imageDone)

    // Inouts

);

initial begin
    #20.5 nextAddress = 1;
    #1 nextAddress = 0;
    #1 nextAddress = 1;
    #1 nextAddress = 0;
    #1 nextAddress = 1;
    #1 nextAddress = 0;
    #1 nextAddress = 1;
    #30 nextAddress = 0;
    #40 nextAddress = 1;
    #10 NSYSRESET = 1;
    #10 NSYSRESET = 0;
end

endmodule

