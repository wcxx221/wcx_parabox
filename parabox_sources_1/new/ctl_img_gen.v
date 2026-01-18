module ctl_img_gen(
    input      pixelclk,
    input      reset_n,
    input wire key_enC,
    input wire key_enU,
    input wire key_enL,
    input wire key_enR,
    input wire key_enD,
    input wire rst,       
    input wire undo,     
    input [11:0] hcount,
    input [11:0] vcount,
    input        i_vsync,
    output [23:0] dout	//gray out
); 

reg  i_vsync_r, i_vsync_pos;
wire [23:0] dout_tui;
wire [23:0] dout1;
wire [23:0] dout2;
wire [23:0] dout3;
reg [11:0] man_x1;
reg [11:0] man_y1;
reg [11:0] man_x2;
reg [11:0] man_y2;
reg [11:0] man_x3;
reg [11:0] man_y3;

reg [11:0] man_x1_old, man_y1_old;
reg [11:0] box11_x_old, box11_y_old;
reg [11:0] man_x2_old, man_y2_old;
reg [11:0] box21_x_old, box21_y_old, box22_x_old, box22_y_old, box23_x_old, box23_y_old, box24_x_old, box24_y_old;
reg [11:0] man_x3_old, man_y3_old;
reg [11:0] box31_x_old, box31_y_old, box32_x_old, box32_y_old;

parameter IDLE        = 4'd0,
           SEL_LEVEL   = 4'd1,
           LEVEL1      = 4'd2,
           LEVEL2      = 4'd3,
           LEVEL3      = 4'd4,
           LEVEL1_OVER = 4'd5,
           LEVEL2_OVER = 4'd6,
           LEVEL3_OVER = 4'd7;
           
reg [3:0] state;
reg [1:0] level;

reg [11:0] box11_x;     //320
reg [11:0] box11_y;     //220    
wire beat11_level;  // You made it!
wire   hit11_wall;
wire   hit11_box;
wire   hit11_box_wall;

reg [11:0] box21_x;     //280
reg [11:0] box21_y;     //220    
reg [11:0] box22_x;     //280
reg [11:0] box22_y;     //260       
reg [11:0] box23_x;     //340
reg [11:0] box23_y;     //220       
reg [11:0] box24_x;     //340
reg [11:0] box24_y;     //260       
wire beat2_level;  // You made it!
wire   hit2_wall;      
wire   hit2_box1;
wire   hit2_box2;
wire   hit2_box3;
wire   hit2_box4;
wire   hit_box22;      
wire   hit2_box1_wall;
wire   hit2_box2_wall;
wire   hit2_box3_wall;
wire   hit2_box4_wall;

reg [11:0] box31_x;     //260
reg [11:0] box31_y;     //260 
reg [11:0] box32_x;     //300
reg [11:0] box32_y;     //260 
wire beat3_level;  // You made it!
wire   hit3_wall;
wire   hit3_box1;
wire   hit3_box2;
wire   hit_box33;
wire   hit3_box1_wall;
wire   hit3_box2_wall;

reg [31:0] cnt;
reg key_enU_r;
reg key_enL_r;
reg key_enR_r;
reg key_enD_r;
reg key_enU_r1;
reg key_enL_r1;
reg key_enR_r1;
reg key_enD_r1;

reg level1_reset_n;
reg level2_reset_n;
reg level3_reset_n;

assign dout = (state==IDLE||state==SEL_LEVEL)     ? dout_tui:
              (state==LEVEL1||state==LEVEL1_OVER) ? dout1:
              (state==LEVEL2||state==LEVEL2_OVER) ? dout2:dout3;

