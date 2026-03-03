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

// b1: ruta de datos AM

// b2: DDS

// b3: etapa final

// b4: Generación  de oc_val_data



/* DESCRIPCION ------------------------- */	

// b0: ruta datos FM

// b1: ruta de datos AM

// b2: DDS

// b3: Etapa final

// b4: propagacion de val_data




/* ASIGNACION SALIDAS ------------------------- */

assign oc_val_data = ic_val_data; // HAY QUE MODIFICARLO

endmodule 