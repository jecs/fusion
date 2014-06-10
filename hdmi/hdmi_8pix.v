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
	reg [3:0] pixel = 4'd0;
	reg [6:0] pixel_start;
	reg [6:0] pixel_end;

	always @(posedge clock) begin
		hs_out <= hs_in;
		vs_out <= vs_out;
		de_out <= de_in;
		pixel <= {1'b0, x[2:0]};
		pixel_start <= (pixel+4'd1)*8-1;
		pixel_end   <= pixel*8;
	end

	always @(*) begin
		intensity = data_in[pixel_start:pixel_end];
		data_in = {3{intensity, 4'd0}};
	end
endmodule
