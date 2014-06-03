module debounce(
	clock,
	reset,
	noisy,
	clean
);

input wire clock;
input wire reset;
input wire noisy;

parameter DEFAULT = 1'b0;
output reg clean = DEFAULT;
reg past_value = DEFAULT;

parameter COUNT_LIMIT = 28'd14850000; // 1/10 of a second
reg [27:0] count = 28'd0;

always @(posedge clock) begin
	if(reset) begin
		count <= 28'd0;
		clean <= DEFAULT;
	end
	else if(noisy != past_value) begin
		count <= 28'd0;
		clean <= clean;
	end
	else if(count == COUNT_LIMIT) begin
		count <= 28'd0;
		clean <= noisy;
	end
	else begin
		count <= count + 28'd1;
		clean <= clean;
	end

	past_value <= noisy;
end

endmodule
