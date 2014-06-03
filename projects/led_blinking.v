`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2014 02:33:30 PM
// Design Name: 
// Module Name: led_blinking
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_blinking(
    input wire sysclk_n,
    input wire sysclk_p,
    output reg [7:0] gpio_led
);

    wire clock;
    wire locked;
    reg reset;
    reg [26:0] count = 27'd0;
    reg on_off = 1'b0;
    
    parameter HALF_PERIOD = 27'd50000000 - 27'd1;
    
    always @(*) begin
        reset = 1'b0;
        gpio_led[7:1] = {7{on_off}};
        gpio_led[0] = 1'b1;
    end
    
    clk_wiz_0 clock_generator
    (
    // Clock in ports
      .clk_in1_d_p(sysclk_p),    // input clk_in1_d_p
      .clk_in1_d_n(sysclk_n),    // input clk_in1_d_n
      // Clock out ports
      .clock(clock),     // output clock
      // Status and control signals
      .reset(reset),// input reset
      .locked(locked) // output locked
     );

     always @(posedge clock) begin
        if(count >= HALF_PERIOD) begin
            on_off <= ~on_off;
            count <= 17'd0;
        end
        else begin
            on_off <= on_off;
            count <= count + 17'd1;
        end
     end
endmodule
