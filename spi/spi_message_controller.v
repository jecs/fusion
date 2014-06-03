`default_nettype none

module spi_message_controller(
	clock,
	reset,
	inc_bit,
	inc_msg,
	last_bit,
	last_msg,
	msg_bit
);

	input wire clock;
	input wire reset;

	input wire inc_bit;
	input wire inc_msg;

	output reg last_bit;
	output reg last_msg;

	output reg msg_bit;

	reg [4:0] bit_index = 5'd0;
	parameter LAST_BIT = 5'd25;

	reg [4:0] msg_index = 5'd0;
	parameter LAST_MSG = 5'd1;

	wire [0:25] message;
	reg [0:8] address;
	reg [0:15] data;

	assign message = {address, 1'b1, data};
	
	always @(posedge clock) begin
		if(reset) begin
			bit_index <= 5'd0;
		end
		else if(!inc_bit) begin
			bit_index <= bit_index;
		end
		else if(last_bit) begin
			bit_index <= 5'd0;
		end
		else begin
			bit_index <= bit_index + 5'd1;
		end

		if(reset) begin
			msg_index <= 5'd0;
		end
		else if(!inc_msg) begin
			msg_index <= msg_index;
		end
		else if(last_msg) begin
			msg_index <= 5'd0;
		end
		else begin
			msg_index <= msg_index + 5'd1;
		end
	end

	always @(*) begin
		case(msg_index)
			5'd0: begin
				address = 9'b010101010;
				data = 15'b000111000111000;
			end
			5'd1: begin
				address = 9'b101010101;
				data = 15'b111000111000111;
			end
			default: begin
				address = 9'd0;
				data = 15'd0;
			end
		endcase

		msg_bit = message[bit_index];
		last_bit = (bit_index == LAST_BIT);
		last_msg = (msg_index == LAST_MSG);
	end
endmodule	
