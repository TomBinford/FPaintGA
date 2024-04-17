`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 11:40:56 AM
// Design Name: 
// Module Name: XYScanner
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


module XYScanner #(parameter XBITS = 3, parameter YBITS = 3) (
    input clk,
    input move_en,
    input [XBITS+1-1:0] width,
    input [YBITS+1-1:0] height,
    output reg [XBITS-1:0] x,
    output reg [YBITS-1:0] y
    );
    
    always @(posedge clk) begin
        if (move_en) begin
            if (x < width - 1) begin
                x <= x + 1;
            end
            else begin
                x <= 0;
                y <= y < height - 1 ? y + 1 : 0;
            end
        end
    end
    
endmodule
