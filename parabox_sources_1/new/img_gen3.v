`define RED    24'hFF0000//red    
`define GREEN  24'h00FF00//green        
`define BLUE   24'h0000FF//blue         
`define PURPLE 24'hFF00FF//purple       
`define YELLOW 24'hFFFF00//yellow       
`define CYAN   24'h00FFFF//cyan         
`define ORANGE 24'hFFC125//orange       
`define WHITE  24'hFFFFFF//white        
`define BLACK  24'h000000//black 

`define WALL_W31 ((hcount>240&&hcount<320)&&(vcount>180&&vcount<200))
`define WALL_H31 ((hcount>240&&hcount<260)&&(vcount>200&&vcount<320))
`define WALL_W32 ((hcount>260&&hcount<320)&&(vcount>300&&vcount<320))
`define WALL_H32 ((hcount>300&&hcount<320)&&(vcount>200&&vcount<240))
`define WALL_W33 ((hcount>320&&hcount<380)&&(vcount>220&&vcount<240))
`define WALL_H33 ((hcount>360&&hcount<380)&&(vcount>240&&vcount<280))
`define WALL_W34 ((hcount>300&&hcount<340)&&(vcount>280&&vcount<300))
`define WALL_H34 ((hcount>340&&hcount<360)&&(vcount>260&&vcount<300))

`define WALL_W3H (`WALL_W31||`WALL_H31||`WALL_W32||`WALL_H32||`WALL_W33||`WALL_H33||`WALL_W34||`WALL_H34)
 
`define DIST31   ((hcount>280&&hcount<301)&&(vcount>200&&vcount<221))
`define DIST32   ((hcount>260&&hcount<281)&&(vcount>240&&vcount<261))
 
`define MAN     ((hcount>man_x&&hcount<(man_x+21))&&(vcount>man_y&&vcount<(man_y+21)))

`define BOX1   ((hcount>box1_x&&hcount<(box1_x+21))&&(vcount>box1_y&&vcount<(box1_y+21)))
`define BOX2   ((hcount>box2_x&&hcount<(box2_x+21))&&(vcount>box2_y&&vcount<(box2_y+21)))

`define CAI     ((hcount>340&&hcount<361)&&(vcount>240&&vcount<261))
`define CAI_CHAR     ((hcount>400&&hcount<481)&&(vcount>240&&vcount<281))
module img_gen3(
    input         pixelclk,
    input         reset_n,
	input [11:0]  hcount,
	input [11:0]  vcount,
    input         i_vsync,
    input  [11:0] man_x,
    input  [11:0] man_y, 
    input  [11:0] box1_x,//260
    input  [11:0] box1_y,//260  
    input  [11:0] box2_x,//300
    input  [11:0] box2_y,//260    
    output beat_level,
    output hit_wall,
    output hit_box1,
    output hit_box2,  
    output hit_box33,
    output hit_box1_wall,
    output hit_box2_wall,
    output [23:0] dout	//gray out
);

reg  [23:0] rgb_data;
reg  [8:0]  dist_addr1;
wire [7:0]  dist_data1_r;
wire [7:0]  dist_data1_g;
wire [7:0]  dist_data1_b;

reg  [8:0]  dist_addr2;
wire [7:0]  dist_data2_r;
wire [7:0]  dist_data2_g;
wire [7:0]  dist_data2_b;

reg  [8:0]   man_addr;
wire [7:0]  man_data_r;
wire [7:0]  man_data_g;
wire [7:0]  man_data_b;

reg  [8:0]  cai_addr;
wire [7:0]  cai_data_r;
wire [7:0]  cai_data_g;
wire [7:0]  cai_data_b;
reg [11:0]   caiaddr;
wire [7:0]   cai_data;

reg hit_cai;
reg beat_level1;
reg beat_level2;

assign beat_level=(beat_level1&&beat_level2)?1'b1:1'b0;
assign hit_wall =(`MAN&`WALL_W3H)?1'b1:1'b0;
assign hit_box1=(`BOX1&`MAN)?1'b1:1'b0;
assign hit_box2=(`BOX2&`MAN)?1'b1:1'b0;

assign hit_box33=(`BOX1&`BOX2)?1'b1:1'b0;

assign hit_box1_wall=(`BOX1&`WALL_W3H)?1'b1:1'b0;
assign hit_box2_wall=(`BOX2&`WALL_W3H)?1'b1:1'b0;

assign dout = rgb_data;

    always @(posedge pixelclk or negedge reset_n) begin
      if(!reset_n) begin
        hit_cai<=1'b0;
        beat_level1<=1'b0;
        beat_level2<=1'b0;
      end
      else begin
        if(`CAI&`MAN)
          hit_cai<=1'b1;
        if(`DIST31&`BOX1||`DIST31&`BOX2)
          beat_level1<=1'b1;
        else if(i_vsync==1'b0)
          beat_level1<=1'b0;
         if(`DIST32&`BOX2||`DIST32&`BOX1)
          beat_level2<=1'b1;
        else if(i_vsync==1'b0)
          beat_level2<=1'b0;
      end
    end

    always @(posedge pixelclk) begin
      if(!reset_n) begin
         rgb_data <= `BLACK;
         dist_addr1<=0;
         dist_addr2<=0;
         man_addr<=0;
         cai_addr<=0;
         caiaddr<=0;
      end
      else begin
         if(i_vsync==1'b1)begin
            if(`WALL_W31||`WALL_H31||`WALL_W32||`WALL_H32||`WALL_W33||`WALL_H33||`WALL_W34||`WALL_H34)begin
                rgb_data <=`ORANGE;
            end
            else if(`BOX1)begin
              rgb_data <=`RED;
            end
            else if(`BOX2)begin
              rgb_data <=`RED;
            end
            else if(`MAN) begin
                rgb_data <={man_data_r,man_data_g,man_data_b};//gray
                man_addr <= man_addr + 1;
            end
            else if(`CAI_CHAR&&hit_cai) begin
                rgb_data <={cai_data,cai_data,cai_data};//gray
                caiaddr <= caiaddr + 1;
            end
            else if(`CAI) begin
                rgb_data <={cai_data_r,cai_data_g,cai_data_b};//gray
                cai_addr <= cai_addr + 1;
            end
            else if(`DIST31) begin
                rgb_data <={dist_data1_b,dist_data1_g,dist_data1_r};//gray
                dist_addr1 <= dist_addr1 + 1;
            end
            else if(`DIST32) begin
                rgb_data <={dist_data2_b,dist_data2_g,dist_data2_r};//gray
                dist_addr2 <= dist_addr2 + 1;
            end
            else begin
                rgb_data <=`WHITE;
                dist_addr1 <= dist_addr1;
                dist_addr2 <= dist_addr2;
                man_addr <= man_addr;
                cai_addr <= cai_addr;
                caiaddr <= caiaddr;
            end
         end
         else begin
            rgb_data <= `BLACK;
            dist_addr1<=0;
            dist_addr2<=0;
            man_addr<=0;
            cai_addr<=0;
            caiaddr<=0;
         end
      end 
    end

