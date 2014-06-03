`default_nettype none

`include "hdmi.h"

module hdmi_top(
	output wire hdmi_r_d[35:0],
	output wire hdmi_r_hsync,
	output wire hdmi_r_vsync,
	output wire hdmi_r_de,
	output wire hdmi_r_clk
);

wire clock;
wire reset;
wire vclock;

wire hs_gen;
wire vs_gen;
wire de_gen;
wire request_gen;
wire [`HBW-1:0] x_gen;
wire [`VBW-1:0] y_gen;

hdmi_generator hdmi_gen(
	.clock(clock),
	.reset(reset),
	.hs(hs_gen),
	.vs(vs_gen),
	.de(de_gen),
	.vclock(vclock),
	.request(request_gen),
	.x(x_gen),
	.y(y_gen)
);


hdmi_test_pattern_generator test(
	.clock(clock),
	.reset(reset),
	.hs_in(hs_gen),
	.vs_in(vs_gen),
	.de_in(de_gen),
	.vclock_in(vclock),
	.x(x_gen),
	.y(y_gen),
	.hs_out(hdmi_r_hsync),
	.vs_out(hdmi_r_vsync),
	.de_out(hdmi_r_de),
	.vclock_out(hdmi_r_clk),
	.data_out(hdmi_r_d)
);

endmodule
