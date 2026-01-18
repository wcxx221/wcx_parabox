module BTN_TOP(
     input CLK100MHZ,
     input CPU_RESETN,
     input BTNC,
     input BTNU,
     input BTNL,
     input BTNR,
     input BTND,     
     output key_enC,
     output key_enU,
     output key_enL,
     output key_enR,
     output key_enD
);
// button debounce     
key_filter U1key_filter(
			.Clk(CLK100MHZ),      
			.Rst_n(CPU_RESETN),    
			.key_in(BTNC),   
		    .key_en(key_enC)
);

key_filter U2key_filter(
			.Clk(CLK100MHZ),      
			.Rst_n(CPU_RESETN),    
			.key_in(BTNU),  
		    .key_en(key_enU)
);
		
key_filter U3key_filter(
			.Clk(CLK100MHZ),      
			.Rst_n(CPU_RESETN),    
			.key_in(BTNL),   
		    .key_en(key_enL)
);
		
key_filter U4key_filter(
			.Clk(CLK100MHZ),      
			.Rst_n(CPU_RESETN),    
			.key_in(BTNR),   
		    .key_en(key_enR)
);
		
key_filter U5key_filter(
			.Clk(CLK100MHZ),     
			.Rst_n(CPU_RESETN),    //module reset
			.key_in(BTND),       //button in
		    .key_en(key_enD)
);
    
endmodule
