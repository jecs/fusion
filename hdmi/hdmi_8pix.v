`include "hdmi.h"

`default_nettype none

module hdmi_8pix(
	clock,
	reset,
	hs_in,
	vs_in,
	de_in,
	x,
	y,
	hs_out,
	vs_out,
	de_out,
	data_out,
	addr,
	data_in
);

	input wire clock;
	input wire reset;
	input wire hs_in;
	input wire vs_in;
	input wire de_in;
	input wire [`HBW-1:0] x;
	input wire [`VBW-1:0] y;
	output reg hs_out;
	output reg vs_out;
	output reg de_out;
	output reg [`PBW-1:0] data_out;
	output reg [18:0] addr;
	input wire [63:0] data_in;

	reg [7:0] intensity;
	reg [2:0] pixel = 3'd0;

	always @(posedge clock) begin
		hs_out <= hs_in;
		vs_out <= vs_out;
		de_out <= de_in;
		pixel <= x[2:0];
	end

	always @(*) begin
		addr = y*240+x[`HBW-1:3];
		case(pixel)
			3'd0: intensity = data_in[63:56];
			3'd1: intensity = data_in[55:48];
			3'd2: intensity = data_in[47:40];
			3'd3: intensity = data_in[39:32];
			3'd4: intensity = data_in[31:24];
			3'd5: intensity = data_in[23:16];
			3'd6: intensity = data_in[15:8];
			3'd7: intensity = data_in[7:0];
		endcase
			
		data_out = {3{intensity, 4'd0}};
	end
endmodule
