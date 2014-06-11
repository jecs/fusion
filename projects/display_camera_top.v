`timescale 1ns / 1ps
`default_nettype none

`include "hdmi.h"

module display_camera_top(
	i2c_scl,
	i2c_sda,
	// input 200MHz clock
	sysclk_p,
	sysclk_n,
	// LEDs
	gpio_led,
	// HDMI
	hdmi_de,
	hdmi_vsync,
	hdmi_hsync,
	hdmi_clock,
	hdmi_data,
	// VITA2000 data in
	cam_d_p,
	cam_d_n,
	sync_p,
	sync_n,
	clk_out_p,
	clk_out_n,
	// VITA2000 SPI
	spi_mosi,
	spi_sclk,
	spi_ssel_n,
	// VITA2000 signals out
	pg_c2m, // power good
	clk_pll, // 62MHz
	prsnt_m2c_l, // ???
	cam_reset_n,
	vadj_on_b,
	// PMBus for VADJ
	pmbus_data,
	pmbus_clock
);

	output wire i2c_scl;
	inout wire i2c_sda;
	input wire sysclk_p;
	input wire sysclk_n;
	output wire [7:0] gpio_led;
	output wire hdmi_de;
	output wire hdmi_vsync;
	output wire hdmi_hsync;
	output wire hdmi_clock;
	output wire [35:0] hdmi_data;
	input wire [3:0] cam_d_p;
	input wire [3:0] cam_d_n;
	input wire sync_p;
	input wire sync_n;
	input wire clk_out_p;
	input wire clk_out_n;
	output wire spi_mosi;
	output wire spi_sclk;
	output wire spi_ssel_n;
	output wire pg_c2m;
	output wire clk_pll;
	input wire prsnt_m2c_l;
	output wire cam_reset_n;
	output wire vadj_on_b;
	inout wire pmbus_data;
	output wire pmbus_clock; 
	
	wire clock;
	wire reset;
	wire pixel_clock;

	/* START SIGNALS */
	wire pmbus_start;
	wire vadj_started;
	wire hdmi_i2c_start;
	wire vita2000_spi_start;
	
	/* VIDEO SIGNALS */
	wire hs_gen;
	wire vs_gen;
	wire de_gen;
	wire [`HBW-1:0] x_gen;
	wire [`VBW-1:0] y_gen;

	/* MEMORY SIGNALS */
	wire [18:0] vita2000_addr;
	wire [63:0] vita2000_data;
	wire vita2000_we;
	wire vita2000_clock;
	wire [18:0] hdmi_addr;
	wire [63:0] hdmi_read;

	/* NECESSARY ASSIGNMENTS */
	assign reset = 1'b0;
	assign vadj_on_b = ~vadj_started;
	assign gpio_led = 8'h00;
	
	clock_generator clock_generator(
		.clock_ds_p(sysclk_p),
		.clock_ds_n(sysclk_n),
		.system_clock(clock),
		.hdmi_clock(pixel_clock),
		.hdmi_clock_inv(hdmi_clock)
	);
	
	pll_clock_gen pll (
		.clk_in1_p(sysclk_p),
		.clk_in1_n(sysclk_n),
		.pll_clk(clk_pll)
	);

	/* TIMERS FOR SERIAL INITIALIZERS */	
	start_timer hdmi_st(
		.clock(clock),
		.reset(reset),
		.start(hdmi_i2c_start),
		.started()
	);

	start_timer vita2k_st(
		.clock(clock),
		.reset(reset),
		.start(vita2000_spi_start),
		.started()
	);

	start_timer #(
		.TIME(32'd10000000)
	) pmbus_st(
		.clock(clock),
		.reset(reset),
		.start(pmbus_start),
		.started(vadj_started)
	);
	
	start_timer #(
		.TIME(32'd20000000)
	) pg_st(
		.clock(clock),
		.reset(reset),
		.start(),
		.started(pg_c2m)
	);
	
	/* SERIAL INITIALIZERS */
	pmbus_ti9248_init vadj_init(
		.clock(clock),
		.reset(reset),
		.start(pmbus_start),
		.scl(pmbus_clock),
		.sda(pmbus_data),
		.reading_sda()
	);
	
	i2c_adv7511_init hdmi_i2c(
		.clock(clock),
		.reset(reset),
		.start(hdmi_i2c_start),
		.scl(i2c_scl),
		.sda(i2c_sda),
		.reading_sda()
	);
	
	spi_master vita2000_spi(
		.clock(clock),
		.reset(reset),
		.start(vita2000_spi_start),
		.ss_n(spi_ssel_n),
		.sclk(spi_sclk),
		.mosi(spi_mosi)
	);
	
	/* CAPTURE, STORAGE, AND DISPLAY MODULES */
	hdmi_generator hdmi_gen
	(
		.clock(pixel_clock),
		.reset(reset),
		.hs(hs_gen),
		.vs(vs_gen),
		.de(de_gen),
		.x(x_gen),
		.y(y_gen)
	);
	
	hdmi_8pix hdmi8(
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
		.data_out(hdmi_data),
		.addr(hdmi_addr),
		.data_in(hdmi_read)
	);

	vita2000_capture vita2000c(
		.pclock_p(clk_out_p),
		.pclock_n(clk_out_n),
		.cam_d_p(cam_d_p),
		.cam_d_n(cam_d_n),
		.sync_p(sync_p),
		.sync_n(sync_n),
		.pclock(),
		.w_addr(vita2000_addr),
		.w_data(vita2000_data),
		.we(vita2000_we)
	);
	
	blk_mem_gen_0 mem (
	  .clka(pixel_clock),    // input wire clka
	  .ena(1'b1),      // input wire ena
	  .wea(1'b0),      // input wire [0 : 0] wea
	  .addra(hdmi_addr[16:0]),  // input wire [16 : 0] addra
	  .dina(64'd0),    // input wire [63 : 0] dina
	  .douta(hdmi_read),  // output wire [63 : 0] douta
	  .clkb(vita2000_clock),    // input wire clkb
	  .web(vita2000_we),      // input wire [0 : 0] web
	  .addrb(vita2000_addr[16:0]),  // input wire [16 : 0] addrb
	  .dinb(vita2000_data),    // input wire [63 : 0] dinb
	  .doutb()  // output wire [63 : 0] doutb
	);

endmodule
