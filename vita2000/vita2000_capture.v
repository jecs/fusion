`default_nettype none

module vita2000_capture(
	pclock_p,
	pclock_n,
	cam_d_p,
	cam_d_n,
	sync_p,
	sync_n,
	pclock,
	w_addr,
	w_data,
	we
);

	input wire pclock_p;
	input wire pclock_n;

	input wire [3:0] cam_d_p;
	input wire [3:0] cam_d_n;

	input wire sync_p;
	input wire sync_n;

	output wire pclock;
	output wire [18:0] w_addr;
	output wire [63:0] w_data;
	output wire we;

	wire [3:0] cam_d;
	wire sync;

	lvds_in_to_cmos #(
		.BUS_WIDTH(4)
	) cam (
		.in_p(cam_d_p),
		.in_n(cam_d_n),
		.out_s(cam_d)
	);

	lvds_in_to_cmos #(
		.BUS_WIDTH(1)
	) syn (
		.in_p(sync_p),
		.in_n(sync_n),
		.out_s(sync)
	);

	lvds_in_to_cmos_clock pclock_buf(
		.clock_p(pclock_p),
		.clock_n(pclock_n),
		.clock(pclock)
	);

	video_capture video(
		.pclock(pclock),
		.reset(1'b0),
		.sync(sync),
		.data(cam_d),
		.w_addr(w_addr),
		.w_data(w_data),
		.we(we)
	);
endmodule
