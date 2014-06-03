//-----------------------------------------------------------------------------
// system_top.v
//-----------------------------------------------------------------------------

`default_nettype none
`include "hdmi.h"

module system_top
  (
    sm_fan_pwm_net_vcc,
    ddr_memory_we_n,
    ddr_memory_ras_n,
    ddr_memory_odt,
    ddr_memory_dqs_n,
    ddr_memory_dqs,
    ddr_memory_dq,
    ddr_memory_dm,
    ddr_memory_ddr3_rst,
    ddr_memory_cs_n,
    ddr_memory_clk_n,
    ddr_memory_clk,
    ddr_memory_cke,
    ddr_memory_cas_n,
    ddr_memory_ba,
    ddr_memory_addr,
    RS232_Uart_1_sout,
    RS232_Uart_1_sin,
    RESET,
    CLK_P,
    CLK_N,
    iic_rstn,
    iic_sda,
    iic_scl,
    hdmi_clk,
    hdmi_vsync,
    hdmi_hsync,
    hdmi_data_e,
    hdmi_data,
    hdmi_spdif,
    hdmi_int,
	 gpio_sw_s,
	 gpio_led
  );
  
  output sm_fan_pwm_net_vcc;
  output ddr_memory_we_n;
  output ddr_memory_ras_n;
  output ddr_memory_odt;
  inout [7:0] ddr_memory_dqs_n;
  inout [7:0] ddr_memory_dqs;
  inout [63:0] ddr_memory_dq;
  output [7:0] ddr_memory_dm;
  output ddr_memory_ddr3_rst;
  output ddr_memory_cs_n;
  output ddr_memory_clk_n;
  output ddr_memory_clk;
  output ddr_memory_cke;
  output ddr_memory_cas_n;
  output [2:0] ddr_memory_ba;
  output [13:0] ddr_memory_addr;
  output RS232_Uart_1_sout;
  input RS232_Uart_1_sin;
  input RESET;
  input CLK_P;
  input CLK_N;
  output iic_rstn;
  inout iic_sda;
  inout iic_scl;
  output hdmi_clk;
  output hdmi_vsync;
  output hdmi_hsync;
  output hdmi_data_e;
  output [35:0] hdmi_data;
  output hdmi_spdif;
  input hdmi_int;
  input gpio_sw_s;
  output reg [7:0] gpio_led;
  
  wire system_clock;
  

  (* BOX_TYPE = "user_black_box" *)
  system
    system_i (
      .sm_fan_pwm_net_vcc ( sm_fan_pwm_net_vcc ),
      .ddr_memory_we_n ( ddr_memory_we_n ),
      .ddr_memory_ras_n ( ddr_memory_ras_n ),
      .ddr_memory_odt ( ddr_memory_odt ),
      .ddr_memory_dqs_n ( ddr_memory_dqs_n ),
      .ddr_memory_dqs ( ddr_memory_dqs ),
      .ddr_memory_dq ( ddr_memory_dq ),
      .ddr_memory_dm ( ddr_memory_dm ),
      .ddr_memory_ddr3_rst ( ddr_memory_ddr3_rst ),
      .ddr_memory_cs_n ( ddr_memory_cs_n ),
      .ddr_memory_clk_n ( ddr_memory_clk_n ),
      .ddr_memory_clk ( ddr_memory_clk ),
      .ddr_memory_cke ( ddr_memory_cke ),
      .ddr_memory_cas_n ( ddr_memory_cas_n ),
      .ddr_memory_ba ( ddr_memory_ba ),
      .ddr_memory_addr ( ddr_memory_addr ),
      .RS232_Uart_1_sout ( RS232_Uart_1_sout ),
      .RS232_Uart_1_sin ( RS232_Uart_1_sin ),
      .RESET ( RESET ),
      .CLK_P ( CLK_P ),
      .CLK_N ( CLK_N ),
      .iic_rstn ( iic_rstn ),
      .iic_sda ( iic_sda ),
      .iic_scl ( iic_scl ),
		
		.hdmi_clk(),
		.hdmi_vsync(),
		.hdmi_hsync(),
		.hdmi_data_e(),
		.hdmi_data(),
		.hdmi_spdif(hdmi_spdif),
		.hdmi_int( hdmi_int ),
		.system_clock(system_clock)
	/*
      .hdmi_clk ( hdmi_clk ),
      .hdmi_vsync ( hdmi_vsync ),
      .hdmi_hsync ( hdmi_hsync ),
      .hdmi_data_e ( hdmi_data_e ),
      .hdmi_data ( ),
      .hdmi_spdif ( hdmi_spdif ),
      .hdmi_int ( hdmi_int )
*/
	);
	
	wire hs_gen;
	wire vs_gen;
	wire de_gen;
	wire vclock_gen;
	wire video_clock;
	wire [`HBW-1:0] x_gen;
	wire [`VBW-1:0] y_gen;
	
	/*
	wire gpio_sw_s_clean;
	
	debounce debounce1
	(
		.clock(video_clock),
		.reset(1'b0),
		.noisy(gpio_sw_s),
		.clean(gpio_sw_s_clean)
	);
	
	reg [3:0] levels = 4'd0;
	*/
	
	video_clock_gen clock_gen
   (
		.sys_clock(system_clock),
		.hdmi_clock(video_clock),
		.hdmi_clock_inv(hdmi_clk)
	);
	
   hdmi_generator hdmi_gen
   (
		.clock(video_clock),
		.reset( 1'b0 ),
		.hs(hs_gen),
		.vs(vs_gen),
		.de(de_gen),
		.vclock(),
		.request(),
		// x and y associated with current timestep
		// values will be delayed later on, in another module
		.x(x_gen),
		.y(y_gen)
	);
	
	wire display_toggle;
	wire dwt_toggle_on;
	wire dwt_toggle_off;
	wire dwt_disabled;
	wire dwt_transposing;
	wire new_frame;
	//reg started = 1'b0;
	
	wire [17:0] display_addr;
	wire [17:0] dwt_read_addr;
	wire [17:0] dwt_write_addr;
	
	wire [7:0] dwt_data_in;
	wire [7:0] dwt_data_out;
	wire dwt_we;
	wire [7:0] display_data_in;
	wire clean_sw;
	wire [3:0] dwt_levels;
	
	always @(*) begin
		gpio_led[7:4] = dwt_levels;
		gpio_led[3:1] = 3'b000;
		gpio_led[0] = clean_sw;
	end
	
	debounce db1(
		.clock(video_clock),
		.reset(1'b0),
		.noisy(gpio_sw_s),
		.clean(clean_sw)
	);
	
	levels_state_machine lsm(
		.clock(video_clock),
		.reset(1'b0),
		.toggle(clean_sw),
		.level(dwt_levels),
		.level_update(new_frame)
	);
	
	arbiter3 arbiter(
		.clock(video_clock),
		.reset(1'b0),
		.dwt_read_addr(dwt_read_addr),
		.dwt_write_addr(dwt_write_addr),
		.display_read_addr(display_addr),
		.dwt_write_data(dwt_data_out),
		.dwt_we(dwt_we),
		.dwt_toggle_on(dwt_toggle_on),
		.dwt_toggle_off(dwt_toggle_off),
		.dwt_disabled(dwt_disabled),
		.dwt_transposing(dwt_transposing),
		.dwt_read_data(dwt_data_in),
		.display_read_data(display_data_in)
	);
	
	display_lena display(
		.clock(video_clock),
		.reset(1'b0),
		.y(y_gen),
		.x(x_gen),
		.hsync_in(hs_gen),
		.vsync_in(vs_gen),
		.de_in(de_gen),
		.hsync_out(hdmi_hsync),
		.vsync_out(hdmi_vsync),
		.de_out(hdmi_data_e),
		.data_out(hdmi_data),
		.addr(display_addr),
		.data_in(display_data_in),
		.end_of_frame(display_toggle)
	);

	haar_dwt dwt(
		.clock(video_clock),
		.reset(1'b0),
		.new_frame(new_frame),
		.addr_in(dwt_read_addr),
		.data_in(dwt_data_in),
		.addr_out(dwt_write_addr),
		.data_out(dwt_data_out),
		.we(dwt_we),
		.on_switch(dwt_toggle_on),
		.off_switch(dwt_toggle_off),
		.disabled(dwt_disabled),
		.transposing(dwt_transposing),
		.levels(dwt_levels)
	);
	
endmodule

