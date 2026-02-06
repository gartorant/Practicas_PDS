module dds_test_wrp
	(
	input [26:0] id_p_ac,				// U[27,0]			
	input ic_rst_ac, 
	input ic_en_ac,
	input ic_val_data,	
	input clk,
	output signed [13:0] od_sqr_wave,  // S[14,13]
	output signed [13:0] od_ramp_wave,	// S[14,13]
	output signed [13:0] od_sin_wave,  // S[14,13]
	output oc_val_data
	);

logic [26:0] id_p_ac_r;
logic val_in_r;
logic en_ac_r;
logic signed [13:0] sqr_wave_s,sqr_wave_r;
logic signed [13:0] ramp_wave_s,ramp_wave_r;
logic signed [13:0] sin_wave_s,sin_wave_r;
logic val_out_s,val_out_r;

// Seleccion de registros de I/O: 0-->no, 1-->si 
parameter reg_io = 0;

// No registra I/O
generate if (reg_io == 0)
	always_comb 	
		begin
			id_p_ac_r <= id_p_ac;
			val_in_r <= ic_val_data;
			en_ac_r <= ic_en_ac;
			sqr_wave_r <= sqr_wave_s;
			ramp_wave_r <= ramp_wave_s;
			sin_wave_r <= sin_wave_s;
			val_out_r <= val_out_s;
		end
else
	always_ff@(posedge clk) 	
		begin
			id_p_ac_r <= id_p_ac;
			val_in_r <= ic_val_data;
			en_ac_r <= ic_en_ac;
			sqr_wave_r <= sqr_wave_s;
			ramp_wave_r <= ramp_wave_s;
			sin_wave_r <= sin_wave_s;
			val_out_r <= val_out_s;
		end
endgenerate
		

		
dds_test #(.M(27),.L(15),.W(14)) DDS1 
			(.id_p_ac(id_p_ac_r),
			.ic_rst_ac(ic_rst_ac),
			.ic_en_ac(en_ac_r),
			.ic_val_data(val_in_r),
			.clk(clk),
			.od_sqr_wave(sqr_wave_s),
			.od_ramp_wave(ramp_wave_s),
			.od_sin_wave(sin_wave_s),
			.oc_val_data(val_out_s)
			);

assign od_sqr_wave = sqr_wave_r;
assign od_ramp_wave = ramp_wave_r;
assign od_sin_wave = sin_wave_r;
assign oc_val_data = val_out_r;

endmodule 
