`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 01:24:35 PM
// Design Name: 
// Module Name: VGAController
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

// Adapted from the NERP demo code.
module VGAController(
    input clk,       // master clock: a multiple of 25MHz
	input clk_25MHz, // pixel clock: 25MHz
	input clr,       // asynchronous reset
	output hsync,    // horizontal sync out
	output vsync,    // vertical sync out
	output xyvalid,
	output yvalid,
	output [9:0] x,  // x position of current pixel, 0 to 639 when xyvalid
	output [9:0] y   // y position of current pixel, 0 to 479 when xyvalid
    );

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
always @(posedge clk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else if (clk_25MHz)
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
	end
end

// generate sync pulses (active low)
assign hsync = (hc < hpulse) ? 0 : 1;
assign vsync = (vc < vpulse) ? 0 : 1;

assign xyvalid = (vbp <= vc && vc < vfp && hbp <= hc && hc < hfp);
assign yvalid = (vbp <= vc && vc < vfp);
assign x = hc - hbp;
assign y = vc - vbp;
endmodule
