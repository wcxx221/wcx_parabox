module key_filter(
	    Clk,      
		Rst_n,    
		key_in,   
		key_en
);

input Clk;
input Rst_n;
input key_in;
output reg key_en;
	
reg key_flag;
reg key_state;
	
always@(posedge Clk or negedge Rst_n)   // key enable
	if(!Rst_n)
		key_en <= 0;
	else 
        if(key_flag && !key_state)
            key_en <= 1;
        else
            key_en <= 0;
	
localparam              // state define
	IDLE	= 4'b0001,
	FILTER0	= 4'b0010,
	DOWN	= 4'b0100,
	FILTER1 = 4'b1000;
		
	reg [3:0]state;
	reg [19:0]cnt;
	reg en_cnt;	   // Count enabler
    //input synchronize
	reg key_in_sa,key_in_sb;
	always@(posedge Clk or negedge Rst_n)begin
        if(~Rst_n)begin
            key_in_sa <= 1'b0;
            key_in_sb <= 1'b0;
        end
        else begin
            key_in_sa <= key_in;
            key_in_sb <= key_in_sa;	
        end
	end
	
	reg key_tmpa,key_tmpb;
	wire pedge,nedge;
	reg cnt_full;      //Counting full signal
	
//Use DFF to store the level states of input signals(already synchronized to the system clock)at 2 adjacent clock rising edges
	always@(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)begin
            key_tmpa <= 1'b0;
            key_tmpb <= 1'b0;
        end
        else begin
            key_tmpa <= key_in_sb;
            key_tmpb <= key_tmpa;	
        end
    end
    
//Generate edge signal	
	assign nedge = !key_tmpa & key_tmpb;
	assign pedge = key_tmpa & (!key_tmpb);
	
always@(posedge Clk or negedge Rst_n) begin
	if(!Rst_n)begin
		en_cnt <= 1'b0;
		state <= IDLE;
		key_flag <= 1'b0;
		key_state <= 1'b1;
	end
	else begin
		case(state)
			IDLE :
				begin
					key_flag <= 1'b0;
					if(nedge)begin
						state <= FILTER0;  // go to FILTER0
						en_cnt <= 1'b1;
					end
					else
						state <= IDLE;
				end					
			FILTER0:
				if(cnt_full)begin
					key_flag <= 1'b1;
					key_state <= 1'b0;
					en_cnt <= 1'b0;
					state <= DOWN;     // go to DOWN
				end
				else if(pedge)begin
					state <= IDLE;
					en_cnt <= 1'b0;
				end
				else
					state <= FILTER0;					
			DOWN:
				begin
					key_flag <= 1'b0;
					if(pedge)begin
						state <= FILTER1;  // go to FILTER1
						en_cnt <= 1'b1;
					end
					else
						state <= DOWN;
				end			
			FILTER1:
				if(cnt_full)begin
					key_flag <= 1'b1;
					key_state <= 1'b1;
					state <= IDLE;         // jump to IDLE
					en_cnt <= 1'b0;
				end
				else if(nedge)begin
					en_cnt <= 1'b0;
					state <= DOWN;         // go to DOWN
				end
				else
					state <= FILTER1;		
			default:
				begin 
					state <= IDLE; 
					en_cnt <= 1'b0;		
					key_flag <= 1'b0;
					key_state <= 1'b1;
				end				
		endcase	
	end
end
	
	always@(posedge Clk or negedge Rst_n) begin    // counter
        if(!Rst_n)
            cnt <= 20'd0;
        else if(en_cnt)
            cnt <= cnt + 1'b1;
        else
            cnt <= 20'd0;
    end
        
    always@(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            cnt_full <= 1'b0;
        else if(cnt == 20'd499999)  //actually 20ms
            cnt_full <= 1'b1;
        else
            cnt_full <= 1'b0;	
    end

endmodule
