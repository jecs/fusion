`default_nettype none

module i2c_master_fsm(
	clock,
	reset,
	start,
	scl_in,
	cl_low,
	cl_high,
	last_bit,
	last_msg,
	inc_bit,
	inc_msg,
	msg_bit,
	sda,
	scl_out,
	reading_sda,
	idle
);

	input wire clock;
	input wire reset;
	input wire start;
	input wire scl_in;
	input wire cl_low;
	input wire cl_high;
	input wire last_bit;	
	input wire last_msg;
	output reg inc_bit;
	output reg inc_msg;
	output reg reading_sda;
	output reg idle;
	
	input wire msg_bit;
	inout wire sda;
	output reg scl_out;

	wire [5:0] control = {start, sda, cl_low, cl_high, last_msg, last_bit};
	reg [3:0] outputs;

	parameter IDLE         = 10'b0000000001;
	parameter STARTING     = 10'b0000000010;
	parameter LOW_STARTING = 10'b0000000100;
	parameter TRANSMITTING = 10'b0000001000;
	parameter NEXT_BIT     = 10'b0000010000;
	parameter ACK          = 10'b0000100000;
	parameter NEXT_MESSAGE = 10'b0001000000;
	parameter LOW_CONTINUE = 10'b0010000000;
	parameter LOW_STOPPING = 10'b0100000000;
	parameter STOPPING     = 10'b1000000000;
	reg [9:0] state = IDLE;

	always @(posedge clock) begin
		if(reset) begin
			state <= IDLE;
		end
		else case(state)
			IDLE: casex(control)
				6'b0XXXXX: state <= IDLE;
				6'b1XXXXX: state <= STARTING;
			endcase
			STARTING: casex(control)
				6'bXXX0XX: state <= STARTING;
				6'bXXX1XX: state <= LOW_STARTING;
			endcase
			LOW_STARTING: casex(control)
				6'bXX0XXX: state <= LOW_STARTING;
				6'bXX1XXX: state <= TRANSMITTING;
			endcase
			TRANSMITTING: casex(control)
				6'bXX0XXX: state <= TRANSMITTING;
				6'bXX1XXX: state <= NEXT_BIT;
			endcase
			NEXT_BIT: casex(control)
				6'bXXXXX0: state <= TRANSMITTING;
				6'bXXXXX1: state <= ACK;
			endcase
			ACK: casex(control)
				6'bXXX0XX: state <= ACK;
				6'bX0X1XX: state <= NEXT_MESSAGE;
				6'bX1X1XX: state <= LOW_STOPPING;
			endcase
			NEXT_MESSAGE: casex(control)
				6'bXXXX1X: state <= LOW_STOPPING;
				6'bXXXX0X: state <= LOW_CONTINUE;
			endcase
			LOW_CONTINUE: casex(control)
				6'bXX0XXX: state <= LOW_CONTINUE;
				6'bXX1XXX: state <= TRANSMITTING;
			endcase
			LOW_STOPPING: casex(control)
				6'bXX0XXX: state <= LOW_STOPPING;
				6'bXX1XXX: state <= STOPPING;
			endcase
			STOPPING: casex(control)
				6'bXXX0XX: state <= STOPPING;
				6'bXXX1XX: state <= IDLE;
			endcase
			default: state <= IDLE;
		endcase
	end

	always @(*) begin
		if(reset) begin
			outputs = 4'b0011;
		end
		else case(state)
			IDLE:         outputs = {1'b0, 1'b0, 1'b1, 1'b1};
			STARTING:     outputs = {1'b0, 1'b0, 1'b1, 1'b1};
			LOW_STARTING: outputs = {1'b0, 1'b0, 1'b0, scl_in};
			TRANSMITTING: outputs = {1'b0, 1'b0, msg_bit, scl_in};
			NEXT_BIT:     outputs = {1'b0, 1'b1, msg_bit, scl_in};
			ACK:          outputs = {1'b0, 1'b0, 1'bZ, scl_in};
			NEXT_MESSAGE: outputs = {1'b1, 1'b0, 1'bZ, scl_in};
			LOW_CONTINUE: outputs = {1'b0, 1'b0, 1'bZ, scl_in};
			LOW_STOPPING: outputs = {1'b0, 1'b0, 1'bZ, scl_in};
			STOPPING:     outputs = {1'b0, 1'b0, 1'b0, scl_in};
			default:      outputs = {1'b0, 1'b0, 1'b1, 1'b1};
		endcase
		
		case(state)
			ACK, LOW_STOPPING, LOW_CONTINUE, NEXT_MESSAGE: reading_sda = 1'b1;
			default: reading_sda = 1'b0;
		endcase

		case(state)
			IDLE: idle = 1'b1;
			default: idle = 1'b0;
		endcase

		inc_msg = outputs[3];
		inc_bit = outputs[2];
		scl_out = outputs[0];
	end

	assign sda  = outputs[1];

endmodule
