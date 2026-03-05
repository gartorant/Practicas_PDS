module dp_mod
	(
	input signed [15:0] id_data,	// S[16,15] 
	input [23:0] id_frec_por,		// U[24,24]
	input [15:0] id_im_am,			// U[16,15]
	input [15:0] id_im_fm,			// U[16,16]
	input ic_fm_am, 				// Control modo fm/am
	input ic_rst,					// rst sincrono activo a 1
	input ic_val_data,				
	input clk,
	output signed [15:0] od_data,	// S[16,15]
	output oc_val_data
	);
	
/* DECLARACIONES ------------------------- */

// b0: ruta datos FM
logic signed [16:0] b0_multiplicand_mux_r; // S[17,16]

logic signed [16:0] b0_multiplicand_mux_s; // S[17,16]
logic signed [32:0] b0_mult_full_s;// S[33,31]
logic signed [23:0] b0_mult_cut_s; // S[24,24]
logic signed [24:0] b0_sum_ext_s; // S[25,24]

// b1: ruta de datos AM

// b2: DDS

// b3: etapa final

// b4: Generaci�n  de oc_val_data



/* DESCRIPCION ------------------------- */	

// b0: ruta datos FM

always_comb begin
  b0_multiplicand_mux_s = ic_fm_am ? $signed({1'b0, id_im_fm}) : 17'sd0;
  
  b0_mult_full_s = $signed(id_data) * $signed(b0_multiplicand_mux_s);

  // corte/escala (ajústalo a tu Q-format)
  b0_mult_cut_s  = b0_mult_full_s[30 -: 24];   

  b0_sum_ext_s   = $signed({b0_mult_cut_s[23], b0_mult_cut_s}) + $signed({1'b0, id_frec_por});

end 

always_ff @(posedge clk) begin
    if(ic_fm_am) begin
    b0_multiplicand_mux_r <= $signed({1'b0, id_im_fm});
    end 
        else begin
            b0_multiplicand_mux_r <= 17'd0;
        end
end

/*
always_ff @(posedge clk) begin
    if(ic_rst) begin
        b0_mult_res_r <= 0;
        b0_sum_res_r <= 0;
        end 
        else begin
            b0_mult_res_full_s = id_data * b0_multiplicand_mux_r;
            b0_mult_res_r <= b0_mult_res_full_s[30:30-23];
            b0_sum_res_extended_s = {b0_mult_res_r[23], b0_mult_res_r} + $signed({1'b0, id_frec_por});
            b0_sum_res_r <= b0_sum_res_extended_s[23:0];
        end
end*/

// b1: ruta de datos AM

// b2: DDS

// b3: Etapa final

// b4: propagacion de val_data




/* ASIGNACION SALIDAS ------------------------- */

assign oc_val_data = ic_val_data; // HAY QUE MODIFICARLO

endmodule 