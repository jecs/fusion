module data_record(
	pclock,
	reset,
	record,
	end_line,
	end_frame,
	data_in,
	write_addr,
	we,
	data_out,
	LL
);

	input wire pclock;
	input wire reset;
	input wire record;
	input wire end_line;
	input wire end_frame;
	input wire [63:0] data_in;

	output reg [18:0] write_addr = 19'd0;
	output reg we = 1'b0;
	output reg [63:0] data_out = 64'd0;
	output reg LL;

	parameter Y_START = 11'd1919;
	parameter Y_END   = 11'd0;
	parameter X_START = 8'd0;
	parameter X_COUNT = 8'd240;

	reg [10:0] y = Y_START;
	reg [7:0]  x = X_START;

	always @(posedge pclock) begin
		if(reset || end_line || end_frame) begin
			x <= X_START;
		end
		else if(record) begin
			x <= x + 8'd1;
		end
		else begin
			x <= x;
		end

		if(reset || end_frame) begin
			y <= Y_START;
		end
		else if(end_line) begin
			y <= y - 11'd1;
		end
		else begin
			y <= y;
		end

		if(reset) begin
			write_addr <= Y_START*X_COUNT+X_START;
			we <= 1'b0;
			data_out <= 64'd0;
		end
		else begin
			write_addr <= y*X_COUNT + x;
			we <= record;
			data_out <= data_in;
		end
	end

	always @(*) begin
		LL = (y == Y_END);
	end
endmodule
