`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2024 08:02:21 PM
// Design Name: 
// Module Name: CanvasArbiter
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


module CanvasArbiter #(parameter NUM_COLORS = 2) (
    input [12*NUM_COLORS-1:0] colors,
    input [NUM_COLORS-1:0] signals,
    input [11:0] fallbackColor,
    output reg [11:0] chosenColor
    );
    integer i;
    
    always @(*) begin
        chosenColor = fallbackColor;
        for (i = 0; i < NUM_COLORS; i = i + 1) begin
            if (signals[i]) begin
                chosenColor = colors[12*i +: 12];
            end
        end
    end
    
endmodule
