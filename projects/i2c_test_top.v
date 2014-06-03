`timescale 1ns / 1ps
`default_nettype none

`include "hdmi.h"

module i2c_test_top(
	i2c_scl,
	i2c_sda,
	sysclk_p,
	sysclk_n,
	gpio_led,
	hdmi_de,
	hdmi_vsync,
	hdmi_hsync,
	hdmi_clock,
	hdmi_data
);

	output wire i2c_scl;
	inout wire i2c_sda;
	input wire sysclk_p;
	input wire sysclk_n;
	output reg [7:0] gpio_led;
	output wire hdmi_de;
	output wire hdmi_vsync;
	output wire hdmi_hsync;
	output wire hdmi_clock;
	output wire [35:0] hdmi_data;
	
	wire clock;
	wire reset;
	assign reset = 1'b0;
	wire pixel_clock;
	wire i2c_start;
	
	clock_generator clock_generator(
		.diff_clock_p(sysclk_p),
		.diff_clock_n(sysclk_n),
		.system_clock(clock),
		.hdmi_clock(pixel_clock),
		.hdmi_clock_inv(hdmi_clock)
	);
	
	i2c_master_transmitter i2c(
		.clock(clock),
		.reset(reset),
		.start(i2c_start),
		.scl(i2c_scl),
		.sda(i2c_sda),
		.reading_sda()
	);
	
	i2c_start_counter i2c_start(
		.clock(clock),
		.reset(reset),
		.start(i2c_start)
	);
	
	wire hs_gen;
	wire vs_gen;
	wire de_gen;
	wire [`HBW-1:0] x_gen;
	wire [`VBW-1:0] y_gen;
	
	hdmi_generator hdmi_gen
	(
		.clock(pixel_clock),
		.reset(reset),
		.hs(hs_gen),
		.vs(vs_gen),
		.de(de_gen),
		// x and y associated with current timestep
		// values will be delayed later on, in another module
		.x(x_gen),
		.y(y_gen)
	);
	
	hdmi_test_pattern_generator hdmi_test_gen
	(
		.clock(pixel_clock),
		.reset(reset),
		.hs_in(hs_gen),
		.vs_in(vs_gen),
		.de_in(de_gen),
		.x(x_gen),
		.y(y_gen),
		.hs_out(hdmi_hsync),
		.vs_out(hdmi_vsync),
		.de_out(hdmi_de),
		.data_out(hdmi_data)
	);

endmodule
