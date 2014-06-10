`default_nettype none

module video_capture(
	pclock,
	reset,
	sync,
	data,
	w_addr,
	w_data,
	we
);

	input wire pclock;
	input wire reset;
	input wire sync;
	input wire [3:0] data;

	output wire [18:0] w_addr;
	output wire [63:0] w_data;
	output wire we;

	wire FS;
	wire FE;
	wire LS;
	wire LE;
	wire IMG;
	wire ID;
	wire LL;
	wire end_line;
	wire end_frame;
	wire fsm_record;
	wire datac_record;
	wire [63:0] data_in;

	video_capture_fsm fsm(
		.pclock(pclock),
		.reset(reset),
		.FS(FS),
		.FE(FE),
		.LS(LS),
		.LE(LE),
		.IMG(IMG),
		.ID(ID),
		.LL(LL),
		.end_line(end_line),
		.end_frame(end_frame),
		.record(fsm_record)
	);

	sync_capture syncc(
		.pclock(pclock),
		.reset(reset),
		.sync_bit(sync),
		.FS(FS),
		.FE(FE),
		.LS(LS),
		.LE(LE),
		.IMG(IMG),
		.ID(ID)
	);

	data_capture datac(
		.pclock(pclock),
		.reset(reset),
		.data(data),
		.record_in(fsm_record),
		.pixels(data_in),
		.record_out(datac_record)
	);

	data_record datar(
		.pclock(pclock),
		.reset(reset),
		.record(datac_record),
		.end_line(end_line),
		.end_frame(end_frame),
		.data_in(data_in),
		.write_addr(w_addr),
		.we(we),
		.data_out(w_data),
		.LL(LL)
	);
endmodule
