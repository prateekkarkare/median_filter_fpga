//////////////////////////////////////////////////////////////////////
// Created by Microsemi SmartDesign Mon Jun 25 14:49:23 2018
// Testbench Template
// This is a basic testbench that instantiates your design with basic 
// clock and reset pins connected.  If your design has special
// clock/reset or testbench driver requirements then you should 
// copy this file and modify it. 
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: flatMemTest.v
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

module flatMemTest;

parameter SYSCLK_PERIOD = 10;// 100MHZ

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


wire dataOut;
reg [7:0] xAddressIn;
reg [7:0] yAddressIn;
reg write;
reg dataIn;

//wire [15:0] addressReg;
//assign addressReg = DUT.addressReg;

//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  flatMem
//////////////////////////////////////////////////////////////////////
flatMem DUT (
    // Inputs
    .clk(SYSCLK),
    .reset(NSYSRESET),
    .xAddressIn(xAddressIn),
    .yAddressIn(yAddressIn),
    .dataIn(dataIn),
    .write(write),

    // Outputs
    .dataOut(dataOut)

    // Inouts

);

integer i;
integer j;
localparam IMWIDTH = 240;
localparam IMHEIGHT = 180;

initial begin
    #115
        write = 1;
        for (i = 0; i < 240 ; i = i + 1) begin
            xAddressIn = i;
            for (j = 0; j < 180; j = j + 1) begin
                yAddressIn = j;
                dataIn = $random % 2;
                #(SYSCLK_PERIOD * 1);
            end
        end
        write = 0;
        #(SYSCLK_PERIOD * 1);
        for (i = 0; i < 240 ; i = i + 1) begin
            xAddressIn = i;
            for (j = 0; j < 180; j = j + 1) begin
                yAddressIn = j;
                #(SYSCLK_PERIOD * 1);
            end
        end
end

endmodule

