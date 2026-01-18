`timescale 1ns / 1ps

`define RED    24'hFF0000//red    
`define GREEN  24'h00FF00//green        
`define BLUE   24'h0000FF//blue         
`define PURPLE 24'hFF00FF//purple       
`define YELLOW 24'hFFFF00//yellow       
`define CYAN   24'h00FFFF//cyan         
`define ORANGE 24'hFFC125//orange       
`define WHITE  24'hFFFFFF//white        
`define BLACK  24'h000000//black 

// define display regions on screen
`define TUI_REGION ((hcount>220&&hcount<341)&&(vcount>160&&vcount<201))
`define TUI1_REGION ((hcount>220&&hcount<341)&&(vcount>200&&vcount<241))
`define TUI2_REGION ((hcount>220&&hcount<341)&&(vcount>240&&vcount<281))
`define NUM_REGION ((hcount>340&&hcount<381)&&(vcount>240&&vcount<281))

module img_start(
    input        pixelclk,
    input        reset_n,
	input [11:0] hcount,
	input [11:0] vcount,
    input        i_vsync,
    input [1:0]  level,
    output [23:0] dout	//gray out
);

reg [12:0] tui_addr;
reg [12:3] tui1_addr;
reg [12:0] tui2_addr;

wire [7:0] tui_data;
wire [7:0] tui1_data;
wire [7:0] tui2_data;

reg [10:0] num1_addr;
reg [10:0] num2_addr;    
reg [10:0] num3_addr;

wire [7:0] num1_data;
wire [7:0] num2_data;
wire [7:0] num3_data;

reg [23:0] rgb_data;
assign dout = rgb_data;

always @(posedge pixelclk or negedge reset_n) begin
  if(!reset_n) begin
        rgb_data <= `BLACK;
        tui_addr<=0;
        tui1_addr<=0;
        tui2_addr<=0;
        num1_addr<=0;   
        num2_addr<=0;
        num3_addr<=0;
  end
  else begin
    if(i_vsync==1'b1)begin 
       // During visible frame, output gray image data from corresponding ROMs
       if(`TUI_REGION) begin
            rgb_data <={tui_data,tui_data,tui_data}; // Display TUI region in grayscale
            tui_addr <= tui_addr + 1;
       end
       else if(`TUI1_REGION) begin
                rgb_data <={tui1_data,tui1_data,tui1_data}; // TUI1 region
                tui1_addr <= tui1_addr + 1;
       end
       else if(`TUI2_REGION) begin
                rgb_data <={tui2_data,tui2_data,tui2_data}; // TUI2 region
                tui2_addr <= tui2_addr + 1;
       end
       else if(`NUM_REGION)begin
            // Show number according to current level
            if(level==2'b00) begin
                rgb_data <={num1_data,num1_data,num1_data};
                num1_addr <= num1_addr + 1;
            end
            else if(level==2'b01) begin
                rgb_data <={num2_data,num2_data,num2_data};
                num2_addr <= num2_addr + 1;
            end
            else begin
                rgb_data <={num3_data,num3_data,num3_data};
                num3_addr <= num3_addr + 1;
            end
       end
       else begin
            rgb_data <=`WHITE; // Background color
       end
    end
    else begin 
        // Reset address counters at each frame (vsync)
        rgb_data <= `BLACK;
        tui_addr<=0;
        tui1_addr<=0;
        tui2_addr<=0;  
        num1_addr<=0;
        num2_addr<=0;
        num3_addr<=0;
    end
  end
end

// ROM instances for TUI and number patterns
rom_num1 Urom_num1(
         .clock(pixelclk), 
         .address(num1_addr), 
         .q(num1_data)
         );

rom_num2 Urom_num2(
         .clock(pixelclk), 
         .address(num2_addr), 
         .q(num2_data)
         );

rom_num3 Urom_num3(
         .clock(pixelclk), 
         .address(num3_addr), 
         .q(num3_data)
         );

rom_tui Urom_tui(
         .clock(pixelclk), 
         .address(tui_addr), 
         .q(tui_data)
         );

rom_tui1 Urom_tui1(
         .clock(pixelclk), 
         .address(tui1_addr), 
         .q(tui1_data)
         );

rom_tui2 Urom_tui2(
         .clock(pixelclk), 
         .address(tui2_addr), 
         .q(tui2_data)
         );

endmodule
