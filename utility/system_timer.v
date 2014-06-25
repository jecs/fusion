`default_nettype none

module system_timer(
	clock,
	reset,
	trigger,
	activate
);

	parameter NUMBER = 1;
	parameter TIMES  = {NUMBER{32'd1}};
	
	input wire clock;
	input wire reset;
	
	output reg [NUMBER-1:0] trigger;
	output reg [NUMBER-1:0] activate;
	
	reg [NUMBER-1:0] triggered = {NUMBER{1'b0}};
	reg [31:0] timer = 32'd0;
	
	always @(posedge clock) begin
		if(reset || &triggered) begin
			timer <= 32'd0;
		end
		else begin
			timer <= timer + 32'd1;
		end
	end
	
	genvar i;
	generate
		for(i=0;i < NUMBER;i=i+1) begin: TRIGGER
			always @(*) begin
				trigger[i] = (timer == (TIMES[31+32*i:32*i]-32'd1));
				activate[i] = trigger[i] | triggered[i];
			end
			always @(posedge clock) begin
				triggered[i] <= (~reset) & activate[i];
			end
		end
	endgenerate
endmodule