`default_nettype none

module synchronizer(
	ser_clock,
	par_clock,
	sync_p,
	sync_n,
	cam_d_p,
	cam_d_n,
	sync,
	cam_d,
	FS,
	FE,
	LS,
	LE,
	ID,
	BL,
	TP,
	IMG,
	CRC,
	INV,
	REC
);

	input wire ser_clock;
	input wire par_clock;
	input wire sync_p;
	input wire sync_n;
	input wire [3:0] cam_d_p;
	input wire [3:0] cam_d_n;

	output reg sync;
	output reg [31:0] cam_d;

	output reg FS;
	output reg FE;
	output reg LS;
	output reg LE;
	output reg ID;
	output reg BL;
	output reg TP;
	output reg IMG;
	output reg CRC;
	output reg INV;
	output reg REC;

	reg [7:0] FS_EXT;
	reg [7:0] FE_EXT;
	reg [7:0] LS_EXT;
	reg [7:0] LE_EXT;
	reg [7:0] ID_EXT;
	reg [7:0] BL_EXT;
	reg [7:0] TP_EXT;
	reg [7:0] IMG_EXT;
	reg [7:0] CRC_EXT;

	/*
		10101010 - FS
		11001010 - FE
		00101010 - LS
		01001010 - LE
		00000101 - BL
		00001101 - IMG
		00010110 - CRC
		11101001 - TP
	*/

	parameter FS_WORD  = 8'b10101010;
	parameter FE_WORD  = 8'b11001010;
	parameter LS_WORD  = 8'b00101010;
	parameter LE_WORD  = 8'b01001010;
	parameter ID_WORD  = 8'b00000000;
	parameter BL_WORD  = 8'b00000101;
	parameter TP_WORD  = 8'b11101001;
	parameter IMG_WORD = 8'b00001101;
	parameter CRC_WORD = 8'b00010110;

	reg [7:0] select;
	reg [14:0] sync_ext;

	demultiplex sync_demux(
		.ser_clock(ser_clock),
		.par_clock(par_clock),
		.data_in_p(sync_p),
		.data_in_n(sync_n),
		.select(select),
		.data_out(sync),
		.data_ext(sync_ext),
	);

	genvar i;
	generate
		for(i=0;i < 4;i=i+1) begin : DATA_DEMUX
			demultiplex data_demux(
				.ser_clock(ser_clock),
				.par_clock(par_clock),
				.data_in_p(cam_d_p[i]),
				.data_in_n(cam_d_n[i]),
				.select(select),
				.data_out(cam_d[(i+1)*8-1:i*8]),
				.data_ext(),
			);
		end	

		for(i=7;i >= 0;i=i-1) begin : SYNC_PARSE
			always @(*) begin
				FS_EXT[i] = (sync_ext[(7+i):i] == FS_WORD);
				FE_EXT[i] = (sync_ext[(7+i):i] == FE_WORD);
				LS_EXT[i] = (sync_ext[(7+i):i] == LS_WORD);
				LE_EXT[i] = (sync_ext[(7+i):i] == LE_WORD);
				ID_EXT[i] = (sync_ext[(7+i):i] == ID_WORD);
				BL_EXT[i] = (sync_ext[(7+i):i] == BL_WORD);
				TP_EXT[i] = (sync_ext[(7+i):i] == TP_WORD);
				IMG_WORD[i] = (sync_ext[(7+i):i] == IMG_WORD);
				CRC_WORD[i] = (sync_ext[(7+i):i] == CRC_WORD);
			end
		end
	endgenerate

	always @(*) begin
		FS = |FS_EXT;
		FE = |FE_EXT;
		LS = |LS_EXT;
		LE = |LE_EXT;
		ID = |ID_EXT;
		BL = |BL_EXT;
		TP = |TP_EXT;
		IMG = |IMG_EXT;
		CRC = |CRC_EXT;

		select = (FS_EXT | FE_EXT | LS_EXT  | LE_EXT | ID_EXT |\
				  BL_EXT | TP_EXT | IMG_EXT | CRC_EXT);
		INV = ~|select;
		REC = (FS | FE | LS | LE | ID | IMG);
	end
endmodule
