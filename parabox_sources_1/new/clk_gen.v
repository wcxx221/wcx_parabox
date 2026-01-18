`timescale 1ns / 1ps

module clk_gen (
    input wire clk,      // 100MHz clock in
    input wire reset_n,  
    output wire clk_25m   // 25MHz clock out
);

reg [1:0] cnt;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        cnt <= 2'd0;  
    end else begin
        cnt <= cnt + 2'd1;  // Counter, divide clock
    end
end
assign clk_25m=cnt[1];

endmodule
