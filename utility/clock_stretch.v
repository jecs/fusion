module clock_stretch(
	clock,
	reset,
	stretched
);

	parameter HALF_PERIOD = 32'd100000000;

	input wire clock;
	input wire reset;
	output reg stretched = 1'b0;
	reg [31:0] count = 32'd0;

	always @(posedge clock) begin
		if(reset) begin
			count <= 32'd0;
			stretched <= 1'b0;
		end
		else if(count == HALF_PERIOD-32'd1) begin
			count <= 32'd0;
			stretched <= ~stretched;
		end
		else begin
			count <= count + 32'd1;
			stretched <= stretched;
		end
	end
endmodule
