`default_nettype none

module start_timer(
	clock,
	reset,
	start,
	started
);

	parameter TIME = 32'd100000000; // 0.5s

	input wire clock;
	input wire reset;
	output reg start;
	output reg started = 1'b0;

	reg [31:0] count = 32'd0;

	always @(posedge clock) begin
		if(reset) begin
			count <= 32'd0;
		end
		else if(!started) begin
			count <= count + 32'd1;
		end
		else begin
			count <= count;
		end

		if(reset) begin
			started <= 1'b0;
		end	
		else if(!started) begin
			started <= start;
		end
		else begin
			started <= started;
		end
	end

	always @(*) begin
		start = (count == (TIME-32'd1));
	end
endmodule
