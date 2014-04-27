`ifndef HDMI_H
`define HDMI_H

`define hdmi720p
`define rgb24b

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
`define PBW 24
`endif

`endif
