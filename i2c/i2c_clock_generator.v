`default_nettype none
//`define TESTING_I2C

module i2c_clock_generator(
	clock,
	reset,
	scl,
	cl_low,
	cl_high
);

	`ifdef TESTING_I2C	
		parameter PERIOD      = 21'd1000;
	`else
		parameter PERIOD      = 21'd2000000;
	`endif
	parameter HALF_PERIOD = PERIOD >> 1;
	parameter QUAR_PERIOD = PERIOD >> 2;

	parameter ZERO = 21'd0;
	parameter ONE = 21'd1;

	input wire clock;
	input wire reset;
	output reg scl = 1'b0;
	output reg cl_low = 1'b0;
	output reg cl_high = 1'b0;
	
	reg [20:0] counter = ZERO;

	always @(posedge clock) begin
		if(reset || counter == (PERIOD-ONE)) begin
			counter <= ZERO;
		end
		else begin
			counter <= counter + ONE;
		end

		if(reset) begin
			scl <= 1'b0;
		end
		else if(counter == (HALF_PERIOD-ONE)) begin
			scl <= 1'b1;
		end
		else if(counter == (PERIOD-ONE)) begin
			scl <= 1'b0;
		end
		else begin
			scl <= scl;
		end

		if(reset || counter != (HALF_PERIOD-QUAR_PERIOD-ONE)) begin
			cl_low <= 1'b0;
		end
		else begin
			cl_low <= 1'b1;
		end

		if(reset || counter != (HALF_PERIOD+QUAR_PERIOD-ONE)) begin
			cl_high <= 1'b0;
		end
		else begin
			cl_high <= 1'b1;
		end
	end
endmodule
