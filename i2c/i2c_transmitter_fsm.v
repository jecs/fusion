`default_nettype none

module i2c_transmitter_fsm(
	clock,
	reset,
	idle,
	last_trans,
	start,
	cl_high,
	start_trans,
	inc_trans
);

	input wire clock;
	input wire reset;
	input wire idle;
	input wire last_trans;
	input wire start;
	input wire cl_high;

	output reg start_trans;
	output reg inc_trans;

	reg continue;
	reg count_highs;
	parameter HIGHS = 6'd5;
	reg [5:0] high_count = 6'd0;

	reg [3:0] control;
	reg [2:0] outputs;

	parameter INIT   = 5'b000001;
	parameter START  = 5'b000010;
	parameter TRANS  = 5'b000100;
	parameter UPDATE = 5'b001000;
	parameter WAIT   = 5'b010000;
	reg [4:0] state = INIT;

	always @(*) begin
		control = {idle, last_trans, start, continue};
		
		case(state)
			INIT:   outputs = 3'b000;
			START:  outputs = 3'b100;
			TRANS:  outputs = 3'b000;
			UPDATE: outputs = 3'b010;
			WAIT:   outputs = 3'b001;
			default: outputs = 3'b000;
		endcase

		start_trans = outputs[2];
		inc_trans = outputs[1];
		count_highs = outputs[0];
	end

	always @(posedge clock) begin
		if(reset) begin
			state <= INIT;
		end
		else case(state)
			INIT: casex(control)
				4'bXX0X: state <= INIT;
				4'bXX1X: state <= START;
			endcase
			START: state <= TRANS;
			TRANS: casex(control)
				4'b0XXX: state <= TRANS;
				4'b1XXX: state <= UPDATE;
			endcase
			UPDATE: casex(control)
				4'bX0XX: state <= WAIT;
				4'bX1XX: state <= INIT;
			endcase
			WAIT: casex(control)
				4'bXXX0: state <= WAIT;
				4'bXXX1: state <= START;
			endcase
			default: state <= INIT;
		endcase
	end

	always @(posedge clock) begin
		if(reset || !count_highs) begin
			high_count <= 6'd0;
		end
		else if(!cl_high) begin
			high_count <= high_count;
		end
		else if(continue) begin
			high_count <= 6'd0;
		end
		else begin
			high_count <= high_count + 6'd1;
		end
	end

	always @(*) begin
		continue = (high_count == HIGHS);
	end
endmodule
