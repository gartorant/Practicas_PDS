module dds_test #(
    parameter M = 24,  // DDS accumulator wordlength
    parameter L = 15,  // DDS phase truncation wordlength
    parameter W = 16
)  // DDS ROM wordlength
(
    input [M-1:0] id_p_ac,  // U[M,0]			
    input ic_rst_ac,
    input ic_en_ac,
    input ic_val_data,
    input clk,
    output signed [W-1:0] od_sqr_wave,  // S[W,W-1]
    output signed [W-1:0] od_ramp_wave,  // S[W,W-1]
    output signed [W-1:0] od_sin_wave,  // S[W,W-1]
    output oc_val_data
);

  /* DECLARACIONES ------------------------- */

  // b0 - ACUMULADOR
  logic [M-1:0] b0_ac_r;



  /* DESCRIPCION ------------------------- */
  // b0 - ACUMULADOR
  always_ff @(posedge clk)
    if (ic_rst_ac) b0_ac_r <= 0;
    else if (ic_en_ac) b0_ac_r <= b0_ac_r + id_p_ac;



  /* ASIGNACION SALIDAS ------------------------- */



endmodule


/* MEMORIA ROM PARA dds_test */
module dds_test_rom #(
    parameter ADDR_WIDTH = 13,  // Address wordlength
    parameter DATA_WIDTH = 14
)  // ROM output wordlength
(
    input [ADDR_WIDTH-1:0] ic_addr,  // U[ADDR_WIDTH,0]
    input clk,
    output signed [DATA_WIDTH-1:0] od_rom  // S[DATA_WIDTH,DATA_WIDTH-1]
);

  /* DECLARACIONES ------------------------- */
  reg signed [DATA_WIDTH-1:0] rom[0:2**ADDR_WIDTH-1];

  logic [DATA_WIDTH-1:0] b0_rom_r;

  /* DESCRIPCION ------------------------- */

  // ROM data
  initial
    if ((DATA_WIDTH == 14) & (ADDR_WIDTH == 13)) $readmemb("../src/rom_dds_L15_W14.txt", rom);
    else if ((DATA_WIDTH == 16) & (ADDR_WIDTH == 13)) $readmemb("../src/rom_dds_L15_W16.txt", rom);
    else if ((DATA_WIDTH == 16) & (ADDR_WIDTH == 4)) $readmemb("../src/rom_dds_L6_W16.txt", rom);


  // Read synchronous ROM
  always_ff @(posedge clk) b0_rom_r <= rom[ic_addr];


  /* ASIGNACION SALIDAS ------------------------- */
  assign od_rom = b0_rom_r;

endmodule
