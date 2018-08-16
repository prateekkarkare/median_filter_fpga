//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Mon Jun 18 19:56:33 2018
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: windowCounterTest.v
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

module windowCounterTest;

parameter SYSCLK_PERIOD = 10;// 10MHZ

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
    #(SYSCLK_PERIOD * 100 )
        NSYSRESET = 1'b1;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;


reg start;
wire [1:0] countX;
wire [1:0] countY;
wire windowValid;
//
//wire [1:0] currentState;
//wire [1:0] nextState;
//
//wire xDone, yDone;
//assign xDone = windowCounter_0.xDone;
//assign yDone = windowCounter_0.yDone;
//assign currentState = windowCounter_0.currentState;
//assign nextState = windowCounter_0.nextState;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  windowCounter
//////////////////////////////////////////////////////////////////////
windowCounter windowCounter_0 (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .start(start),

    // Outputs
    .countX(countX),
    .countY(countY),
    .windowValid(windowValid)
    // Inouts

);

initial begin
    start = 0;
end

initial begin
    #5 NSYSRESET = 1;
    #15 NSYSRESET = 0;
    #15 start <= 1;
    #90 start <= 0;
    #10  start <= 1;
end
endmodule

