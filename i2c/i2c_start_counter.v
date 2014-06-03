`default_nettype none

module i2c_start_counter(
	clock,
	reset,
	start
);

	input wire clock;
	input wire reset;
	output reg start = 1'b0;

	parameter CYCLES=28'd100000000;
	//parameter CYCLES = 28'd1000;
	reg [27:0] cycle_count = 28'd0;

	always @(posedge clock) begin
		if(reset) begin
			cycle_count <= 28'd0;
		end
		else if(cycle_count == CYCLES) begin
			cycle_count <= cycle_count;
		end
		else begin
			cycle_count <= cycle_count + 28'd1;
		end

		start <= (~reset) & (cycle_count == (CYCLES-28'd1));
	end
endmodule
