module haar_filterbank(
	// inputs
	clock,
	reset,
	enable, // should be enabled when pixels are valid and available
	// outputs
	pixels_in, // should remain constant until out_low goes from HIGH to LOW
	pixel_out, // when out_low == 0, LF pixel; else, HF pixel
	region     // LF: 0, HF: 1
);

	parameter IB=8;

	input wire clock;
	input wire reset;
	input wire enable;
	input wire [IB-1:0] pixels_in[0:1];
	
	reg low = 1'b0;
	output reg [IB-1:0] pixel_out;
	
	signed reg [IB:0] signed_pixels_in[0:1];
	signed reg [IB:0] signed_pixel_difference;
	
	always @(*) begin
		signed_pixels_in[0] = {0, pixels_in[0]};
		signed_pixels_in[1] = {0, pixels_in[1]};
		signed_pixel_difference = ({signed_pixels_in[1] - signed_pixels[0]} >>> 1) + IB'sd128;
	end
	
	always @(posedge clock) begin
		if(reset || !enable) begin
			low <= 1'b0;
			region <= 1'b0;
			pixel_out <= IB'd0;
		end
		else if(!low) begin
			low <= 1'b1;
			region <= 1'b0;
			pixel_out <= ({0, pixels_in[0]} + {0, pixels_in[0]}) >> 1;
		end
		else begin
			low <= 1'b0;
			region <= 1'b1;
			pixel_out <= signed_pixel_difference[IB-1:0];
		end
	end
endmodule