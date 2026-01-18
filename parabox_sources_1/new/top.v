`timescale 1ns / 1ps

module top(
    input clk,
    input sw0,   // Total switch
    input sw1,   // Level inner reset
    input sw2,   // Undo
    input btnC,  // Confirm
    input btnU,  // Up
    input btnD,  // Down
    input btnL,  // Left
    input btnR,  // Right 
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output Hsync,     // Horizontal
    output Vsync      // Vertical
);
    
wire key_enC;
wire key_enU;
wire key_enL;
wire key_enR;
wire key_enD;
wire rst;
wire undo;
 
wire clk_25m;       // 25MHz clock

wire [23:0] VGA_RGB;    // VGA's red green blue signal 
wire [11:0] hcount;
wire [11:0] vcount;
wire        VGA_CLK;
wire [7:0]	VGA_R;
wire [7:0]	VGA_G;
wire [7:0]	VGA_B;
wire	    VGA_HS;
wire	    VGA_VS;
wire		VGA_DE;
wire        BLK;        // Black

assign  vgaRed   = VGA_R[7:4];   // high digits transfer vga signal
assign  vgaBlue  = VGA_G[7:4];
assign  vgaGreen = VGA_B[7:4];
assign  Hsync = VGA_HS;     // horizontal
assign  Vsync = VGA_VS;     // vertical

clk_gen  Uclk_gen(
          .clk(clk),      // 100MHz clock
          .reset_n(sw0),  // asychronic low effective reset
          .clk_25m(clk_25m)   // 25MHz clock
);  

BTN_TOP UBTN_TOP(           // instantiate buttons
     .CLK100MHZ(clk_25m),
     .CPU_RESETN(sw0),
     .BTNC(btnC),
     .BTNU(btnU),
     .BTNL(btnL),
     .BTNR(btnR),
     .BTND(btnD),     
     .key_enC(key_enC),
     .key_enU(key_enU),
     .key_enL(key_enL),
     .key_enR(key_enR),
     .key_enD(key_enD)
);
    
ctl_img_gen Uctl_img_gen(       // image generate controller
             .pixelclk(clk_25m),
             .reset_n(sw0),           
             .key_enC(key_enC),
             .key_enU(key_enU),
             .key_enL(key_enL),
             .key_enR(key_enR),
             .key_enD(key_enD),
             .rst(sw1),
             .undo(sw2),
             .hcount(hcount),
             .vcount(vcount),
             .i_vsync(VGA_VS),
             .dout(VGA_RGB)	//gray out
);

vga_ctl  Uvga_ctl(              // vga control
	     .pix_clk(clk_25m),
	     .reset_n(sw0),
	     .VGA_RGB(VGA_RGB),
	     .hcount(hcount),
	     .vcount(vcount),
	     .VGA_CLK(VGA_CLK),
	     .VGA_R(VGA_R),
	     .VGA_G(VGA_G),
	     .VGA_B(VGA_B),
	     .VGA_HS(VGA_HS),
	     .VGA_VS(VGA_VS),
	     .VGA_DE(VGA_DE),
	     .BLK(BLK)     // black
);	    
  
endmodule
