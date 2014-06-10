module sync_capture(
	pclock,
	reset,
	sync_bit,
	FS,
	FE,
	LS,
	LE,
	IMG,
	ID
);

	input wire pclock;
	input wire reset;
	input wire sync_bit;
	output reg FS;
	output reg FE;
	output reg LS;
	output reg LE;
	output reg IMG;
	output reg ID;

	reg [6:0] old_sync_bits = 7'd0;
	reg [7:0] sync_bits;
	reg [3:0] id_count = 4'd0;

	always @(posedge pclock) begin
		if(reset) begin
			old_sync_bits <= 7'd0;
		end
		else begin
			old_sync_bits <= sync_bits;
		end

		if(reset) begin
			id_count <= 4'd0;
		end
		else if(id_count != 4'd0) begin
			id_count <= (id_count == 4'd8) ? 4'd0 : (id_count+4'd1);
		end
		else if(FS || FE || LS || LE) begin
			id_count <= 4'd1;
		end
		else begin
			id_count <= 4'd0;
		end
	end

	parameter FRAME_START = 8'b10101010;
	parameter FRAME_END   = 8'b11001010;
	parameter LINE_START  = 8'b00101010;
	parameter LINE_END    = 8'b01001010;
	parameter VALID_DATA  = 8'h0D;
	parameter ID_COUNT    = 4'd8;

	always @(*) begin
		sync_bits = {old_sync_bits, sync_bit};
		FS =  (sync_bits == FRAME_START);
		FE =  (sync_bits == FRAME_END);
		LS =  (sync_bits == LINE_START);
		LE =  (sync_bits == LINE_END);
		IMG = (sync_bits == VALID_DATA);
		ID =  (id_count == ID_COUNT);
	end
endmodule
