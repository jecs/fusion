`include "hdmi.h"

module display_lena(
	input wire clock,
	input wire reset,
	input wire [`VBW-1:0] y,
	input wire [`HBW-1:0] x,
	input wire hsync_in,
	input wire vsync_in,
	input wire de_in,
	output reg hsync_out,
	output reg vsync_out,
	output reg de_out,
	output reg [`PBW-1:0] data_out,
	
	output reg [17:0] addr,
	input wire [7:0] data_in,
	output reg end_of_frame
);

	reg [7:0] intensity;
	
	always @(*) begin
		addr = {y[9:1], x[9:1]-9'd256};
	end
	
	always @(*) begin
		if(x >= `HBW'd512 && x < `HBW'd1536 && y >= `VBW'd0 && y < `VBW'd1024) begin
			intensity = data_in;
		end
		else begin
			intensity = 8'd0;
		end
	end
	
	always @(*) begin
		end_of_frame = (x == `HBW'd511 && y == `VBW'd511);
	end
	
	always @(posedge clock) begin
		hsync_out <= hsync_in;
		vsync_out <= vsync_in;
		de_out <= de_in;
	end
	
	always @(*) begin
		data_out = {intensity, 4'd0, intensity, 4'd0, intensity, 4'd0};
	end
	
endmodule