rom_dist_r Urom_dist1_r(
         .clock(pixelclk), 
         .address(dist_addr1), 
         .q(dist_data1_r)
         );

rom_dist_g Urom_dist1_g(
         .clock(pixelclk), 
         .address(dist_addr1), 
         .q(dist_data1_g)
         );
rom_dist_b Urom_dist1_b(
         .clock(pixelclk),  
         .address(dist_addr1),      
         .q(dist_data1_b)
         ); 

rom_dist_r Urom_dist2(
         .clock(pixelclk), 
         .address(dist_addr2), 
         .q(dist_data2_r)
         );
rom_dist_g Urom_dist2_g(
         .clock(pixelclk),                  
         .address(dist_addr2),              
         .q(dist_data2_g)
         );

rom_dist_b Urom_dist2_b(
         .clock(pixelclk),                  
         .address(dist_addr2),              
         .q(dist_data2_b)
         );

rom_man_r u_man_r(
         .clock(pixelclk), 
         .address(man_addr), 
         .q(man_data_r)
         );

rom_man_g u_man_g(
         .clock(pixelclk), 
         .address(man_addr), 
         .q(man_data_g)
         );

rom_man_b u_man_b(
         .clock(pixelclk), 
         .address(man_addr), 
         .q(man_data_b)
         );
         
rom_cai u_cai(
         .clock(pixelclk), 
         .address(caiaddr), 
         .q(cai_data)
         );

rom_cai_r u_cai_r(
         .clock(pixelclk), 
         .address(cai_addr), 
         .q(cai_data_r)
         );

rom_cai_g u_cai_g(
         .clock(pixelclk), 
         .address(cai_addr), 
         .q(cai_data_g)
         );

rom_cai_b u_cai_b(
         .clock(pixelclk), 
         .address(cai_addr), 
         .q(cai_data_b)
         );

endmodule
