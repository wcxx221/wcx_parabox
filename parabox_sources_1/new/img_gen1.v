`define RED    24'hFF0000//red    
`define GREEN  24'h00FF00//green        
`define BLUE   24'h0000FF//blue         
`define PURPLE 24'hFF00FF//purple       
`define YELLOW 24'hFFFF00//yellow       
`define CYAN   24'h00FFFF//cyan         
`define ORANGE 24'hFFC125//orange       
`define WHITE  24'hFFFFFF//white        
`define BLACK  24'h000000//black 

// Define wall regions (horizontal and vertical segments)
`define WALL_W1 ((hcount>240&&hcount<300)&&(vcount>220&&vcount<240))
`define WALL_H1 ((hcount>240&&hcount<260)&&(vcount>240&&vcount<320))
`define WALL_W2 ((hcount>260&&hcount<300)&&(vcount>300&&vcount<320))
`define WALL_H2 ((hcount>280&&hcount<300)&&(vcount>180&&vcount<220))
`define WALL_W3 ((hcount>300&&hcount<360)&&(vcount>180&&vcount<200))
`define WALL_H3 ((hcount>340&&hcount<360)&&(vcount>200&&vcount<260))
`define WALL_W4 ((hcount>360&&hcount<420)&&(vcount>240&&vcount<260))
`define WALL_H4 ((hcount>400&&hcount<420)&&(vcount>260&&vcount<320))
`define WALL_W5 ((hcount>340&&hcount<400)&&(vcount>300&&vcount<320))
`define WALL_W6 ((hcount>300&&hcount<340)&&(vcount>280&&vcount<300))

`define WALL_WH (`WALL_W1||`WALL_H1||`WALL_W2||`WALL_H2||`WALL_W3||`WALL_H3||`WALL_W4||`WALL_H4||`WALL_W5||`WALL_W6)

//goal, box, and player regions
`define DIST   ((hcount>300&&hcount<321)&&(vcount>220&&vcount<241))
`define BOX    ((hcount>box_x&&hcount<(box_x+21))&&(vcount>box_y&&vcount<(box_y+21)))
`define MAN    ((hcount>man_x&&hcount<(man_x+21))&&(vcount>man_y&&vcount<(man_y+21)))

module img_gen1(
    input        pixelclk,
    input        reset_n,
	input [11:0] hcount,
	input [11:0] vcount,
    input        i_vsync,
    input [11:0] man_x,
    input [11:0] man_y,    
    input [11:0] box_x,//320
    input [11:0] box_y,//220
    output       beat_level,   // win condition flag
    output       hit_wall,     // collision with wall
    output       hit_box,      // player hits box
    output       hit_box_wall, // box hits wall
    output [23:0] dout	        // VGA RGB output
);

reg  [8:0]  man_addr;
wire [7:0]  man_data_r;
wire [7:0]  man_data_g;
wire [7:0]  man_data_b;

reg  [8:0]  dist_addr1;
wire [7:0]  dist_data1_r;
wire [7:0]  dist_data1_g;
wire [7:0]  dist_data1_b;

reg [23:0] rgb_data;
assign dout = rgb_data;

// detect collisions and success
assign beat_level=(`DIST&`BOX)?1'b1:1'b0;       // Box reaches goal
assign hit_wall =(`MAN&`WALL_WH)?1'b1:1'b0;     // Player hits wall
assign hit_box=(`BOX&`MAN)?1'b1:1'b0;           // Player hits box
assign hit_box_wall=(`BOX&`WALL_WH)?1'b1:1'b0;  // Box hits wall

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
      rgb_data <= `BLACK;
      man_addr<=0;
      dist_addr1<=0;
  end
  else begin
    if(i_vsync==1'b1)begin
        // Draw different objects according to pixel region
        if(`WALL_WH)begin
            rgb_data <=`ORANGE;                 
        end
        else if(`BOX)begin
          rgb_data <=`RED;                      // Box in red
        end
        else if(`MAN) begin
            rgb_data <={man_data_r,man_data_g,man_data_b}; // Player sprite
            man_addr <= man_addr + 1;
        end
        else if(`DIST) begin
            rgb_data <={dist_data1_b,dist_data1_g,dist_data1_r}; // Destination
            dist_addr1 <= dist_addr1 + 1;
        end
        else begin
            rgb_data <=`WHITE;                  // Background color
        end
    end
    else begin
      // Reset addresses each frame (on vertical sync)
      rgb_data <= `BLACK;
      man_addr<=0;
      dist_addr1<=0;
    end
  end
end

// ROM instances store RGB bitmaps for man and goal images
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

endmodule
