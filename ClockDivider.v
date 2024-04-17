`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2024 10:48:41 AM
// Design Name: 
// Module Name: ClockDivider
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

// A clock divider with synchronous reset.
module ClockDivider #(parameter DIVISION_FACTOR = 1) (
    input clk,
    input rst,
    output divided_clk
    );
    reg [$clog2(DIVISION_FACTOR)-1:0] counter;
    
    assign divided_clk = counter == DIVISION_FACTOR - 1;
    
    always @(posedge clk) begin
        if (rst || counter == DIVISION_FACTOR - 1) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
