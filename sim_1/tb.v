`timescale 1ns / 1ps

module tb_top();

reg clk;
reg sw0;   // Total control
reg sw1;   // level reset
reg sw2;   // undo
reg btnC;  // confirm
reg btnU;  // up
reg btnD;  // down
reg btnL;  // left
reg btnR;  // right

wire [3:0] vgaRed;
wire [3:0] vgaBlue;
wire [3:0] vgaGreen;
wire Hsync;
wire Vsync;

top Utop(
    .clk(clk),
    .sw0(sw0),
    .sw1(sw1),
    .sw2(sw2),
    .btnC(btnC),
    .btnU(btnU),
    .btnD(btnD),
    .btnL(btnL),
    .btnR(btnR),
    .vgaRed(vgaRed),
    .vgaBlue(vgaBlue),
    .vgaGreen(vgaGreen),
    .Hsync(Hsync),
    .Vsync(Vsync)
);


initial begin
    clk = 0;
    forever #5 clk = ~clk; // T=10ns => 100MHz
end


initial begin
    // ³õÊ¼×´Ì¬
    sw0 = 0; sw1 = 0; sw2 = 0;
    btnC = 0; btnU = 0; btnD = 0; btnL = 0; btnR = 0;
    
    #50;
    sw0 = 1; // release
    #100;

    btnU = 1; #20; btnU = 0; #100;
    btnD = 1; #20; btnD = 0; #100;
    btnL = 1; #20; btnL = 0; #100;
    btnR = 1; #20; btnR = 0; #100;

    btnC = 1; #20; btnC = 0; #100;

    sw1 = 1; #50; sw1 = 0; #100;

    sw2 = 1; #50; sw2 = 0; #100;

    btnU = 1; btnC = 1; #20; btnU = 0; btnC = 0; #100;
    btnL = 1; sw2 = 1; #20; btnL = 0; sw2 = 0; #100;
    btnD = 1; sw1 = 1; #20; btnD = 0; sw1 = 0; #100;
    #100;

    $finish;
end

endmodule
