`define DWT_BW 8
`define INTERM_DWT_BW 9
`define DWT_IMG_WIDTH 10'd1024
`define DWT_IMG_HEIGHT 10'd768
`define MEM_ADDR_BW 20;
`define GRID_BW 10;
`define DWT_LEVELS 1

module haar_dwt(
	input clock,
	input reset,
	input start,
	// data in
	output reg [`MEM_ADDR_BW-1:0] mem_addr_read,
	output reg read,
	input reg [`DWT_BW-1:0] data_in,
	// data out
	output reg [`MEM_ADDR_BW-1:0] mem_addr_write,
	output reg write,
	output reg [`DWT_BW-1:0] data_out;
);

// intermediate data output
signed reg [`INTERM_DWT_BW-1:0] data_dif;
reg [`INTERM_DWT_BW-1:0] data_sum;

// processed data
reg [`DWT_BW-1:0] process_pixels[0:1];
reg [`DWT_BW-1:0] read_pixel;

// output grid coordinates
reg [`GRID_BW-1:0] out_r;
reg [`GRID_BW-1:0] out_c;

// input grid coordinates
reg [`GRID_BW-1:0] in_r;
reg [`GRID_BW-1:0] in_c;

// state
reg [4:0] state;

parameter H_LOAD = 7'b0000001; // load row-wise
parameter V_LOAD = 7'b0000010; // load column-wise
parameter HOR_HP = 7'b0000100; // highpass, row-wise
parameter HOR_LP = 7'b0001000; // lowpass, row-wise
parameter VER_HP = 7'b0010000; // highpass, column-wise
parameter VER_LP = 7'b0100000; // lowpass, column-wise
parameter STDBY  = 7'b1000000; // wait for start signal

// indicators of position
reg out_r_end;
reg out_c_end;
reg in_r_end;
reg in_c_end;

always @(*) begin
	out_r_end = (out_r == `DWT_IMG_HEIGHT - `GRID_BW'd1);
	out_c_end = (out_c == `DWT_IMG_WIDTH - `GRID_BW'd1);

	in_r_end = (in_r == `DWT_IMG_HEIGHT - `GRID_BW'd1);
	in_c_end = (in_c == `DWT_IMG_WIDTH - `GRID_BW'd1);
end

always @(posedge clock) begin
	if(reset) begin
		state <= STDBY;
	end
	else case(state)
	H_LOAD: begin
		if(in_c == `GRID_BW'd2)
			state <= HOR_LP;
		else
			state <= H_LOAD;
	end
	V_LOAD: begin
		if(in_r == `GRID_BW'd2)
			state <= VER_LP;
		else
			state <= V_LOAD;
	end
	HOR_LP: begin
		state <= HOR_HP;
	end
	HOR_HP: begin
		if(out_r_end && out_c_end)
			state <= V_LOAD;
		else
			state <= HOR_LP;
	end
	VER_LP: begin
		state <= VER_HP;
	end
	VER_HP: begin
		if(out_r_end && out_c_end)
			state <= STDBY;
		else
			state <= VER_LP;
	end	
	STDBY: begin
		if(start)
			state <= H_LOAD;
		else
			state <= STDBY;
	end
	default: begin
		state <= STDBY;
	end
	endcase
end

// reading
always @(posedge clock) begin
	if(reset) begin
		in_r <= `GRID_BW'd0;
		in_c <= `GRID_BW'd0;
		read <= 1'b0;
	end
	else case(state)
	H_LOAD: begin
		in_r <= in_r;
		in_c <= in_c + `GRID_BW'd1;
		read <= 1'b1;
	end
	V_LOAD: begin
		in_r <= in_r + `GRID_BW'd1;
		in_c <= in_c;
		read <= 1'b1;
	end
	HOR_LP: begin
		if(read) begin
			in_r <= in_r;
			in_c <= in_c + `GRID_BW'd1;
		end
		else begin
			in_r <= in_r;
			in_c <= in_c;
		end
		read <= read;
	end
	HOR_HP: begin
		if(!read) begin
			in_r <= in_r;
			in_c <= in_c;
		end
		else if(!in_c_end) begin
			in_r <= in_r;
			in_c <= in_c + `GRID_BW'd1;
		end
		else if(in_r_end) begin
			in_r <= `GRID_BW'd0;
			in_c <= `GRID_BW'd0;
		end
		else begin
			in_r <= in_r + `GRID_BW'd1;
			in_c <= `GRID_BW'd0;
		end

		if(!read) begin
			read <= (out_r_end & out_c_end);
		end
		else begin
			read <= ~(in_r_end & in_c_end);
		end
	end
	VER_LP: begin
		if(read) begin
			in_r <= in_r + `GRID_BW'd1;
			in_c <= in_c;
		end
		else begin
			in_r <= in_r;
			in_c <= in_c;
		end
		read <= read;
	end
	VER_HP: begin
		if(!read) begin
			in_r <= in_r;
			in_c <= in_c;
		end
		else if(!in_r_end) begin
			in_r <= in_r + `GRID_BW'd1;
			in_c <= in_c;
		end
		else if(in_c_end) begin
			in_r <= in_r;
			in_c <= in_c;
		end
		else begin
			in_r <= `GRID_BW'd0;
			in_c <= in_c + `GRID_BW'd1;
		end
	end
	STDBY, default: begin
		in_r <= `GRID_BW'd0;
		in_c <= `GRID_BW'd0;
		read <= start;
	end
	endcase
end

// writing
always @(*) begin
	if(reset) begin
		write = 1'b0;
	end
	else case(state)
	HOR_LP, HOR_HP, VER_LP, VER_HP: begin
		write = 1'b1;
	end
	default: begin
		write = 1'b0;
	end
	endcase
end

always @(posedge clock) begin
	if(reset) begin
		out_r <= `GRID_BW'd0;
		out_c <= `GRID_BW'd0;
	end
	else case(state)
	HOR_LP: begin
		out_r <= out_r;
		out_c <= out_c + (`DWT_IMG_WIDTH >> 1);
	end
	HOR_HP: begin
		if(!out_c_end) begin
			out_r <= out_r;
			out_c <= out_c + `GRID_BW'd1 - (`DWT_IMG_WIDTH >> 1);
		end
		else if(!out_r_end) begin
			out_r <= out_r + `GRID_BW'd1;
			out_c <= `GRID_BW'd0;
		end
		else begin
			out_r <= `GRID_BW'd0;
			out_c <= `GRID_BW'd0;
		end
	end
	VER_LP: begin
		out_r <= out_r + (`DWT_IMG_HEIGHT >> 1);
		out_c <= out_c;
	end
	VER_HP: begin
		if(!out_r_end) begin
			out_r <= out_r + `GRID_BW'd1 - (`DWT_IMG_WIDTH >> 1);
			out_c <= out_c;
		end
		else if(!out_c_end) begin
			out_r <= `GRID_BW'd0;
			out_c <= out_c + `GRID_BW'd1;
		end
		else begin
			out_r <= `GRID_BW'd0;
			out_c <= `GRID_BW'd0;
		end
	end
	H_LOAD, V_LOAD, STDBY, default: begin
		out_r <= `GRID_BW'd0;
		out_c <= `GRID_BW'd0;
	end
	endcase
end

// data read and write
always @(posedge clock) begin
	// save last (N-1) pixels
	// in this case N = 2
	if(reset) begin
		read_pixel <= `DWT_BW'd0;
	end
	else begin
		read_pixel <= data_in;
	end

	if(reset) begin
		processed_pixels[0] <= `DWT_BW'd0;
		processed_pixels[1] <= `DWT_BW'd1;
	end
	else case(state)
	H_LOAD: begin
		if(in_c == `GRID_BW'd2) begin
			processed_pixels[0] <= read_pixel;
			processed_pixels[1] <= data_in;
		end
		else
			read_pixels[0] <= read_pixels[0];
			read_pixels[1] <= read_pixels[1];
		end
	end
	V_LOAD: begin
		if(in_r == `GRID_BW'd2) begin
			processed_pixels[0] <= read_pixel;
			processed_pixels[1] <= data_in;
		end
		else
			read_pixels[0] <= read_pixels[0];
			read_pixels[1] <= read_pixels[1];
		end
	end
	HOR_HP, VER_HP: begin
		processed_pixels[0] <= read_pixel;
		processed_pixels[1] <= data_in;
	end	
	HOR_LP, VER_LP: begin
		processed_pixels[0] <= processed_pixels[0];
		processed_pixels[1] <= processed_pixels[1];
	end
	STDBY, default: begin
		processed_pixels[0] <= `DWT_BW'd0;
		processed_pixels[1] <= `DWT_BW'd1;
	end
	endcase
end

// TODO: revise this section; make sure division is carried out appropriately
always @(*) begin
	if(reset) begin
		data_out = `DWT_BW'd0;
		data_sum = `INTERM_DWT_BW'd0;
		data_dif = `INTERM_DWT_BW'd0;
	end
	else case(state)
	HOR_LP, VER_LP: begin
		data_out = data_sum[`INTERM_DWT_BW-1:1];
		data_sum = {0, processed_pixels[0]} + {0, processed_pixels[1]};
		data_dif = `INTERM_DWT_BW'd0;
	end
	HOR_HP, VER_HP: begin
		data_out = data_dif[`INTERM_DWT_BW-1:1];
		data_sum = `INTERM_DWT_BW'd0;
		data_dif = $signed({0, processed_pixels[0]}) - $signed({0, processed_pixels[1]});
	end
	default: begin
		data_out = `DWT_BW'd0;
		data_sum = `INTERM_DWT_BW'd0;
		data_dif = `INTERM_DWT_BW'd0;
	end
end

// TODO: address calculation
always @(*) begin
	mem_addr_read = in_r*`DWT_IMG_WIDTH + in_c;
	mem_addr_write = out_r*`DWT_IMG_HEIGHT + out_c;
end

endmodule
