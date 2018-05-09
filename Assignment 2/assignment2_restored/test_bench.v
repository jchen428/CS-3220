`timescale 1ns/1ps
module test_bench();
reg CLOCK_50, RESET_N;
reg [3:0] KEY;
reg [9:0] SW;
wire [6:0] HEX0;
wire [6:0] HEX1;
wire [6:0] HEX2;
wire [6:0] HEX3;
wire [6:0] HEX4;
wire [6:0] HEX5;
wire [9:0] LEDR;

Project project_test(CLOCK_50, RESET_N, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

initial begin	
	CLOCK_50 = 0;
	RESET_N = 0;
	KEY = 0;
	SW = 0;
end

always#1 CLOCK_50 = ~CLOCK_50;

endmodule
