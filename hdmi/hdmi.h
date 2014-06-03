`ifndef HDMI_H
`define HDMI_H

`define rgb24b

//`define hdmi720p
//`define hdmi1280x1024
//`define hdmi1024x768
//`define hdmi800x600
`define hdmi1080p

`ifdef hdmi1080p
	`define HBW 12
	`define VBW 12
	
	`define HSYNC `HBW'd44
	`define HBP   `HBW'd148
	`define HRES  `HBW'd1920
	`define HFP   `HBW'd88
	`define HTOT  `HBW'd2200
	
	`define VSYNC `VBW'd5
	`define VBP   `VBW'd36
	`define VRES  `VBW'd1080
	`define VFP   `VBW'd4
	`define VTOT  `VBW'd1125
`endif

`ifdef hdmi800x600
	`define HBW  11
	`define VBW  11
					 
	`define HSYNC `HBW'd128
	`define HBP   `HBW'd88
	`define HRES  `HBW'd800
	`define HFP   `HBW'd40
	`define HTOT  `HBW'd1056

	`define VSYNC `VBW'd4
	`define VBP   `VBW'd23
	`define VRES  `VBW'd600
	`define VFP   `VBW'd1
	`define VTOT  `VBW'd628
`endif

`ifdef hdmi800x600
	`define HBW  11
	`define VBW  11
					 
	`define HSYNC `HBW'd128
	`define HBP   `HBW'd88
	`define HRES  `HBW'd800
	`define HFP   `HBW'd40
	`define HTOT  `HBW'd1056

	`define VSYNC `VBW'd4
	`define VBP   `VBW'd23
	`define VRES  `VBW'd600
	`define VFP   `VBW'd1
	`define VTOT  `VBW'd628
`endif

`ifdef hdmi1024x768
`define HBW  11
`define VBW  11
             
`define HTOT  `HBW'd1344
`define HFP   `HBW'd24
`define HRES  `HBW'd1024
`define HBP   `HBW'd160
`define HSYNC `HBW'd136
             
`define VTOT  `VBW'd806
`define VFP   `VBW'd3
`define VRES  `VBW'd768
`define VBP   `VBW'd29
`define VSYNC `VBW'd6

`define NEG_POL
`endif

`ifdef hdmi1280x1024
`define HBW  11
`define VBW  11
             
`define HTOT  `HBW'd1688
`define HFP   `HBW'd48
`define HRES  `HBW'd1280
`define HBP   `HBW'd248
`define HSYNC `HBW'd112
             
`define VTOT  `VBW'd1066
`define VFP   `VBW'd1
`define VRES  `VBW'd1024
`define VBP   `VBW'd38
`define VSYNC `VBW'd3
`endif

`ifdef hdmi720p
`define HBW  11
`define VBW  10

`define HTOT  `HBW'd1650
`define HFP   `HBW'd110
`define HRES  `HBW'd1280
`define HBP   `HBW'd220
`define HSYNC `HBW'd40

`define VTOT  `VBW'd750
`define VFP   `VBW'd5
`define VRES  `VBW'd720
`define VBP   `VBW'd20
`define VSYNC `VBW'd5
`endif

`ifdef rgb24b
`define PBW 36
`endif

`endif
