`default_nettype none

module spi_master(
	clock,
	reset,
	start,
	ss_n,
	sclk,
	mosi
);

	input wire clock;
	input wire reset;
	input wire start;
	output wire ss_n;
	output wire sclk;
	output wire mosi;

	wire msg_bit;
	wire sclk_in;
	wire start_fsm;
	wire low_t;
	wire high_t;
	wire last_bit;
	wire last_msg;
	wire restart_fsm;
	wire inc_bit;
	wire inc_msg;
	wire waiting;
	assign start_fsm = start;

	spi_clock_generator spi_clock(
		.clock(clock),
		.reset(reset),
		.sclk(sclk_in),
		.high_t(high_t),
		.low_t(low_t)
	);

	spi_message_controller spi_msg(
		.clock(clock),
		.reset(reset),
		.inc_bit(inc_bit),
		.inc_msg(inc_msg),
		.last_bit(last_bit),
		.last_msg(last_msg),
		.msg_bit(msg_bit)
	);

	/*
	spi_start_timer spi_start(
		.clock(clock),
		.reset(reset),
		.start(start_fsm)
	);
	*/

	spi_restart_timer spi_restart(
		.clock(clock),
		.reset(reset),
		.pulse(low_t),
		.count(waiting),
		.done(restart_fsm)
	);

	spi_master_fsm fsm(
		.clock(clock),
		.reset(reset),
		.msg_bit(msg_bit),
		.sclk_in(sclk_in),
		.start(start_fsm),
		.low_t(low_t),
		.high_t(high_t),
		.last_bit(last_bit),
		.last_msg(last_msg),
		.restart(restart_fsm),
		.ss_n(ss_n),
		.sclk_out(sclk),
		.mosi(mosi),
		.inc_bit(inc_bit),
		.inc_msg(inc_msg),
		.waiting(waiting)
	);
endmodule
