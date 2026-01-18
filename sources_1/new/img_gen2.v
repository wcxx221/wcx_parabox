`define RED    24'hFF0000
`define GREEN  24'h00FF00
`define BLUE   24'h0000FF
`define PURPLE 24'hFF00FF
`define YELLOW 24'hFFFF00
`define CYAN   24'h00FFFF
`define ORANGE 24'hFFC125
`define WHITE  24'hFFFFFF
`define BLACK  24'h000000

// Walls
`define WALL_W21 ((hcount>260&&hcount<380)&&(vcount>180&&vcount<200))
`define WALL_W22 ((hcount>240&&hcount<280)&&(vcount>200&&vcount<220))
`define WALL_W23 ((hcount>360&&hcount<400)&&(vcount>200&&vcount<220))
`define WALL_W24 ((hcount>280&&hcount<360)&&(vcount>300&&vcount<320))
`define WALL_H21 ((hcount>240&&hcount<260)&&(vcount>220&&vcount<300))
`define WALL_H22 ((hcount>380&&hcount<400)&&(vcount>220&&vcount<300))
`define WALL_H23 ((hcount>260&&hcount<280)&&(vcount>280&&vcount<320))
`define WALL_H24 ((hcount>360&&hcount<380)&&(vcount>280&&vcount<320))
`define WALL_W25 ((hcount>300&&hcount<340)&&(vcount>240&&vcount<260))

`define WALL_ALL (`WALL_W21||`WALL_W22||`WALL_W23||`WALL_W24||`WALL_H21||`WALL_H22||`WALL_H23||`WALL_H24||`WALL_W25)

// Destination( you know that DIST means destination is ok)
`define DIST1 ((hcount>280&&hcount<301)&&(vcount>200&&vcount<221))
`define DIST2 ((hcount>280&&hcount<301)&&(vcount>240&&vcount<261))
`define DIST3 ((hcount>340&&hcount<361)&&(vcount>200&&vcount<221))
`define DIST4 ((hcount>340&&hcount<361)&&(vcount>240&&vcount<261))

