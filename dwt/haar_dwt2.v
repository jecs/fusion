`default_nettype none

module haar_dwt(
	clock,
	reset,
	new_frame,
	addr_in,
	data_in,
	addr_out,
	data_out,
	we,
	on_switch,
	off_switch,
	disabled,
	transposing,
	levels
);

	input wire clock;
	input wire reset;
	input wire new_frame;
	output reg [17:0] addr_in;
	input wire [7:0] data_in;
	output reg [17:0] addr_out;
	output wire [7:0] data_out;
	output reg we;
	output reg on_switch;
	output reg off_switch;
	output reg disabled;
	output reg transposing = 1'b0;
	input [3:0] levels;
	
	reg [8:0] in_x = 9'd0;
	reg [8:0] in_y = 9'd0;
	reg [8:0] out_x = 9'd0;
	reg [8:0] out_y = 9'd0;
	
	reg buffer_enable;
	reg buffer_reset;
	reg buffer_clear;
	
	reg filter_enable;
	reg filter_reset;
	
	wire [15:0] pixels;
	wire buffer_ready;
	wire filter_region;
	
	parameter IDLE       = 3'b001;
	parameter STARTING   = 3'b010;
	parameter PROCESSING = 3'b100;
	reg [2:0] state = IDLE;
	
	haar_filterbank hfb(
		.clock(clock),
		.reset(reset | filter_reset),
		.enable(filter_enable),  // should be enabled when pixels are valid and available
		.pixels_in(pixels),      // should remain constant until region goes from HIGH to LOW
		.pixel_out(data_out),    // LEN pixels, that will be used for processing
		.region(filter_region) // signals when pixels have been updated
	);
	
	dwt_buffer dwtb(
		// inputs
		.clock(clock),
		.reset(reset),
		.clear(buffer_clear),
		.enable(buffer_enable), // should be kept high; guarantees valid pixels in two cycles
		.data_in(data_in),      // single pixel; should be valid when enable is called
		// outputs
		.data_out(pixels),      // LEN pixels, that will be used for processing
		.ready(buffer_ready)    // signals when pixels have been updated
	);
	
	reg last_row_read;
	reg last_col_read;
	reg last_read;
	reg last_row_write;
	reg last_col_write;
	reg last_write;
	reg finished_starting;
	reg finished_ending;
	
	reg start_processing;
	reg start_filter;
	
	parameter WIDTH  = 9'd511; // plus 1
	parameter HEIGHT = 9'd511; // plus 1
	
	reg continuing;
	reg [3:0] current_level = 4'd0;
	
	reg [8:0] x_limit = WIDTH;
	reg [8:0] y_limit = HEIGHT;
	reg [8:0] next_x_limit;
	reg [8:0] next_y_limit;
	
	always @(*) begin
		last_row_read = (in_x == x_limit);
		last_col_read = (in_y == y_limit);
		last_read = last_row_read & last_col_read;
		
		last_row_write = (out_x == x_limit);
		last_col_write = (out_y == y_limit);
		last_write = last_row_write & last_col_write;
		
		start_filter = (in_x == 9'd1 && in_y == 9'd0);
		start_processing = (in_x == 9'd2 && in_y == 9'd0);
	end
	
	always @(posedge clock) begin
		if(reset) begin
			in_x <= 9'd0;
			in_y <= 9'd0;
			out_x <= 9'd0;
			out_y <= 9'd0;
			
			state <= IDLE;
			transposing <= 1'b0;
			current_level <= 4'd0;
			x_limit <= WIDTH;
			y_limit <= HEIGHT;
			
			buffer_reset <= 1'b0;
			buffer_enable <= 1'b0;
			
			filter_reset <= 1'b0;
			filter_enable <= 1'b0;
		end
		else case(state)
			IDLE: begin
				in_x <= new_frame ? 9'd1 : 9'd0;
				in_y <= 9'd0;
				
				out_x <= 9'd0;
				out_y <= 9'd0;
				
				state <= (new_frame && (levels != 4'd0)) ? STARTING : IDLE;
				transposing <= 1'b0;
				current_level <= 4'd0;
				x_limit <= WIDTH;
				y_limit <= HEIGHT;
				
				buffer_reset <= 1'b0;
				buffer_enable <= new_frame;
				
				filter_reset <= 1'b0;
				filter_enable <= 1'b0;
			end
			STARTING: begin
				in_x <= in_x + 9'd1;
				in_y <= in_y;
				
				out_x <= 9'd0;
				out_y <= 9'd0;
				
				state <= start_processing ? PROCESSING : STARTING;
				transposing <= transposing;
				current_level <= current_level;
				x_limit <= x_limit;
				y_limit <= y_limit;
				
				buffer_reset <= 1'b0;
				buffer_enable <= 1'b1;
				
				filter_reset <= 1'b0;
				filter_enable <= filter_enable | start_filter;
			end
			PROCESSING: begin
				if(in_x == 9'd0 && in_y == 9'd0) begin
					in_x <= 9'd0;
					in_y <= 9'd0;
				end
				else if(!last_row_read) begin
					in_x <= in_x + 9'd1;
					in_y <= in_y;
				end
				else if(!last_col_read) begin
					in_x <= 9'd0;
					in_y <= in_y + 9'd1;
				end
				else begin
					in_x <= 9'd0;
					in_y <= 9'd0;
				end

				
				if(!last_row_write) begin
					out_x <= (out_x <= next_x_limit) ? (out_x + next_x_limit + 9'd1) : (out_x - next_x_limit);
					out_y <= out_y;
				end
				else if(!last_col_write) begin
					out_x <= 9'd0;
					out_y <= out_y + 9'd1;
				end
				else begin
					out_x <= 9'd0;
					out_y <= 9'd0;
				end
				
				if(!last_write) begin
					state <= PROCESSING;
					transposing <= transposing;
					current_level <= current_level;
					x_limit <= x_limit;
					y_limit <= y_limit;
				end
				else if(!continuing) begin
					state <= IDLE;
					transposing <= 1'b0;
					current_level <= 4'd0;
					x_limit <= WIDTH;
					y_limit <= HEIGHT;
				end
				else if(transposing) begin
					state <= STARTING;
					transposing <= 1'b0;
					current_level <= current_level + 4'd1;
					x_limit <= next_x_limit;
					y_limit <= next_y_limit;
				end
				else begin
					state <= STARTING;
					transposing <= 1'b1;
					current_level <= current_level;
					x_limit <= x_limit;
					y_limit <= y_limit;
				end

				buffer_reset <= last_write & ~continuing;
				buffer_enable <= (buffer_enable & ~last_read) | (last_write & continuing);
				
				filter_reset <= last_write;
				filter_enable <= ~last_write;
			end
		endcase
	end
	
	always @(*) begin
		addr_in  = (transposing == 1'b0) ? {in_y, in_x} : {in_x, in_y};
		addr_out = (transposing == 1'b0) ? {out_y, out_x} : {out_x, out_y};
		buffer_clear = start_processing;
		we = (state == PROCESSING);
		continuing = ~((current_level == (levels-4'd1)) && (transposing == 1'b1));
		next_x_limit = {1'b0, x_limit[8:1]};
		next_y_limit = {1'b0, y_limit[8:1]};
		on_switch  = ~disabled & (last_write == 1'b1 && current_level == 4'd0 && transposing == 1'b0);
		off_switch = ~disabled & (last_write == 1'b1 && continuing == 1'b0);
		disabled = (levels == 4'd0);
	end
endmodule
