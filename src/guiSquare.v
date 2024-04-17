`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 01:14:28 PM
// Design Name: 
// Module Name: guiSquare
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


module guiSquare #(parameter X = 100,
                   parameter Y = 0,
                   parameter SIZE = 50,
                   parameter COLOR = 0) (
        input clk,
        input [9:0] pixelX,
        input [9:0] pixelY,
        input [9:0] mouseX,
        input [9:0] mouseY,
        input mouseLeftButton,
        output isActive,
        output [11:0] color,
        output isPressed,
        output reg isClicked
    );
    
    wire isMouseOver;
    assign isMouseOver = X <= mouseX && mouseX < X+SIZE && Y <= mouseY && mouseY < Y+SIZE;
    assign isPressed = isMouseOver && mouseLeftButton;
    
    reg prevMouseLeftButton = 0;
    
    assign isActive = X <= pixelX && pixelX < X+SIZE
                      && Y <= pixelY && pixelY < Y+SIZE;
    
    assign color = COLOR;
    
    always @(posedge clk) begin
        isClicked <= isMouseOver && mouseLeftButton && !prevMouseLeftButton;
        prevMouseLeftButton <= mouseLeftButton;
    end
    
endmodule