reg [3:0] key_reg;
reg [3:0] box22_reg;
reg [3:0] box33_reg;
// Initialize 
  always @(posedge pixelclk or negedge reset_n) begin
      if(!reset_n) begin
        state  <= IDLE;
        level  <= 2'b0;
        man_x1 <= 280;
        man_y1 <= 240;
        man_x2 <= 300;
        man_y2 <= 280;        
        man_x3 <= 280;
        man_y3 <= 240;        
        box11_x <= 320;
        box11_y <= 220;        
            cnt <= 0;
        key_reg <= 4'b0;       
        level1_reset_n<=1'b1;
        
        box21_x <= 280;//280
        box21_y <= 220;//220           
        box22_x <= 280;//280
        box22_y <= 260;//260           
        box23_x <= 340;//340
        box23_y <= 220;//220         
        box24_x <= 340;//340
        box24_y <= 260;//260        
        box22_reg <= 4'b0000;         
        level2_reset_n<=1'b1;
         
        box31_x <= 260;//260
        box31_y <= 260;//260           
        box32_x <= 300;//300
        box32_y <= 260;//260         
        box33_reg <= 4'b0000;         
        level3_reset_n<=1'b1;
      end
      else begin
    case(state)
      IDLE:begin
            level1_reset_n<=1'b1;
            level2_reset_n<=1'b1;
            level3_reset_n<=1'b1;
        if(key_enC==1'b1)
            state<=SEL_LEVEL;
        else
            state<=state;
        if(key_enU==1'b1) 
            level<=level+2'b01;
        else
            level<=level;
      end
      SEL_LEVEL:begin       // select your level
        if(level==2'b00) state<=LEVEL1;
        else if(level==2'b01) state<=LEVEL2;
        else if(level==2'b10||level==2'b11) state<=LEVEL3;
        else state<=state;
      end       // Design 3 levels seperately
      
      // ------------------------------------------ LEVEL 1 -----------------------------------------
      LEVEL1:begin
        if(rst)begin
                 man_x1 <= 280; man_y1 <= 240;      // reset
                 box11_x <= 320; box11_y <= 220;
                 key_reg <= 4'b0000;
             end
        else if(undo) begin                         // undo
                 man_x1 <= man_x1_old; man_y1 <= man_y1_old;
                 box11_x <= box11_x_old; box11_y <= box11_y_old;
             end
        else begin  // keep the old states
             if(key_enU||key_enD||key_enL||key_enR) begin
                 man_x1_old <= man_x1; man_y1_old <= man_y1;
                 box11_x_old <= box11_x; box11_y_old <= box11_y;
             end
        if(key_enU==1'b1) begin man_y1<=man_y1-20; key_reg<=4'b1000; end    // up
        if(key_enD==1'b1) begin man_y1<=man_y1+20; key_reg<=4'b0100;end     // down
        if(key_enL==1'b1) begin man_x1<=man_x1-20; key_reg<=4'b0010;end     // left
        if(key_enR==1'b1) begin man_x1<=man_x1+20; key_reg<=4'b0001;end     // right
        
        if(hit11_wall==1'b1) begin      // hit wall
          if(key_reg[3]==1'b1) begin man_y1<=man_y1+20; key_reg<=4'b0000;end
          if(key_reg[2]==1'b1) begin man_y1<=man_y1-20; key_reg<=4'b0000;end
          if(key_reg[1]==1'b1) begin man_x1<=man_x1+20; key_reg<=4'b0000;end
          if(key_reg[0]==1'b1) begin man_x1<=man_x1-20; key_reg<=4'b0000;end
        end
        
        if(hit11_box==1'b1) begin       // hit the box
          if(key_reg[3]==1'b1)  box11_y<=box11_y-20;
          if(key_reg[2]==1'b1)  box11_y<=box11_y+20;
          if(key_reg[1]==1'b1)  box11_x<=box11_x-20;
          if(key_reg[0]==1'b1)  box11_x<=box11_x+20;        
        end
        
       if(hit11_box_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box11_y<=box11_y+20;
             man_y1<=man_y1+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box11_y<=box11_y-20;
              man_y1<=man_y1-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box11_x<=box11_x+20;
            man_x1<=man_x1+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box11_x<=box11_x-20;
            man_x1<=man_x1-20;
            key_reg<=4'b0000;
          end          
       end
        
        if(beat11_level==1'b1) state<=LEVEL1_OVER;
      end
      end
      
      // ------------------------------------------ LEVEL 2 -----------------------------------------
      LEVEL2:begin
         if(rst) begin
                    man_x2 <= 300; man_y2 <= 280;
                    box21_x <= 280; box21_y <= 220;
                    box22_x <= 280; box22_y <= 260;
                    box23_x <= 340; box23_y <= 220;
                    box24_x <= 340; box24_y <= 260;
                    key_reg <= 4'b0000;
                    box22_reg <= 4'b0000;
             end
         else if(undo) begin
                    man_x2 <= man_x2_old; man_y2 <= man_y2_old;
                    box21_x <= box21_x_old; box21_y <= box21_y_old;
                    box22_x <= box22_x_old; box22_y <= box22_y_old;
                    box23_x <= box23_x_old; box23_y <= box23_y_old;
                    box24_x <= box24_x_old; box24_y <= box24_y_old;
             end
         else begin
             if(key_enU||key_enD||key_enL||key_enR) begin
                    man_x2_old <= man_x2; man_y2_old <= man_y2;
                    box21_x_old <= box21_x; box21_y_old <= box21_y;
                    box22_x_old <= box22_x; box22_y_old <= box22_y;
                    box23_x_old <= box23_x; box23_y_old <= box23_y;
                    box24_x_old <= box24_x; box24_y_old <= box24_y;
             end
        if(key_enU==1'b1) begin  man_y2<=man_y2-20;  key_reg<=4'b1000; end
        if(key_enD==1'b1) begin  man_y2<=man_y2+20;  key_reg<=4'b0100; end
        if(key_enL==1'b1) begin  man_x2<=man_x2-20;  key_reg<=4'b0010; end
        if(key_enR==1'b1) begin  man_x2<=man_x2+20;  key_reg<=4'b0001; end 
        
        if(hit2_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin man_y2<=man_y2+20; key_reg<=4'b0000;end
          if(key_reg[2]==1'b1) begin man_y2<=man_y2-20; key_reg<=4'b0000;end
          if(key_reg[1]==1'b1) begin man_x2<=man_x2+20; key_reg<=4'b0000;end
          if(key_reg[0]==1'b1) begin man_x2<=man_x2-20; key_reg<=4'b0000;end
        end
        
        if(hit2_box1==1'b1) begin
          box22_reg<=4'b0001;
          if(key_reg[3]==1'b1)  box21_y<=box21_y-20;
          if(key_reg[2]==1'b1)  box21_y<=box21_y+20;
          if(key_reg[1]==1'b1)  box21_x<=box21_x-20;
          if(key_reg[0]==1'b1)  box21_x<=box21_x+20;        
        end
        
       if(hit2_box2==1'b1) begin
          box22_reg<=4'b0010;
          if(key_reg[3]==1'b1)  box22_y<=box22_y-20;
          if(key_reg[2]==1'b1)  box22_y<=box22_y+20;
          if(key_reg[1]==1'b1)  box22_x<=box22_x-20;
          if(key_reg[0]==1'b1)  box22_x<=box22_x+20;        
        end
        
       if(hit2_box3==1'b1) begin
          box22_reg<=4'b0100;
          if(key_reg[3]==1'b1)  box23_y<=box23_y-20;
          if(key_reg[2]==1'b1)  box23_y<=box23_y+20;
          if(key_reg[1]==1'b1)  box23_x<=box23_x-20;
          if(key_reg[0]==1'b1)  box23_x<=box23_x+20;        
        end
    
       if(hit2_box4==1'b1) begin
          box22_reg<=4'b1000;
          if(key_reg[3]==1'b1)  box24_y<=box24_y-20;
          if(key_reg[2]==1'b1)  box24_y<=box24_y+20;
          if(key_reg[1]==1'b1)  box24_x<=box24_x-20;
          if(key_reg[0]==1'b1)  box24_x<=box24_x+20;        
        end
        
        if(hit2_box1_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box21_y<=box21_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box21_y<=box21_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box21_x<=box21_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box21_x<=box21_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end          
       end
       
       if(hit2_box2_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box22_y<=box22_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box22_y<=box22_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box22_x<=box22_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box22_x<=box22_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end          
       end
       
        if(hit2_box3_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box23_y<=box23_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box23_y<=box23_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box23_x<=box23_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box23_x<=box23_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end          
       end

        if(hit2_box4_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box24_y<=box24_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box24_y<=box24_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box24_x<=box24_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box24_x<=box24_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end          
       end
       
       if(hit_box22==1'b1) begin
         if(box22_reg<=4'b0001) begin
           if(key_reg[3]==1'b1) begin
             box21_y<=box21_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box21_y<=box21_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box21_x<=box21_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box21_x<=box21_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end 
         end
         if(box22_reg<=4'b0010) begin
           if(key_reg[3]==1'b1) begin
             box22_y<=box22_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box22_y<=box22_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box22_x<=box22_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box22_x<=box22_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end 
         end
         if(box22_reg<=4'b0100) begin
           if(key_reg[3]==1'b1) begin
             box23_y<=box23_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box23_y<=box23_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box23_x<=box23_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box23_x<=box23_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end 
         end
         if(box22_reg<=4'b1000) begin
           if(key_reg[3]==1'b1) begin
             box24_y<=box24_y+20;
             man_y2<=man_y2+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box24_y<=box24_y-20;
              man_y2<=man_y2-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box24_x<=box24_x+20;
            man_x2<=man_x2+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box24_x<=box24_x-20;
            man_x2<=man_x2-20;
            key_reg<=4'b0000;
          end 
         end
       end
               
        if(beat2_level==1'b1) begin
           state<=LEVEL2_OVER;
           box22_reg<=4'b0000;
        end
            
      end
      end
      
      // ------------------------------------------ LEVEL 3------------------------------------------
      LEVEL3:begin
        if(rst) begin
                man_x3 <= 280; man_y3 <= 240;
                box31_x <= 260; box31_y <= 260;
                box32_x <= 300; box32_y <= 260;
                key_reg <= 4'b0000;
                box33_reg <= 4'b0000;
            end
        else if(undo) begin
                man_x3 <= man_x3_old; man_y3 <= man_y3_old;
                box31_x <= box31_x_old; box31_y <= box31_y_old;
                box32_x <= box32_x_old; box32_y <= box32_y_old;
            end
        else begin
            if(key_enU||key_enD||key_enL||key_enR) begin
                 man_x3_old <= man_x3; man_y3_old <= man_y3;
                 box31_x_old <= box31_x; box31_y_old <= box31_y;
                 box32_x_old <= box32_x; box32_y_old <= box32_y;
            end
        if(key_enU==1'b1) begin  man_y3<=man_y3-20;  key_reg<=4'b1000; end
        if(key_enD==1'b1) begin  man_y3<=man_y3+20;  key_reg<=4'b0100; end
        if(key_enL==1'b1) begin  man_x3<=man_x3-20;  key_reg<=4'b0010; end
        if(key_enR==1'b1) begin  man_x3<=man_x3+20;  key_reg<=4'b0001; end 
        
        if(hit3_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin man_y3<=man_y3+20; key_reg<=4'b0000;end
          if(key_reg[2]==1'b1) begin man_y3<=man_y3-20; key_reg<=4'b0000;end
          if(key_reg[1]==1'b1) begin man_x3<=man_x3+20; key_reg<=4'b0000;end
          if(key_reg[0]==1'b1) begin man_x3<=man_x3-20; key_reg<=4'b0000;end
        end
        
        if(hit3_box1==1'b1) begin
          box33_reg<=4'b0001;
          if(key_reg[3]==1'b1)  box31_y<=box31_y-20;
          if(key_reg[2]==1'b1)  box31_y<=box31_y+20;
          if(key_reg[1]==1'b1)  box31_x<=box31_x-20;
          if(key_reg[0]==1'b1)  box31_x<=box31_x+20;        
        end
        
       if(hit3_box2==1'b1) begin
          box33_reg<=4'b0010;
          if(key_reg[3]==1'b1)  box32_y<=box32_y-20;
          if(key_reg[2]==1'b1)  box32_y<=box32_y+20;
          if(key_reg[1]==1'b1)  box32_x<=box32_x-20;
          if(key_reg[0]==1'b1)  box32_x<=box32_x+20;        
        end
        
        if(hit_box33==1'b1) begin
          if(box33_reg==4'b0001) begin
            if(key_reg[3]==1'b1) begin
               box31_y<=box31_y+20;
               man_y3<=man_y3+20;
               key_reg<=4'b0000;
            end
            if(key_reg[2]==1'b1) begin
              box31_y<=box31_y-20;
              man_y3<=man_y3-20;
              key_reg<=4'b0000;
           end
           if(key_reg[1]==1'b1) begin
              box31_x<=box31_x+20;
              man_x3<=man_x3+20;
              key_reg<=4'b0000;
           end
           if(key_reg[0]==1'b1) begin
             box31_x<=box31_x-20;
             man_x3<=man_x3-20;
             key_reg<=4'b0000;
           end                 
          end
          if(box33_reg==4'b0010) begin
            if(key_reg[3]==1'b1) begin
               box32_y<=box32_y+20;
               man_y3<=man_y3+20;
               key_reg<=4'b0000;
            end
            if(key_reg[2]==1'b1) begin
              box32_y<=box32_y-20;
              man_y3<=man_y3-20;
              key_reg<=4'b0000;
            end
            if(key_reg[1]==1'b1) begin
              box32_x<=box32_x+20;
              man_x3<=man_x3+20;
              key_reg<=4'b0000;
            end
            if(key_reg[0]==1'b1) begin
              box32_x<=box32_x-20;
              man_x3<=man_x3-20;
              key_reg<=4'b0000;
            end                    
          end
        end
        
        if(hit3_box1_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box31_y<=box31_y+20;
             man_y3<=man_y3+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box31_y<=box31_y-20;
              man_y3<=man_y3-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box31_x<=box31_x+20;
            man_x3<=man_x3+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box31_x<=box31_x-20;
            man_x3<=man_x3-20;
            key_reg<=4'b0000;
          end          
       end
       
       if(hit3_box2_wall==1'b1) begin
          if(key_reg[3]==1'b1) begin
             box32_y<=box32_y+20;
             man_y3<=man_y3+20;
             key_reg<=4'b0000;
          end
          if(key_reg[2]==1'b1) begin
              box32_y<=box32_y-20;
              man_y3<=man_y3-20;
              key_reg<=4'b0000;
          end
          if(key_reg[1]==1'b1) begin
            box32_x<=box32_x+20;
            man_x3<=man_x3+20;
            key_reg<=4'b0000;
          end
          if(key_reg[0]==1'b1) begin
            box32_x<=box32_x-20;
            man_x3<=man_x3-20;
            key_reg<=4'b0000;
          end          
       end
       
         if(beat3_level==1'b1) state<=LEVEL3_OVER;
            end
      end      
            
      
      // ------------------------------------------ LEVEL OVER JUDGEMENT -----------------------------------------
      LEVEL1_OVER:begin
        if(cnt==24999999) begin
          state<=IDLE;
          cnt<=0;
          level1_reset_n<=1'b0;
        end
        else
          cnt<=cnt+1;
      end
      
      LEVEL2_OVER:begin
        if(cnt==24999999) begin
          state<=IDLE;
          cnt<=0;
          level2_reset_n<=1'b0;
        end
        else
          cnt<=cnt+1;
      end
      
      LEVEL3_OVER:begin
        if(cnt==24999999) begin
          state<=IDLE;
          cnt<=0;
          level3_reset_n<=1'b0;
        end
        else
          cnt<=cnt+1;
      end
      // All 7 states considered,no need to default
    endcase
  end
end

img_start Uimg_start(
          .pixelclk(pixelclk),
          .reset_n(reset_n),
	      .hcount(hcount),
	      .vcount(vcount),
          .i_vsync(i_vsync),
          .level(level),
          .dout(dout_tui)	//gray out
);

img_gen1 U_IMG_GEN1 (
    	.pixelclk(pixelclk),
        .reset_n(reset_n&level1_reset_n),
	    .hcount(hcount),
	    .vcount(vcount),
		.man_x(man_x1),//280
        .man_y(man_y1),//240
        .i_vsync(i_vsync),       
        .box_x(box11_x),//320
        .box_y(box11_y),//220   
        .beat_level(beat11_level),
        .hit_wall(hit11_wall),
        .hit_box(hit11_box),
        .hit_box_wall(hit11_box_wall),
        .dout(dout1)	//gray out
);

img_gen2 U_IMG_GEN2 (
    	.pixelclk(pixelclk),
        .reset_n(reset_n&level2_reset_n),
	    .hcount(hcount),
	    .vcount(vcount),
		.man_x(man_x2),//300
        .man_y(man_y2),//280
        .i_vsync(i_vsync),        
        .box1_x(box21_x),//280
        .box1_y(box21_y),//220       
        .box2_x(box22_x),//280
        .box2_y(box22_y),//260       
        .box3_x(box23_x),//340
        .box3_y(box23_y),//220     
        .box4_x(box24_x),//340
        .box4_y(box24_y),//260       
        .beat_level(beat2_level),
        .hit_wall(hit2_wall),      
        .hit_box1(hit2_box1),
        .hit_box2(hit2_box2),
        .hit_box3(hit2_box3),
        .hit_box4(hit2_box4),        
        .hit_box22(hit_box22),      
        .hit_box1_wall(hit2_box1_wall),
        .hit_box2_wall(hit2_box2_wall),
        .hit_box3_wall(hit2_box3_wall),
        .hit_box4_wall(hit2_box4_wall),
        .dout(dout2)	//gray out
);

img_gen3 U_IMG_GEN3 (
    	.pixelclk(pixelclk),
        .reset_n(reset_n&level3_reset_n),
	    .hcount(hcount),
	    .vcount(vcount),
		.man_x(man_x3),
        .man_y(man_y3),
        .i_vsync(i_vsync),        
        .box1_x(box31_x),//260
        .box1_y(box31_y),//260    
        .box2_x(box32_x),//300
        .box2_y(box32_y),//260       
        .hit_box33(hit_box33),    
        .beat_level(beat3_level),
        .hit_wall(hit3_wall),
        .hit_box1(hit3_box1),
        .hit_box2(hit3_box2),
        .hit_box1_wall(hit3_box1_wall),
        .hit_box2_wall(hit3_box2_wall),
        .dout(dout3)	//gray out
);

endmodule
