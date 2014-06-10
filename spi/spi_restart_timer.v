`default_nettype none

module spi_restart_timer(
	clock,
	reset,
	pulse,
	count,
	done
);

	input wire clock;
	input wire reset;
	input wire pulse;
	input wire count;

	output reg done;
	parameter COUNT = 4'd8;
	reg [3:0] counter = 4'd0;

	always @(posedge clock) begin
		if(reset || !count) begin
			counter <= 4'd0;
		end
		else if(!pulse) begin
			counter <= counter;
		end
		else if(done) begin
			counter <= 4'd0;
		end
		else begin
			counter <= counter + 4'd1;
		end
	end

	always @(*) begin
		done = (counter == COUNT);
	end
endmodule	
