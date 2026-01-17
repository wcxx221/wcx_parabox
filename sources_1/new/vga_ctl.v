module vga_ctl(
	input	      pix_clk,
	input         reset_n,
	input  [23:0] VGA_RGB,
	output [11:0] hcount,
	output [11:0] vcount,
	output        VGA_CLK,
	output [7:0]  VGA_R,
	output [7:0]  VGA_G,
	output [7:0]  VGA_B,
	output		  VGA_HS,
	output		  VGA_VS,
	output		  VGA_DE,
	output        BLK
);
	
parameter   H_Total = 800,
             H_Sync = 96,
             H_Back = 40, 
             H_Active = 640,          
             H_Front = 24,     
             H_Start = 136, // H_Sync+H_Back
             H_End = 776,   // H_Sync+H_Back+H_Active
             V_Total = 525,
             V_Sync = 2,
             V_Back = 25,
             V_Active = 480,
             V_Front = 16,
             V_Start = 27,  // V_Sync+V_Back
             V_End = 507;   // V_Sync+V_Back+V_Active

reg [11:0] x_cnt;
reg [11:0] y_cnt;
reg	       hsync_r; 
reg	       hs_de;
reg	       vsync_r;
reg	       vs_de;

assign VGA_CLK = pix_clk;

    always @(posedge pix_clk or negedge reset_n) begin  // H count
        if(!reset_n)
          x_cnt	<= 1;
        else if(x_cnt==H_Total)
          x_cnt	<= 1;
        else
          x_cnt	<= x_cnt+1;
    end

    always @(posedge pix_clk or negedge reset_n) begin  // H SYNC DENABLE
        if(!reset_n)
          hsync_r <= 1'b1;
        else if(x_cnt)
          hsync_r <= 1'b0;
        else if(x_cnt==H_Sync)
          hsync_r <= 1'b1;
        else
          hsync_r <= hsync_r;
        
        if(!reset_n)
          hs_de	<= 1'b0;
        else if(x_cnt==H_Start)
          hs_de	<= 1'b1;
        else if(x_cnt==H_End)
          hs_de	<= 1'b0;
        else
          hs_de <= hs_de;
    end

    always @(posedge pix_clk or negedge reset_n) begin  // V count
        if(!reset_n)
          y_cnt	<= 1;
        else if(y_cnt==V_Total)
          y_cnt	<= 1;
        else if(x_cnt==H_Total)
          y_cnt	<= y_cnt+1;
        else
          y_cnt <= y_cnt;
    end

    always @(posedge pix_clk or negedge reset_n) begin  // V SYNC DENABLE
        if(!reset_n)
          vsync_r <= 1'b1;
        else if(y_cnt)
          vsync_r <= 1'b0;
        else if(y_cnt==V_Sync)
          vsync_r <= 1'b1;
        else
          vsync_r <= vsync_r ;
        
        if(!reset_n)
          vs_de	<=	1'b0;
        else if(y_cnt==V_Start)
          vs_de	<=	1'b1;
        else if(y_cnt==V_End)
          vs_de	<=	1'b0;
        else
          vs_de <=  vs_de;
    end

assign BLK    = 1;
assign VGA_HS =	hsync_r;
assign VGA_VS = vsync_r;
assign VGA_DE =	hs_de & vs_de;
assign VGA_R  =	(hs_de & vs_de)? VGA_RGB[23:16]:8'h0;    //R
assign VGA_G  =	(hs_de & vs_de)? VGA_RGB[15:8]:8'h0;     //G
assign VGA_B  =	(hs_de & vs_de)? VGA_RGB[7:0]:8'h0;      //B
assign hcount = (hs_de & vs_de)? (x_cnt - H_Start):12'd0;
assign vcount = (hs_de & vs_de)? (y_cnt - V_Start):12'd0;

endmodule
