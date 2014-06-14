`default_nettype none

module vita2k(
	cam_clock_p,
	cam_clock_n,
	sync_p,
	sync_n,
	cam_d_p,
	cam_d_n,
	par_clock,
	we,
	pixels,
	debug
);

	input wire cam_clock_p;
	input wire cam_clock_n;
	input wire sync_p;
	input wire sync_n;
	input wire [3:0] cam_d_p;
	input wire [3:0] cam_d_n;

	wire ser_clock;
	output wire par_clock;
	
	output wire we;
	output wire [63:0] pixels;
	output wire [10:0] debug;

	wire [7:0] sync;
	wire [31:0] cam_d;

	wire FS;
	wire FE;
	wire LS;
	wire LE;
	wire ID;
	wire BL;
	wire TP;
	wire IMG;
	wire CRC;
	wire INV;
	wire REC;

	// GENERATE CLOCKS
	

	// SYNCHRONIZE AND DEMULTIPLEX DATA
	synchronizer sync(
		.ser_clock(ser_clock),
		.par_clock(par_clock),
		.sync_p(sync_p),
		.sync_n(sync_n),
		.cam_d_p(cam_d_p),
		.cam_d_n(cam_d_n),
		.sync(sync),
		.cam_d(cam_d),
		.FS(FS),
		.FE(FE),
		.LS(LS),
		.LE(LE),
		.ID(ID),
		.BL(BL),
		.TP(TP),
		.IMG(IMG),
		.CRC(CRC),
		.INV(INV),
		.REC(REC)
	);

	// RECORD DATA
	recorder rec(
		.par_clock(par_clock),
		.cam_d(cam_d),
		.FS(FS),
		.FE(FE),
		.INV(INV),
		.REC(REC),
		.we(we),
		.pixels(pixels)
	);
endmodule
