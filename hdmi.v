`default_nettype none

`include "hdmi.h"

module hdmi_generator
(
	input wire clock,
	input wire reset,
	output reg hs,
	output reg vs,
	output reg de,
	output reg vclock,
	output reg request,
	// x and y associated with current timestep
	// values will be delayed later on, in another module
	output reg [`HBW-1:0] x,
	output reg [`VBW-1:0] y
);

reg hde;
reg vde;
reg [`HBW-1:0] hcount;
reg [`VBW-1:0] vcount;

reg end_of_hfp;
reg end_of_hsync;
reg end_of_hvis;
reg end_of_hbp;

reg end_of_vfp;
reg end_of_vsync;
reg end_of_vvis;
reg end_of_vbp;

// triggers for the different regions
always @(*) begin
	end_of_hsync = (hcount == `HSYNC-`HBW'd1);
	end_of_hfp   = (hcount == `HSYNC+`HFP-`HBW'd1);
	end_of_hvis  = (hcount == `HSYNC+`HFP+`HRES-`HBW'd1);
	end_of_hbp   = (hcount == `HTOT-`HBW'd1);

	end_of_vsync = (vcount == `VSYNC-`VBW'd1);
	end_of_vfp   = (vcount == `VSYNC+`VFP-`VBW'd1);
	end_of_vvis  = (vcount == `VSYNC+`VFP+`VRES-`VBW'd1);
	end_of_vbp   = (vcount == `VTOT-`VBW'd1);
end

// vcount & hcount
always @(posedge clock) begin
	if(reset || end_of_hbp) begin
		hcount <= `HBW'd0;
	end
	else begin
		hcount <= hcount + `HBW'd1;
	end

	if(reset) begin
		vcount <= `VBW'd0;
	end
	else if(!end_of_hbp) begin
		vcount <= vcount;
	end
	else if(!end_of_vbp) begin
		vcount <= vcount + `VBW'd1;
	end
	else begin
		vcount <= `VBW'd0;
	end
end

// hsync & vsync
always @(posedge clock) begin
	if(reset || end_of_hbp) begin
		hs <= 1'b1;
	end
	else if(end_of_hsync) begin
		hs <= 1'b0;
	end
	else begin
		hs <= hs;
	end

	if(reset) begin
		vs <= 1'b1;
	end
	else if(end_of_vsync && end_of_hbp) begin
		vs <= 1'b0;
	end
	else begin
		vs <= vs;
	end
end

// x & y
always @(posedge clock) begin
	if(reset) begin
		x <= `HBW'd0;
	end
	else if(end_of_hvis) begin
		x <= `HBW'd0;
	end
	else if(de) begin
		x <= x + `HBW'd1;
	end
	else begin
		x <= x;
	end

	if(reset) begin
		y <= `VBW'd0;
	end
	else if(!end_of_hvis) begin
		y <= y;
	end
	else if(end_of_vvis) begin
		y <= `VBW'd0;
	end
	else if(de) begin
		y <= y + `VBW'd1;
	end
	else begin
		y <= y;
	end
end

// vde, hde, & de
always @(posedge clock) begin
	if(reset) begin
		hde <= 1'b0;
	end
	else if(end_of_hfp) begin
		hde <= 1'b1;
	end
	else if(end_of_hvis) begin
		hde <= 1'b0;
	end
	else begin
		hde <= hde;
	end

	if(reset) begin
		vde <= 1'b0;
	end
	else if(!end_of_hbp) begin
		vde <= vde;
	end
	else if(end_of_vfp) begin
		vde <= 1'b1;
	end
	else if(end_of_vvis) begin
		vde <= 1'b0;
	end
	else begin
		vde <= vde;
	end
end

always @(*) begin
	de = hde & vde;
end

always @(*) begin
	vclock = ~clock;
end

endmodule

module  hdmi_test_pattern_generator
(
	input wire clock,
	input wire reset,
	input wire hs_in,
	input wire vs_in,
	input wire de_in,
	input wire vclock_in,
	input wire [`HBW-1:0] x,
	input wire [`VBW-1:0] y,
	output reg hs_out,
	output reg vs_out,
	output reg de_out,
	output reg vclock_out,
	output [`PBW-1:0] reg data_out
);

reg intensity;

always @(posedge clock) begin
	hs_out <= hs_in;
	vs_out <= vs_in;
	de_out <= de_in;
	intensity <= (x[4:0] < 5'd16) & (y[4:0] < 5'd16);
end

always @(*) begin
	vclock_out = vclock_in;
	data_out = {`PBW{intensity}};
end

endmodule
