`default_nettype none

module i2c_adv7511_init_ROM(
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
	parameter BUS  = 7'b1110100;
	parameter HDMI = 7'b0111001;
	parameter BUS_W = {BUS, WRITE};
	parameter HDMI_W = {HDMI, WRITE};

	always @(*) begin
		LIMIT_BIT = 3'd7;
		case(index_trans)
			5'd0: LIMIT_MSG = 5'd1;
			default: LIMIT_MSG = 5'd2;
		endcase
		LIMIT_TRANS = 5'd13;
		

		case(index_trans)
			5'd0: case(index_msg)
				2'd0: message = BUS_W;
				2'd1: message = 8'b00100000;
				default: message = 8'h00;
			endcase
			5'd1: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h41;
				2'd2: message = 8'b00010000;
				default: message = 8'h00;
			endcase
			5'd2: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h98;
				2'd2: message = 8'h03;
				default: message = 8'h00;
			endcase
			5'd3: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9A;
				2'd2: message = 8'b11100000;
				default: message = 8'h00;
			endcase
			5'd4: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9C;
				2'd2: message = 8'h30;
				default: message = 8'h00;
			endcase
			5'd5: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9D;
				2'd2: message = 8'b01100001;
				default: message = 8'h00;
			endcase
			5'd6: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hA2;
				2'd2: message = 8'hA4;
				default: message = 8'h00;
			endcase
			5'd7: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hA3;
				2'd2: message = 8'hA4;
				default: message = 8'h00;
			endcase
			5'd8: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hE0;
				2'd2: message = 8'hD0;
				default: message = 8'h00;
			endcase
			5'd9: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hF9;
				2'd2: message = 8'h00;
				default: message = 8'h00;
			endcase
			5'd10: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h15;
				2'd2: message = 8'h00;
				default: message = 8'h00;
			endcase
			5'd11: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h16;
				2'd2: message = 8'b00110100;
				default: message = 8'h00;
			endcase
			5'd12: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h17;
				2'd2: message = 8'b00000010;
				default: message = 8'h00;
			endcase
			5'd13: case(index_msg)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hAF;
				2'd2: message = 8'b00000110;
				default: message = 8'h00;
			endcase
			default: message = 8'd0;
		endcase

		msg_bit = message[index_bit];
	end
endmodule
