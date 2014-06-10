`default_nettype none

module spi_start_timer(
	clock,
	reset,
	start
);

	input wire clock;
	input wire reset;
	output reg start;

	reg counting = 1'b1;
	parameter COUNT = 28'd150000000; // 0.75s
	//parameter COUNT = 28'd100;
	parameter ZERO = 28'd0;
	parameter ONE = 28'd1;
	reg [27:0] count = 28'd0;

	always @(posedge clock) begin
		if(reset || !counting || start) begin
			count <= ZERO;
		end
		else begin
			count <= count + ONE;
		end

		if(reset) begin
			counting <= 1'b1;
		end
		else if(start) begin
			counting <= 1'b0;
		end
		else begin
			counting <= counting;
		end
	end

	always @(*) begin
		start = (count == COUNT-ONE);
	end
endmodule
