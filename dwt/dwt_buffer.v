`default_nettype none

module dwt_buffer(
	// inputs
	clock,
	reset,    // hard reset
	clear,    // clears fist LEN-2 pixels from output
	enable,   // keep updating and cycling the buffer
	data_in,  // added to last element of buffer
	// outputs
	data_out, // LEN pixels, that will be used for processing
	ready     // signals when pixels have been updated
);

	parameter BW = 8;
	parameter LEN = 2;
	parameter ZERO = {BW{1'b0}};

	input wire clock;
	input wire reset;
	input wire clear;
	input wire enable;
	input wire [BW-1:0] data_in;
	
	output reg ready = 1'b0;
	output reg [LEN*BW-1:0] data_out;
	reg [BW-1:0] data_out_array [0:LEN-1];
	
	integer i;
	genvar j;
	generate
		for(j = 0;j < LEN;j=j+1) begin: map
			always @(*) begin
				data_out[(j+1)*BW-1:j*BW] = data_out_array[j];
			end
		end
	endgenerate
	
	reg update = 1'b0;
	reg [BW-1:0] buffer = ZERO;
	
	always @(posedge clock) begin
	
		// state variables
		// buffer holds value before it is added to output
		// ready indicates on-cycle that values have been updated
		// update indicates that on the next cycle, values will be updated
		// enable controls whether state is updated
		
		if(reset) begin
			update <= 1'b0;
			buffer <= ZERO;
			ready <= 1'b0;
		end
		else if(!enable) begin
			update <= update;
			buffer <= buffer;
			ready  <= ready;
		end
		else if(!update) begin
			update <= 1'b1;
			buffer <= data_in;
			ready  <= 1'b0;
		end
		else begin
			update <= 1'b0;
			buffer <= ZERO;
			ready  <= 1'b1;
		end
		
		// updating the buffer
		// if clear or reset is asserted, first LEN-2 pixels are cleared
		// if update is asserted, output will be shifted

		if(reset | clear) begin
			for(i = 0;i < LEN-2;i = i+1) begin
				data_out_array[i] <= ZERO;
			end
		end
		else if(update) begin
			for(i = 0;i < LEN-2;i = i+1) begin
				data_out_array[i] <= data_out_array[i+2];
			end
		end
		else begin
			for(i = 0;i < LEN-2;i = i+1) begin
				data_out_array[i] <= data_out_array[i];
			end
		end
		
		if(reset) begin
			data_out_array[LEN-2] <= ZERO;
			data_out_array[LEN-1] <= ZERO;
		end
		else if(update && enable) begin
			data_out_array[LEN-2] <= buffer;
			data_out_array[LEN-1] <= data_in;
		end
		else begin
			data_out_array[LEN-2] <= data_out_array[LEN-2];
			data_out_array[LEN-1] <= data_out_array[LEN-1];
		end
	end
endmodule