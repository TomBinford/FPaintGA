`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 11:04:57 AM
// Design Name: 
// Module Name: MutableFramebuffer
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

// The RGB components of color `color` are located at COLOR_LUT[12*color +: 12].
module MutableFramebuffer #(parameter PALETTE_BITS = 2,
                            parameter [12*(1 << PALETTE_BITS)-1:0] COLOR_LUT = -1,
                            parameter WIDTH = 100,
                            parameter HEIGHT = 100) (
    input clk,
    input xyvalid,
    input [9:0] x,
    input [9:0] y,
    input [9:0] writeX,
    input [9:0] writeY,
    input write_enable,
    input [PALETTE_BITS-1:0] write_color,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
    );
    
    wire [PALETTE_BITS-1:0] palette_color;
    
    BlockRAM #(.RAM_WIDTH(PALETTE_BITS), .RAM_DEPTH(WIDTH*HEIGHT)) ram(
        .clk(clk),
        .write_en(write_enable),
        .write_addr(writeX + writeY*WIDTH),
        .word_in(write_color),
        .read_en(xyvalid),
        .read_addr(x + y*WIDTH),
        .word_out(palette_color),
        .output_rst(0),
        .output_en(1)
    );
    
    assign red   = xyvalid ? COLOR_LUT[12*palette_color+8 +: 4] : 0;
    assign green = xyvalid ? COLOR_LUT[12*palette_color+4 +: 4] : 0;
    assign blue  = xyvalid ? COLOR_LUT[12*palette_color   +: 4] : 0;
endmodule