// Player
`define MAN ((hcount>man_x&&hcount<(man_x+21))&&(vcount>man_y&&vcount<(man_y+21)))

// boxes
`define BOX1 ((hcount>box1_x&&hcount<(box1_x+21))&&(vcount>box1_y&&vcount<(box1_y+21)))
`define BOX2 ((hcount>box2_x&&hcount<(box2_x+21))&&(vcount>box2_y&&vcount<(box2_y+21)))
`define BOX3 ((hcount>box3_x&&hcount<(box3_x+21))&&(vcount>box3_y&&vcount<(box3_y+21)))
`define BOX4 ((hcount>box4_x&&hcount<(box4_x+21))&&(vcount>box4_y&&vcount<(box4_y+21)))

module img_gen2(
    input         pixelclk,
    input         reset_n,
    input [11:0]  hcount,
    input [11:0]  vcount,
    input         i_vsync,
    input [11:0]  man_x,
    input [11:0]  man_y,
    input [11:0]  box1_x,
    input [11:0]  box1_y,
    input [11:0]  box2_x,
    input [11:0]  box2_y,
    input [11:0]  box3_x,
    input [11:0]  box3_y,
    input [11:0]  box4_x,
    input [11:0]  box4_y,
    output        beat_level,
    output        hit_wall,
    output        hit_box1,
    output        hit_box2,
    output        hit_box3,
    output        hit_box4,
    output        hit_box22,
    output        hit_box1_wall,
    output        hit_box2_wall,
    output        hit_box3_wall,
    output        hit_box4_wall,
    output [23:0] dout
);

reg [23:0] rgb_data;
assign dout = rgb_data;

// collision
wire hit_box1_wall_sig = `BOX1 & `WALL_ALL;
wire hit_box2_wall_sig = `BOX2 & `WALL_ALL;
wire hit_box3_wall_sig = `BOX3 & `WALL_ALL;
wire hit_box4_wall_sig = `BOX4 & `WALL_ALL;

// boxes collision
wire hit_box1_box_sig = `BOX1 & (`BOX2 | `BOX3 | `BOX4);
wire hit_box2_box_sig = `BOX2 & (`BOX1 | `BOX3 | `BOX4);
wire hit_box3_box_sig = `BOX3 & (`BOX1 | `BOX2 | `BOX4);
wire hit_box4_box_sig = `BOX4 & (`BOX1 | `BOX2 | `BOX3);

assign hit_box1_wall = hit_box1_wall_sig;
assign hit_box2_wall = hit_box2_wall_sig;
assign hit_box3_wall = hit_box3_wall_sig;
assign hit_box4_wall = hit_box4_wall_sig;

assign hit_box1 = `BOX1 & `MAN;
assign hit_box2 = `BOX2 & `MAN;
assign hit_box3 = `BOX3 & `MAN;
assign hit_box4 = `BOX4 & `MAN;

assign hit_wall = `MAN & `WALL_ALL;

// any box touching
assign hit_box22 = hit_box1_box_sig | hit_box2_box_sig | hit_box3_box_sig | hit_box4_box_sig;

// beat_level ?
assign beat_level = ((`BOX1 & `DIST1) && (`BOX2 & `DIST2) && (`BOX3 & `DIST3) && (`BOX4 & `DIST4));

// use ROM 
reg [8:0] man_addr;
reg [8:0] dist_addr1, dist_addr2, dist_addr3, dist_addr4;

wire [7:0] man_data_r, man_data_g, man_data_b;
wire [7:0] dist_data1_r, dist_data1_g, dist_data1_b;
wire [7:0] dist_data2_r, dist_data2_g, dist_data2_b;
wire [7:0] dist_data3_r, dist_data3_g, dist_data3_b;
wire [7:0] dist_data4_r, dist_data4_g, dist_data4_b;

// display
always @(posedge pixelclk or negedge reset_n) begin
    if(!reset_n) begin
        rgb_data <= `BLACK;
        man_addr <= 0;
        dist_addr1 <= 0; dist_addr2 <= 0; dist_addr3 <= 0; dist_addr4 <= 0;
    end else begin
        if(i_vsync) begin
            if(`WALL_ALL) rgb_data <= `ORANGE;
            else if(`BOX1 | `BOX2 | `BOX3 | `BOX4) rgb_data <= `RED;
            else if(`MAN) begin
                rgb_data <= {man_data_r, man_data_g, man_data_b};
                man_addr <= man_addr + 1;
            end else if(`DIST1) begin
                rgb_data <= {dist_data1_b, dist_data1_g, dist_data1_r};
                dist_addr1 <= dist_addr1 + 1;
            end else if(`DIST2) begin
                rgb_data <= {dist_data2_b, dist_data2_g, dist_data2_r};
                dist_addr2 <= dist_addr2 + 1;
            end else if(`DIST3) begin
                rgb_data <= {dist_data3_b, dist_data3_g, dist_data3_r};
                dist_addr3 <= dist_addr3 + 1;
            end else if(`DIST4) begin
                rgb_data <= {dist_data4_b, dist_data4_g, dist_data4_r};
                dist_addr4 <= dist_addr4 + 1;
            end else rgb_data <= `WHITE;
        end else begin
            rgb_data <= `BLACK;
            man_addr <= 0;
            dist_addr1 <= 0; dist_addr2 <= 0; dist_addr3 <= 0; dist_addr4 <= 0;
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

rom_dist_r Urom_dist2_r(
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

rom_dist_r Urom_dist3_r(
         .clock(pixelclk), 
         .address(dist_addr3), 
         .q(dist_data3_r)
         );
         
rom_dist_g Urom_dist3_g(
         .clock(pixelclk), 
         .address(dist_addr3), 
         .q(dist_data3_g)
         );
         
rom_dist_b Urom_dist3_b(
         .clock(pixelclk), 
         .address(dist_addr3), 
         .q(dist_data3_b)
         );

rom_dist_r Urom_dist4_r(
         .clock(pixelclk), 
         .address(dist_addr4), 
         .q(dist_data4_r)
         );
         
rom_dist_g Urom_dist4_g(
         .clock(pixelclk), 
         .address(dist_addr4), 
         .q(dist_data4_g)
         );
         
rom_dist_b Urom_dist4_b(
         .clock(pixelclk), 
         .address(dist_addr4), 
         .q(dist_data4_b)
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
