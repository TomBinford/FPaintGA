`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 10:49:57 AM
// Design Name: 
// Module Name: BlockRAM
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

// Adapted from the Basys3 block RAM template in Tools -> Language Templates ->
// Verilog -> Synthesis Constructs -> Coding Examples -> RAM -> Block RAM -> 1 Clock
module BlockRAM #(parameter RAM_WIDTH = 1, parameter RAM_DEPTH = 10) (
    input [clogb2(RAM_DEPTH-1)-1:0] write_addr, // Write address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] read_addr,  // Read address bus, width determined from RAM_DEPTH
    input [RAM_WIDTH-1:0] word_in,              // RAM input data
    input clk,                                  // Clock
    input write_en,                             // Write enable
    input read_en,                              // Read Enable, for additional power savings, disable when not in use
    input output_rst,                           // Output reset (does not affect memory contents)
    input output_en,                            // Output register enable
    output wire [RAM_WIDTH-1:0] word_out        // RAM output data
    );
    
    reg [RAM_WIDTH-1:0] ram [RAM_DEPTH-1:0];
    reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};
    
    // The following code initializes the memory values to all zeros to match hardware
    generate
      integer ram_index;
      initial
      for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
        ram[ram_index] = {RAM_WIDTH{1'b0}};
    endgenerate
    
    always @(posedge clk) begin
      if (write_en)
        ram[write_addr] <= word_in;
      if (read_en)
        ram_data <= ram[read_addr];
    end
    
    //  The following code generates HIGH_PERFORMANCE (use output register)
    generate
      // The following is a 2 clock cycle read latency with improve clock-to-out timing
      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};
      
      always @(posedge clk)
        if (output_rst)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (output_en)
          doutb_reg <= ram_data;
      
      assign word_out = doutb_reg;
    endgenerate

    //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
      input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
          depth = depth >> 1;
    endfunction
endmodule
