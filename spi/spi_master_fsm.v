module spi_master_fsm(
	clock,
	reset,
	bit_in,
	sclk_in,
	start,
	low_t,
	high_t,
	last_bit,
	done,
	mosi,
	ss_n,
	inc_bit,
	idle,
	sclk_out,
	count
);

	input wire clock;
	input wire reset;
	
	input wire bit_in;
	input wire sclk_in;
	input wire start;
	input wire low_t;
	input wire high_t;
	input wire last_bit;
	input wire done;
	
	output reg mosi;
	output reg ss_n;
	output reg inc_bit;
	output reg idle;
	output reg sclk_out;
	output reg count;
	
	wire [4:0] control;
	reg [5:0] outputs;
	
	parameter IDLE     = 7'b0000001;
	parameter SELECT   = 7'b0000010;
	parameter SET      = 7'b0000100;
	parameter TRANSMIT = 7'b0001000;
	parameter INC      = 7'b0010000;
	parameter FINISH   = 7'b0100000;
	parameter WAIT     = 7'b1000000;
	reg [6:0] state = IDLE;
	
	always @(*) begin
		control = {start, low_t, high_t, last_bit, done};
		mosi = outputs[5];
		ss_n = outputs[4];
		inc_bit = outputs[3];
		idle = outputs[2];
		sclk_out = outputs[1];
		count = outputs[0];
	end
	
	always @(posedge clock) begin
		if(reset) begin
			state <= IDLE;
		end
		else case(state)
			IDLE: casex(control)
				5'd0XXXX: state <= IDLE;
				5'd1XXXX: state <= SELECT;
			endcase
			SELECT: casex(control)
				5'dXX0XX: state <= SELECT;
				5'dXX1XX: state <= SET;
			endcase
			SET: casex(control)
				5'dX0XXX: state <= SET;
				5'dX1XXX: state <= TRANSMIT;
			endcase
			TRANSMIT: casex(control)
				5'dX0XXX: state <= TRANSMIT;
				5'dX1XXX: state <= INC;
			endcase
			INC: casex(control)
				5'dXXX0X: state <= TRANSMIT;
				5'dXXX1X: state <= FINISH;
			endcase
			FINISH: casex(control)
				5'dX0XXX: state <= FINISH;
				5'dX1XXX: state <= WAIT;
			endcase
			WAIT: casex(control)
				5'dXXXX0: state <= WAIT;
				5'dXXXX1: state <= IDLE;
			endcase
			default: state <= IDLE;
		endcase
	end
	
	always @(*) begin
		case(state)
			IDLE:     outputs = 6'b010100;
			SELECT:   outputs = 6'b010000;
			SET:      outputs = 6'b000000;
			TRANSMIT: outputs = {bit_in, 3'b000, sclk_in, 0};
			INC:      outputs = {bit_in, 3'b010, sclk_in, 0};
			FINISH:   outputs = 6'b000000;
			WAIT:     outputs = 6'b010001;
			default:  outputs = 6'b010100;
		endcase
	end
endmodule