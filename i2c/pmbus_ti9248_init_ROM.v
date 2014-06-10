`default_nettype none

module pmbus_ti9248_init_ROM(
	clock,
	reset,
	index_bit,
	index_msg,
	index_trans,
	LIMIT_BIT,
	LIMIT_MSG,
	LIMIT_TRANS,
	msg_bit
);

	parameter BI_BW = 3;
	parameter MI_BW = 2;
	parameter TI_BW = 5;

	input wire clock;
	input wire reset;
	
	input wire [BI_BW-1:0] index_bit;
	input wire [MI_BW-1:0] index_msg;
	input wire [TI_BW-1:0] index_trans;

	output reg [BI_BW-1:0] LIMIT_BIT;
	output reg [MI_BW-1:0] LIMIT_MSG;
	output reg [TI_BW-1:0] LIMIT_TRANS;

	output reg msg_bit;
	reg [0:7] message;

	parameter WRITE = 1'b0;
	parameter PMBUS = 7'h7B;
	parameter PMBUS_W = {PMBUS, WRITE};

	always @(*) begin
		LIMIT_BIT = 3'd7;
		case(index_trans)
			5'd0, 5'd3: LIMIT_MSG = 2'd2;
			default: LIMIT_MSG = 2'd3;
		endcase
		LIMIT_TRANS = 5'd3;

		case(index_trans)
			5'd0: case(index_msg)
				2'd0: message = PMBUS_W;
				2'd1: message = 8'h00;
				2'd2: message = 8'h03;
				default: message = 8'h00;
			endcase
			5'd1: case(index_msg)
				2'd0: message = PMBUS_W;
				2'd1: message = 8'h24;
				2'd2: message = 8'h35;
				2'd3: message = 8'hE8;
				default: message = 8'h00;
			endcase
			5'd2: case(index_msg)
				2'd0: message = PMBUS_W;
				2'd1: message = 8'h21;
				2'd2: message = 8'h34;
				2'd3: message = 8'hCC;
				default: message = 8'h00;
			endcase
			5'd3: case(index_msg)
				2'd0: message = PMBUS_W;
				2'd1: message = 8'h01;
				2'd2: message = 8'h80;
				default: message = 8'h00;
			endcase
			default: message = 8'd0;
		endcase

		msg_bit = message[index_bit];
	end
endmodule
