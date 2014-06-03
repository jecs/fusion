`default_nettype none

module i2c_message_controller(
	clock,
	reset,
	inc_bit,
	inc_msg,
	inc_trans,
	last_bit,
	last_msg,
	last_trans,
	msg_bit
);

	input wire clock;
	input wire reset;

	input wire inc_bit;
	input wire inc_msg;
	input wire inc_trans;

	output reg last_bit;
	output reg last_msg;
	output reg last_trans;
	
	output reg msg_bit;

	reg [2:0] bit_index = 3'd0;
	reg [2:0] LAST_BIT = 3'd7;

	reg [1:0] message_index = 2'd0;
	reg [1:0] LAST_MESSAGE;

	reg [4:0] transmission_index = 5'd0;
	reg [4:0] LAST_TRANSMISSION = 5'd13; // TODO: Update value

	reg [0:7] message;

	always @(posedge clock) begin
		if(reset) begin
			bit_index <= 3'd0;
		end
		else if(!inc_bit) begin
			bit_index <= bit_index;
		end
		else if(last_bit) begin
			bit_index <= 3'd0;
		end
		else begin
			bit_index <= bit_index + 3'd1;
		end

		if(reset) begin
			message_index <= 2'd0;
		end
		else if(!inc_msg) begin
			message_index <= message_index;
		end
		else if(last_msg) begin
			message_index <= 2'd0;
		end
		else begin
			message_index <= message_index + 2'd1;
		end

		if(reset) begin
			transmission_index <= 5'd0;
		end
		else if(!inc_trans) begin
			transmission_index <= transmission_index;
		end
		else if(last_trans) begin
			transmission_index <= 5'd0;
		end
		else begin
			transmission_index <= transmission_index + 5'd1;
		end
	end

	parameter WRITE = 1'b0;
	parameter BUS  = 7'b1110100;
	parameter HDMI = 7'b0111001;
	parameter BUS_W = {BUS, WRITE};
	parameter HDMI_W = {HDMI, WRITE};

	always @(*) begin
		case(transmission_index)
			5'd0: LAST_MESSAGE = 5'd1;
			default: LAST_MESSAGE = 5'd2;
		endcase

		case(transmission_index)
			5'd0: case(message_index)
				2'd0: message = BUS_W;
				2'd1: message = 8'b00100000;
				default: message = 8'h00;
			endcase
			5'd1: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h41;
				2'd2: message = 8'b00010000;
				default: message = 8'h00;
			endcase
			5'd2: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h98;
				2'd2: message = 8'h03;
				default: message = 8'h00;
			endcase
			5'd3: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9A;
				2'd2: message = 8'b11100000;
				default: message = 8'h00;
			endcase
			5'd4: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9C;
				2'd2: message = 8'h30;
				default: message = 8'h00;
			endcase
			5'd5: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h9D;
				2'd2: message = 8'b01100001;
				default: message = 8'h00;
			endcase
			5'd6: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hA2;
				2'd2: message = 8'hA4;
				default: message = 8'h00;
			endcase
			5'd7: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hA3;
				2'd2: message = 8'hA4;
				default: message = 8'h00;
			endcase
			5'd8: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hE0;
				2'd2: message = 8'hD0;
				default: message = 8'h00;
			endcase
			5'd9: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hF9;
				2'd2: message = 8'h00;
				default: message = 8'h00;
			endcase
			5'd10: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h15;
				2'd2: message = 8'h00;
				default: message = 8'h00;
			endcase
			5'd11: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h16;
				2'd2: message = 8'b00110100;
				default: message = 8'h00;
			endcase
			5'd12: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'h17;
				2'd2: message = 8'b00000010;
				default: message = 8'h00;
			endcase
			5'd13: case(message_index)
				2'd0: message = HDMI_W;
				2'd1: message = 8'hAF;
				2'd2: message = 8'b00000110;
				default: message = 8'h00;
			endcase
			default: message = 8'd0;
		endcase

		msg_bit = message[bit_index];

		last_bit = (bit_index == LAST_BIT);
		last_trans = (transmission_index == LAST_TRANSMISSION);
		last_msg = (message_index == LAST_MESSAGE);
	end
endmodule
