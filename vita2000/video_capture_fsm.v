`default_nettype none

module video_capture_fsm(
	pclock,
	reset,
	FS,
	FE,
	LS,
	LE,
	IMG,
	ID,
	LL,
	end_line,
	end_frame,
	record
);

	input wire pclock;
	input wire reset;

	input wire FS;
	input wire FE;
	input wire LS;
	input wire LE;
	input wire IMG;
	input wire ID;
	input wire LL;

	output reg end_line;
	output reg end_frame;
	output reg record;

	parameter IDLE     = 9'b000000001;
	parameter START    = 9'b000000010;
	parameter CAPTURE  = 9'b000000100;
	parameter RECORD   = 9'b000001000;
	parameter ENDING_L = 9'b000010000;
	parameter WAIT_ID  = 9'b000100000;
	parameter END_OF_L = 9'b001000000;
	parameter WAIT_L   = 9'b010000000;
	parameter END_OF_F = 9'b100000000;
	reg [8:0] state = IDLE;

	reg [6:0] control;
	reg [2:0] outputs;

	always @(posedge pclock) begin
		if(reset) begin
			state <= IDLE;
		end
		else case(state)
			IDLE: casex(control)
				7'b0XXXXXX: state <= IDLE;
				7'b1XXXXXX: state <= START;
			endcase
			START: state <= CAPTURE;
			CAPTURE: casex(control)
				7'bX0X000X: state <= CAPTURE;
				7'bX1XXXXX: state <= ENDING_L;
				7'bXXX1XXX: state <= ENDING_L;
				7'bXXXX1XX: state <= RECORD;
				7'bXXXXX1X: state <= RECORD;
			endcase
			RECORD: state <= CAPTURE;
			ENDING_L: state <= WAIT_ID;
			WAIT_ID: casex(control)
				7'bXXXXX0X: state <= WAIT_ID;
				7'bXXXXX10: state <= END_OF_L;
				7'bXXXXX11: state <= END_OF_F;
			endcase
			END_OF_L: state <= WAIT_L;
			WAIT_L: casex(control)
				7'bXX0XXXX: state <= WAIT_L;
				7'bXX1XXXX: state <= RECORD;
			endcase
			END_OF_F: state <= IDLE;
			default: state <= IDLE;
		endcase
	end

	always @(*) begin
		control = {FS, FE, LS, LE, IMG, ID, LL};

		case(state)
			IDLE:     outputs = 3'b000;
			START:    outputs = 3'b001;
			CAPTURE:  outputs = 3'b000;
			RECORD:   outputs = 3'b001;
			ENDING_L: outputs = 3'b001;
			WAIT_ID:  outputs = 3'b000;
			END_OF_L: outputs = 3'b101;
			WAIT_L:   outputs = 3'b000;
			END_OF_F: outputs = 3'b111;
			default:  outputs = 3'b000;
		endcase


		end_line = outputs[2];
		end_frame = outputs[1];
		record = outputs[0];
	end
endmodule
