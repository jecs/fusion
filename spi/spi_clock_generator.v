`default_nettype none

module spi_clock_generator(
	clock,
	reset,
	sclk,
	high_t,
	low_t
);

	input wire clock;
	input wire reset;
	
	output reg sclk = 1'b0;
	output reg high_t;
	output reg low_t;
	
	parameter PERIOD = 9'd256; // clock freq ~= 781kHz
	parameter HALF_PERIOD = PERIOD >> 1;
	
	parameter ONE = 9'd1;
	parameter ZERO = 9'd0;
	
	reg [8:0] count = 9'd0;
	
	always @(posedge clock) begin
		if(reset || low_t) begin
			count <= ZERO;
		end
		else begin
			count <= count + ONE;
		end
		
		if(reset || low_t) begin
			sclk <= 1'b0;
		end
		else if(high_t) begin
			sclk <= 1'b1;
		end
		else begin
			sclk <= sclk;
		end
		
	end
	
	always @(*) begin
		high_t = (count == HALF_PERIOD-ONE);
		low_t =  (count == PERIOD-ONE);
	end
endmodule
