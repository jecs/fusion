`default_nettype none

module demultiplex(
	ser_clock,
	par_clock,
	data_in_p,
	data_in_n,
	select,
	data_out,
	data_ext,
);

	input wire ser_clock;
	input wire par_clock;
	input wire data_in_p;
	input wire data_in_n;
	input wire [7:0] select;
	output wire [7:0] data_out;
	output reg [14:0] data_ext;

	reg [6:0] old_data;
	wire [7:0] demuxed_data;

	demultiplexer demux (
		.data_in_from_pins_p(data_in_p),
		.data_in_from_pins_n(data_in_n),
		.clk_in(ser_clock),
		.clk_div_in(par_clock),
		.io_reset(1'b0),
		.bitslip(1'b0),
		.data_in_to_device(demuxed_data)
	);

	always @(posedge par_clock) begin
		old_data <= demuxed_data[6:0];
	end

	always @(*) begin
		data_ext = {old_data, demuxed_data};
		casex(select)
			8'b1XXXXXXX: data_out = data_ext[14:7];
			8'b01XXXXXX: data_out = data_ext[13:6];
			8'b001XXXXX: data_out = data_ext[12:5];
			8'b0001XXXX: data_out = data_ext[11:4];
			8'b00001XXX: data_out = data_ext[10:3];
			8'b000001XX: data_out = data_ext[9:2];
			8'b0000001X: data_out = data_ext[8:1];
			8'b00000001: data_out = data_ext[7:0];
			8'b00000000: data_out = 8'b00000000;
		endcase
	end
endmodule
