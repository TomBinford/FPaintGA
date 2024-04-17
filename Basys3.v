`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2024 10:31:48 AM
// Design Name: 
// Module Name: Basys3
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

module Basys3(
    input clk_100MHz,
    input reset,
    input [0:0] sw,
    // PS/2 mouse input
    input ps2_clk,
    input ps2_data,
    // 12-bit VGA color
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output vgaHsync,
    output vgaVsync
    );
    // An area above the canvas where painting controls are placed.
    parameter guiHeight = 9'd100;
    reg [9:0] brushSize = 4;
    reg [1:0] brushColor;
    
    wire clk_25MHz;
    wire xyvalid;
    wire yvalid;
    wire [9:0] pixelX, pixelY;
    wire [9:0] mouseX, mouseY;
    
    // These iterate faster over the canvas so they visit a pixel
    // much more often than 60 Hz. These help avoid leaving gaps when
    // drawing when the mouse changes position more often than 60 Hz.
    wire [9:0] fastPixelX, fastPixelY;
    
    reg [9:0] bufferedMouseX, bufferedMouseY;
    always @(posedge clk_100MHz) begin
        if (!yvalid) begin
            bufferedMouseX <= mouseX;
            bufferedMouseY <= mouseY;
        end
    end
    
    wire mouseLeftButton;
    PS2MouseController ps2MouseController(
        .clk(clk_100MHz),
        .rst(reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .mouseX(mouseX),
        .mouseY(mouseY),
        .mouseLeftButton(mouseLeftButton)
        //.mouseRightButton(mouseRightButton)
    );
    
    // Screen compositing variables - each screen element has an Active and a Color value.
    wire canvasActive;
    assign canvasActive = xyvalid && pixelY >= guiHeight;
    wire [11:0] canvasColor;
    
    wire guiActive;
    assign guiActive = xyvalid && pixelY < guiHeight;
    parameter guiColor = 12'heaa;
    
    wire pointerActive;
    assign pointerActive = bufferedMouseX <= pixelX && pixelX < bufferedMouseX+brushSize && 
                           bufferedMouseY <= pixelY && pixelY < bufferedMouseY+brushSize;
    wire [11:0] pointerColor;
    
                         /*RGB*/
    parameter color0 = 12'hffd;
    parameter color1 = 12'hdaa;
    parameter color2 = 12'h44a;
    parameter color3 = 12'hd9f;
    
    `define color_lut { color3, color2, color1, color0 }
    
    wire isClearing;
    assign isClearing = sw[0];
    
    MutableFramebuffer #(.PALETTE_BITS(2),
                         .COLOR_LUT(`color_lut),
                         .WIDTH(640),
                         .HEIGHT(480-guiHeight)) canvas(
        .clk(clk_100MHz),
        .xyvalid(canvasActive),
        .x(pixelX),
        .y(pixelY - guiHeight),
        .writeX(isClearing ? pixelX : mouseX + fastPixelX),
        .writeY(isClearing ? pixelY : mouseY + fastPixelY - guiHeight),
        // No need to condition write_enable on (mouseX/Y + fastPixelX/Y) being near
        // the mouse cursor, because fastPixelX & Y already range between 0 and brushSize. 
        .write_enable(isClearing ||
                      ((mouseY + fastPixelY) >= guiHeight && mouseLeftButton && (mouseX + fastPixelX < 640))),
        .write_color(isClearing ? 0 : brushColor),
        .red(canvasColor[11:8]),
        .green(canvasColor[7:4]),
        .blue(canvasColor[3:0])
    );
    
    `define makeGuiSquare(name, x, y, size, sqcolor, isclicked)     \
    wire name``_active;                                             \
    wire [11:0] name``_color;                                       \
    guiSquare #(.X(x), .Y(y), .COLOR(sqcolor), .SIZE(size)) name (  \
        .clk(clk_100MHz),                                           \
        .pixelX(pixelX),                                            \
        .pixelY(pixelY),                                            \
        .mouseX(bufferedMouseX),                                    \
        .mouseY(bufferedMouseY),                                    \
        .mouseLeftButton(mouseLeftButton),                          \
        .isActive(name``_active),                                   \
        .color(name``_color),                                       \
        .isClicked(isclicked)                                       \
    )

    // This is necessary to make brushSize and brushColor only driven from one always block.
    wire requestedBrushSize2, requestedBrushSize4, requestedBrushSize6, requestedBrushSize8;
    wire requestedColor0, requestedColor1, requestedColor2, requestedColor3;
    always @(posedge clk_100MHz) begin
        case ({ requestedBrushSize2, requestedBrushSize4, requestedBrushSize6, requestedBrushSize8 })
            4'b1000: brushSize <= 2;
            4'b0100: brushSize <= 4;
            4'b0010: brushSize <= 6;
            4'b0001: brushSize <= 8;
        endcase
        case ({ requestedColor0, requestedColor1, requestedColor2, requestedColor3 })
            4'b1000: brushColor <= 0;
            4'b0100: brushColor <= 1;
            4'b0010: brushColor <= 2;
            4'b0001: brushColor <= 3;
        endcase
    end
    
    // GUI buttons. To make them draw be sure to reference their signals from CanvasArbiter.
    `makeGuiSquare(color0_button, 75+0*40, 24, 24, color0, requestedColor0);
    `makeGuiSquare(color1_button, 75+1*40, 24, 24, color1, requestedColor1);
    `makeGuiSquare(color2_button, 75+2*40, 24, 24, color2, requestedColor2);
    `makeGuiSquare(color3_button, 75+3*40, 24, 24, color3, requestedColor3);
    `makeGuiSquare(size2_button, 250+          0, 24, 2*3, 12'h000, requestedBrushSize2);
    `makeGuiSquare(size4_button, 250+  2*3 +  18, 24, 4*3, 12'h000, requestedBrushSize4);
    `makeGuiSquare(size6_button, 250+  6*3 +2*18, 24, 6*3, 12'h000, requestedBrushSize6);
    `makeGuiSquare(size8_button, 250+ 10*3 +3*18, 24, 8*3, 12'h000, requestedBrushSize8);
    
    wire [11:0] vgaColor;
    CanvasArbiter #(.NUM_COLORS(10)) canvasArbiter(
        .signals({ /*pointerColor handled below*/ color0_button_active,
                   color1_button_active, color2_button_active,
                   color3_button_active, size2_button_active,
                   size4_button_active, size6_button_active,
                   size8_button_active, guiActive, canvasActive }),
        .colors({ /*pointerColor handled below*/ color0_button_color,
                  color1_button_color, color2_button_color,
                  color3_button_color, size2_button_color,
                  size4_button_color, size6_button_color,
                  size8_button_color, guiColor, canvasColor }),
        .fallbackColor(12'h000),
        .chosenColor(vgaColor)
    );
    
    // Make pointerColor the inverse of the color underneath it.
    assign pointerColor = 12'hfff - vgaColor;
    assign vgaRed = pointerActive ? pointerColor[11:8] : vgaColor[11:8];
    assign vgaGreen = pointerActive ? pointerColor[7:4] : vgaColor[7:4];
    assign vgaBlue = pointerActive ? pointerColor[3:0] : vgaColor[3:0];
    
    ClockDivider #(.DIVISION_FACTOR(4)) vgaPixelClkDiv(
        .clk(clk_100MHz),
        .rst(0),
        .divided_clk(clk_25MHz)
    );
    
    VGAController vgaController(
        .clk(clk_100MHz),
        .clk_25MHz(clk_25MHz),
        .clr(0),
        .hsync(vgaHsync),
        .vsync(vgaVsync),
        .xyvalid(xyvalid),
        .yvalid(yvalid),
        .x(pixelX),
        .y(pixelY)
    );
    
    // Scan over only the pixels that are actively being drawn by the brush.
    // This lets us update the framebuffer much faster than using pixelX and pixelY, since
    // those iterate over the whole screen.
    XYScanner #(.XBITS(10), .YBITS(10)) xyScanner (
        .clk(clk_100MHz),
        // Iterate over x and y slower than the memory speed, to allow inputs to settle
        // for a few cycles. This is being safe; I didn't try clk_100MHz here.
        .move_en(clk_25MHz),
        .x(fastPixelX),
        .y(fastPixelY),
        .width(brushSize),
        .height(brushSize)
    );
endmodule
