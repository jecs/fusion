module lvds_in_to_cmos (
	in_p,
	in_n,
	out_s
);

	parameter BUS_WIDTH = 1;

	input wire [BUS_WIDTH-1:0] in_p;
	input wire [BUS_WIDTH-1:0] in_n;

	output wire [BUS_WIDTH-1:0] out_s;

	genvar i;
	generate
		for(i = 0;i < BUS_WIDTH;i=i+1) begin: BUFFER
			IBUFDS #( 
				.DIFF_TERM("TRUE"), // Differential Termination 
				.IBUF_LOW_PWR("TRUE"), // Low power="TRUE", Highest performance="FALSE" 
				.IOSTANDARD("DEFAULT") // Specify the input I/O standard 
			) buffer ( 
				.O(out_s[i]), // Buffer output 
				.I(in_p[i]), // Diff_p buffer input (connect directly to top-level port) 
				.IB(in_n[i]) // Diff_n buffer input (connect directly to top-level port) 
			); 
		end
	endgenerate
endmodule

module lvds_in_to_cmos_clock (
	clock_p,
	clock_n,
	clock
);

	input wire clock_p;
	input wire clock_n;
	output wire clock;
	
	IBUFGDS #(
		.DIFF_TERM("TRUE"), // Differential Termination
		.IBUF_LOW_PWR("TRUE"), // Low power="TRUE", Highest performance="FALSE"
		.IOSTANDARD("DEFAULT") // Specify the input I/O standard
	) clock_buf (
		.O(clock), // Clock buffer output
		.I(clock_p), // Diff_p clock buffer input (connect directly to top-level port)
		.IB(clock_n) // Diff_n clock buffer input (connect directly to top-level port)
	);
endmodule
