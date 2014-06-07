`default_nettype none

module i2c_message_controller_fsm(
	clock,
	reset,
	inc_bit,
	inc_msg,
	inc_trans,
	index_bit,
	index_msg,
	index_trans,
	last_bit,
	last_msg,
	last_trans,
	LIMIT_BIT,
	LIMIT_MSG,
	LIMIT_TRANS
);

	parameter BI_BW = 3;
	parameter MI_BW = 2;
	parameter TI_BW = 5;

	input wire clock;
	input wire reset;

	input wire inc_bit;
	input wire inc_msg;
	input wire inc_trans;

	output reg [BI_BW-1:0] index_bit = 0;
	output reg [MI_BW-1:0] index_msg = 0;
	output reg [TI_BW-1:0] index_trans = 0;

	output reg last_bit;
	output reg last_msg;
	output reg last_trans;

	input wire [2:0] LIMIT_BIT;
	input wire [1:0] LIMIT_MSG;
	input wire [4:0] LIMIT_TRANS;

	always @(*) begin
		last_bit   = (index_bit   == LIMIT_BIT);
		last_msg   = (index_msg   == LIMIT_MSG);
		last_trans = (index_trans == LIMIT_TRANS);
	end

	always @(posedge clock) begin
		if(reset) begin
			index_bit <= 0;
		end
		else if(!inc_bit) begin
			index_bit <= index_bit;
		end
		else if(last_bit) begin
			index_bit <= 0;
		end
		else begin
			index_bit <= index_bit + 1;
		end

		if(reset) begin
			index_msg <= 0;
		end
		else if(!inc_msg) begin
			index_msg <= index_msg;
		end
		else if(last_msg) begin
			index_msg <= 0;
		end
		else begin
			index_msg <= index_msg + 1;
		end

		if(reset) begin
			index_trans <= 0;
		end
		else if(!inc_trans) begin
			index_trans <= index_trans;
		end
		else if(last_trans) begin
			index_trans <= 0;
		end
		else begin
			index_trans <= index_trans + 1;
		end
	end
endmodule
