`default_nettype none

module spi_master_fsm(
	clock,
	reset,
	msg_bit,
	sclk_in,
	start,
	low_t,
	high_t,
	last_bit,
	last_msg,
	restart,
	ss_n,
	sclk_out,
	mosi,
	inc_bit,
	inc_msg,
	waiting
);

	input wire clock;
	input wire reset;
	
	input wire msg_bit;
	input wire sclk_in;

	input wire start;
	input wire low_t;
	input wire high_t;
	input wire last_bit;
	input wire last_msg;
	input wire restart;
	
	output reg ss_n;
	output reg sclk_out;
	output reg mosi;
	output reg inc_bit;
	output reg inc_msg;
	output reg waiting;
	
	reg [5:0] control;
	reg [5:0] outputs;
	
	parameter IDLE     = 8'b00000001;
	parameter SELECT   = 8'b00000010;
	parameter SET      = 8'b00000100;
	parameter TRANSMIT = 8'b00001000;
	parameter INC_BIT  = 8'b00010000;
	parameter FINISH   = 8'b00100000;
	parameter INC_MSG  = 8'b01000000;
	parameter WAIT     = 8'b10000000;
	reg [7:0] state = IDLE;
	
	always @(*) begin
		control = {start, low_t, high_t, last_bit, last_msg, restart};
		
		ss_n     = outputs[5];
		sclk_out = outputs[4];
		mosi     = outputs[3];
		inc_bit  = outputs[2];
		inc_msg  = outputs[1];
		waiting  = outputs[0];
	end
	
	always @(posedge clock) begin
		if(reset) begin
			state <= IDLE;
		end
		else case(state)
			IDLE: casex(control)
				6'b0XXXXX: state <= IDLE;
				6'b1XXXXX: state <= SELECT;
			endcase
			SELECT: casex(control)
				6'bXX0XXX: state <= SELECT;
				6'bXX1XXX: state <= SET;
			endcase
			SET: casex(control)
				6'bX0XXXX: state <= SET;
				6'bX1XXXX: state <= TRANSMIT;
			endcase
			TRANSMIT: casex(control)
				6'bX0XXXX: state <= TRANSMIT;
				6'bX1XXXX: state <= INC_BIT;
			endcase
			INC_BIT: casex(control)
				6'bXXX0XX: state <= TRANSMIT;
				6'bXXX1XX: state <= FINISH;
			endcase
			FINISH: casex(control)
				6'bX0XXXX: state <= FINISH;
				6'bX1XXXX: state <= INC_MSG;
			endcase
			INC_MSG: casex(control)
				6'bXXXX0X: state <= WAIT;
				6'bXXXX1X: state <= IDLE;
			endcase
			WAIT: casex(control)
				6'bXXXXX0: state <= WAIT;
				6'bXXXXX1: state <= SELECT;
			endcase
			default: state <= IDLE;
		endcase
	end
	
	always @(*) begin
		case(state)
			IDLE:     outputs = 6'b100000;
			SELECT:   outputs = 6'b100000;
			SET:      outputs = 6'b000000;
			TRANSMIT: outputs = {1'b0, sclk_in, msg_bit, 3'b000};
			INC_BIT:  outputs = {1'b0, sclk_in, msg_bit, 3'b100};
			FINISH:   outputs = 6'b000000;
			INC_MSG:  outputs = 6'b100010;
			WAIT:     outputs = 6'b100001;
			default:  outputs = 6'b100000;
		endcase
	end
endmodule
