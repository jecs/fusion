`default_nettype none

module data_capture(
	pclock,
	reset,
	data,
	record_in,
	pixels,
	record_out
);

	input wire pclock;
	input wire reset;
	input wire [3:0] data;
	input wire record_in;
	output reg [63:0] pixels = 64'd0; // 0th pixel first, MSB first
	output reg record_out = 1'b0;
	
	reg [1:0] bin_count = 2'd0;
	reg [3:0] fdata; // flipped data

	wire [7:0] pixel0;
	wire [7:0] pixel1;
	wire [7:0] pixel2;
	wire [7:0] pixel3;
	wire [7:0] pixel4;
	wire [7:0] pixel5;
	wire [7:0] pixel6;
	wire [7:0] pixel7;

	assign pixel0 = pixels[63:56];
	assign pixel1 = pixels[55:48];
	assign pixel2 = pixels[47:40];
	assign pixel3 = pixels[39:32];
	assign pixel4 = pixels[31:24];
	assign pixel5 = pixels[23:16];
	assign pixel6 = pixels[15:8];
	assign pixel7 = pixels[7:0];

	always @(posedge pclock) begin
		if(reset) begin
			bin_count <= 2'd0;
		end
		else if(record_in) begin
			bin_count <= bin_count + 2'd1;
		end
		else begin
			bin_count <= bin_count;
		end
		
		if(reset) begin
			pixels <= 64'd0;
		end
		// bc   pixel@sensor
		//   | 3 | 2 | 1 | 0 |
		//   -----------------
		// 0 | 0 | 2 | 4 | 6 |
		// 1 | 1 | 3 | 5 | 7 |
		// 2 | 7 | 5 | 3 | 1 |
		// 3 | 6 | 4 | 2 | 0 |
		else case(bin_count)
			4'd0, 4'd3: begin
				pixels[63:56] <= {pixels[62:56], fdata[3]};
				pixels[55:48] <= pixels[55:48];
				pixels[47:40] <= {pixels[46:40], fdata[2]};
				pixels[39:32] <= pixels[39:32];
				pixels[31:24] <= {pixels[30:24], fdata[1]};
				pixels[23:16] <= pixels[23:16];
				pixels[15:8]  <= {pixels[14:8],  fdata[0]};
				pixels[7:0]   <= pixels[7:0];
			end
			4'd1, 4'd2: begin
				pixels[63:56] <= pixels[63:56];
				pixels[55:48] <= {pixels[54:48], fdata[3]};
				pixels[47:40] <= pixels[47:40];
				pixels[39:32] <= {pixels[38:32], fdata[2]};
				pixels[31:24] <= pixels[31:24];
				pixels[23:16] <= {pixels[22:16], fdata[1]};
				pixels[15:8]  <= pixels[15:8];
				pixels[7:0]   <= {pixels[6:0],   fdata[0]};
			end
		endcase

		record_out <= record_in & bin_count[0];
	end

	always @(*) begin
		fdata = (!bin_count[1]) ? data : {data[0], data[1], data[2], data[3]}; // FIX ME
	end
endmodule
