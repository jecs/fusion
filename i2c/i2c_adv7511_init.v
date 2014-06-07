`default_nettype none

module i2c_adv7511_init(
	clock,
	reset,
	start,
	scl,
	sda,
	reading_sda
);

	input wire clock;
	input wire reset;
	input wire start;
	output wire scl;
	inout wire sda;
	output wire reading_sda;

	wire scl_in;
	wire cl_low;
	wire cl_high;
	wire last_bit;
	wire last_msg;
	wire last_trans;
	wire inc_bit;
	wire inc_msg;
	wire inc_trans;
	wire msg_bit;
	wire fsm_idle;
	wire start_trans;

	// EDIT BIT WIDTHS IF NECESSARY
	parameter BI_BW = 3;
	parameter MI_BW = 2;
	parameter TI_BW = 5;

	wire [BI_BW-1:0] index_bit;
	wire [MI_BW-1:0] index_msg;
	wire [TI_BW-1:0] index_trans;

	wire [BI_BW-1:0] LIMIT_BIT;
	wire [MI_BW-1:0] LIMIT_MSG;
	wire [TI_BW-1:0] LIMIT_TRANS;

	i2c_master_fsm masterfsm(
		.clock(clock),
		.reset(reset),
		.start(start_trans),
		.scl_in(scl_in),
		.cl_low(cl_low),
		.cl_high(cl_high),
		.last_bit(last_bit),
		.last_msg(last_msg),
		.inc_bit(inc_bit),
		.inc_msg(inc_msg),
		.msg_bit(msg_bit),
		.sda(sda),
		.scl_out(scl),
		.reading_sda(reading_sda),
		.idle(fsm_idle)
	);
	
	i2c_clock_generator clockgen(
		.clock(clock),
		.reset(reset),
		.scl(scl_in),
		.cl_low(cl_low),
		.cl_high(cl_high)
	);

	i2c_message_controller_fsm #(
		.BI_BW(BI_BW),
		.MI_BW(MI_BW),
		.TI_BW(TI_BW)
	)
	msgfsm (
		.clock(clock),
		.reset(reset),
		.inc_bit(inc_bit),
		.inc_msg(inc_msg),
		.inc_trans(inc_trans),
		.index_bit(index_bit),
		.index_msg(index_msg),
		.index_trans(index_trans),
		.last_bit(last_bit),
		.last_msg(last_msg),
		.last_trans(last_trans),
		.LIMIT_BIT(LIMIT_BIT),
		.LIMIT_MSG(LIMIT_MSG),
		.LIMIT_TRANS(LIMIT_TRANS)
	);

	/* INSERT MESSAGE ROM HERE */
	i2c_adv7511_init_ROM #(
		.BI_BW(BI_BW),
		.MI_BW(MI_BW),
		.TI_BW(TI_BW)
	)
	adv7511_init (
		.clock(clock),
		.reset(reset),
		.index_bit(index_bit),
		.index_msg(index_msg),
		.index_trans(index_trans),
		.LIMIT_BIT(LIMIT_BIT),
		.LIMIT_MSG(LIMIT_MSG),
		.LIMIT_TRANS(LIMIT_TRANS),
		.msg_bit(msg_bit)
	);	

	i2c_transmitter_fsm transfsm(
		.clock(clock),
		.reset(reset),
		.idle(fsm_idle),
		.last_trans(last_trans),
		.start(start),
		.cl_high(cl_high),
		.start_trans(start_trans),
		.inc_trans(inc_trans)
	);
endmodule
