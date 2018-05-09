`timescale 1ns/1ps
module ProjectTest();

reg clk_t, reset;
reg [3:0] key;
reg [9:0] sw;
wire [6:0] hex0;
wire [6:0] hex1;
wire [6:0] hex2;
wire [6:0] hex3;
wire [6:0] hex4;
wire [6:0] hex5;
wire [9:0] ledr;

Project test(clk_t, reset, key, sw, hex0, hex1, hex2, hex3, hex4, hex5, ledr);

always
	#1 clk_t = ~clk_t;
	
endmodule
