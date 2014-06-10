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

	reg [5:0] msg_index = 6'd0;
	parameter LAST_MSG = 6'd40;

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
			msg_index <= 6'd0;
		end
		else if(!inc_msg) begin
			msg_index <= msg_index;
		end
		else if(last_msg) begin
			msg_index <= 6'd0;
		end
		else begin
			msg_index <= msg_index + 6'd1;
		end
	end

	always @(*) begin
		case(msg_index)
			6'd0: begin
				address = 9'd2;
				data = 16'h0001;
			end
			6'd1: begin
				address = 9'd32;
				data = 16'h200C;
			end
			6'd2: begin
				address = 9'd20;
				data = 16'h0000;
			end
			6'd3: begin
				address = 9'd17;
				data = 16'h210F;
			end
			6'd4: begin
				address = 9'd26;
				data = 16'h1180;
			end
			6'd5: begin
				address = 9'd27;
				data = 16'hCCBC;
			end
			6'd6: begin
				address = 9'd8;
				data = 16'h0000;
			end
			6'd7: begin
				address = 9'd16;
				data = 16'h0003;
			end
			6'd8: begin
				address = 9'd9;
				data = 16'h0000;
			end
			6'd9: begin
				address = 9'd32;
				data = 16'h200E;
			end
			6'd10: begin
				address = 9'd34;
				data = 16'h0001;
			end
			6'd11: begin
				address = 9'd41;
				data = 16'h085A;
			end
			6'd12: begin
				address = 9'd129;
				data = 16'hE001;
			end
			6'd13: begin
				address = 9'd65;
				data = 16'h288B;
			end
			6'd14: begin
				address = 9'd66;
				data = 16'h53C6;
			end
			6'd15: begin
				address = 9'd67;
				data = 16'h0344;
			end
			6'd16: begin
				address = 9'd68;
				data = 16'h0085;
			end
			6'd17: begin
				address = 9'd70;
				data = 16'h4888;
			end
			6'd18: begin
				address = 9'd81;
				data = 16'h86A1;
			end
			6'd19: begin
				address = 9'd128;
				data = 16'h460F;
			end
			6'd20: begin
				address = 9'd176;
				data = 16'h00F5;
			end
			6'd21: begin
				address = 9'd180;
				data = 16'h00FD;
			end
			6'd22: begin
				address = 9'd181;
				data = 16'h0144;
			end
			6'd23: begin
				address = 9'd218;
				data = 16'h160B;
			end
			6'd24: begin
				address = 9'd224;
				data = 16'h3E13;
			end
			6'd25: begin
				address = 9'd456;
				data = 16'h0386;
			end
			6'd26: begin
				address = 9'd447;
				data = 16'h0BF1;
			end
			6'd27: begin
				address = 9'd448;
				data = 16'h0BC3;
			end
			6'd28: begin
				address = 9'd32;
				data = 16'h200F;
			end
			6'd29: begin
				address = 9'd10;
				data = 16'h0000;
			end
			6'd30: begin
				address = 9'd64;
				data = 16'h0001;
			end
			6'd31: begin
				address = 9'd72;
				data = 16'h0203;
			end
			6'd32: begin
				address = 9'd40;
				data = 16'h0003;
			end
			6'd33: begin
				address = 9'd48;
				data = 16'h0001;
			end
			6'd34: begin
				address = 9'd112;
				data = 16'h0007;
			end
			6'd35: begin
				address = 9'd199;
				data = 16'h002B;
			end
			6'd36: begin
				address = 9'd200;
				data = 16'h5DDF;
			end
			6'd37: begin
				address = 9'd201;
				data = 16'h0018;
			end
			6'd38: begin
				address = 9'd257;
				data = 16'h003C;
			end
			6'd39: begin
				address = 9'd258;
				data = 16'h0473;
			end
			6'd40: begin
				address = 9'd192;
				data = 16'h0001;
			end
			default: begin
				address = 9'd0;
				data = 16'd0;
			end
		endcase

		msg_bit = message[bit_index];
		last_bit = (bit_index == LAST_BIT);
		last_msg = (msg_index == LAST_MSG);
	end
endmodule
