`default_nettype none

module i2c_master_transmitter(
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

	i2c_message_controller msgcont(
		.clock(clock),
		.reset(reset),
		.inc_bit(inc_bit),
		.inc_msg(inc_msg),
		.inc_trans(inc_trans),
		.last_bit(last_bit),
		.last_msg(last_msg),
		.last_trans(last_trans),
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
