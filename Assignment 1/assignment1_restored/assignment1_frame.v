
module assignment1_frame(
	input        CLOCK_50,
	input        RESET_N,
	input  [3:0] KEY,
//	input  [9:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [9:0] LEDR
);

	
	
	wire clk;
	wire rst;

	wire [4:0] state_number;
		
	wire key0_triggered;
	wire key1_triggered;
	
	localparam blink_time_default = 32'd25000000;
	localparam blink_time_increment = 32'd12500000;
	localparam blink_time_min = 32'd12500000;
	localparam blink_time_max = 32'd100000000;

	reg reset_reg = 0;
	reg key0_reg = 0;
	reg key1_reg = 0;
	
	reg [9:0] ledr_out;
	reg [4:0] state;
	reg [31:0] timer;
	reg [31:0] blink_time;
	reg [3:0] speed_display;
	
	assign clk = CLOCK_50;
	assign rst = ~RESET_N;
	
	assign reset_triggered = ~RESET_N && ~reset_reg;
	assign key0_triggered = ~KEY[0] && ~key0_reg;
	assign key1_triggered = ~KEY[1] && ~key1_reg;
	
	// key0_triggered and key1_triggered signales works like an edge triggered signal 
	
	initial begin
		state = 0;
		ledr_out = 0;
		timer = 0;
		blink_time = blink_time_default;
		speed_display = 3'd2;
	end
	
	always@(posedge clk) begin
		reset_reg <= ~RESET_N;
		key0_reg <= ~KEY[0];
		key1_reg <= ~KEY[1];
	end
	
	always@(posedge clk)begin
		if (reset_triggered) begin
			state <= 0;
			ledr_out <= 0;
			timer <= 0;
			blink_time <= blink_time_default;
			speed_display <= 3'd2;
		end
		else if (key0_triggered && blink_time < blink_time_max) begin
			blink_time <= blink_time + blink_time_increment;
			speed_display <= speed_display + 1'd1;
		end
		else if (key1_triggered && blink_time > blink_time_min) begin
			blink_time <= blink_time - blink_time_increment;
			speed_display <= speed_display - 1'd1;
		end
		
		if (timer >= blink_time) begin
			if (state == 0 || state == 2 || state == 4 || state == 12 || state == 14 || state == 16) begin
				ledr_out<=10'b1111100000;
			end
			else if (state == 6 || state == 8 || state == 10 || state == 13 || state == 15 || state == 17) begin
				ledr_out<=10'b0000011111;
			end
			else if (state == 1 || state == 3 || state == 5 || state == 7 || state == 9 || state == 11) begin
				ledr_out<=10'b0;
			end
			timer<=32'd1;
			if (state == 17) begin
				state<=0;
			end
			else begin
				state<=state+1;
			end
		end
		else begin
			timer<=timer+1;
		end
	end

	assign LEDR=ledr_out;
	assign state_number=state;
		
	/* For debugging */
//	SevenSeg ss0(.IN(state_number[3:0]),.OFF(1'b0),.OUT(HEX0));
//	SevenSeg ss1(.IN(state_number[4:4]),.OFF(1'b0),.OUT(HEX1));
//	SevenSeg ss2(.IN(RESET_N),.OFF(1'b0),.OUT(HEX2));
	SevenSeg ss3(.IN(speed_display),.OFF(1'b0),.OUT(HEX3));
//	SevenSeg ss4(.IN(rst),.OFF(1'b0),.OUT(HEX4));
//	SevenSeg ss5(.IN(nrst),.OFF(1'b0),.OUT(HEX5));
	/*
	SevenSeg ss1(.IN(timer[31:28]),.OFF(1'b0),.OUT(HEX1));
	SevenSeg ss2(.IN(timer[27:24]),.OFF(1'b0),.OUT(HEX2));
	SevenSeg ss3(.IN(timer[23:20]),.OFF(1'b0),.OUT(HEX3));
	SevenSeg ss4(.IN(timer[19:16]),.OFF(1'b0),.OUT(HEX4));
	SevenSeg ss5(.IN(blink_reg),.OFF(1'b0),.OUT(HEX5));
	*/

	
endmodule