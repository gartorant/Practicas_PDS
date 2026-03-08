module dp_mod_dds #(
    parameter M = 24,  // DDS accumulator wordlength
    parameter L = 15,  // DDS phase truncation wordlength
    parameter W = 16
)  // DDS ROM wordlength
(
    input         [M-1:0] id_p_ac,     // U[M,0]
    input                 ic_rst_ac,   // bit
    input                 ic_en_ac,    // bit
    input                 clk,         // bit
    output signed [W-1:0] od_sin_wave  // S[W,W-1]
);

  /* DECLARACIONES ------------------------- */
  // b0 ACUMULADOR
  logic [M-1:0] b0_ac_r;  // U[M,0]

  // b1 PRE PROCESADO
  logic [L-3:0] b1_pre_s;  // U[L-2,0]
  logic         b1_pre_ctrl_s;  // bit
  logic [L-3:0] b1_pre_addr_r;  // U[L-2,0]

  // b2 
  logic [W-1:0] b2_od_sin_wave_s;  // U[W,0]

  // b3 post procesado
  logic         b3_post_ctrl1_r;  // bit
  logic         b3_post_ctrl_2r;  // bit
  logic [W-1:0] b3_od_sin_wave_r;  // U[W,0]

  /* DESCRIPCION ------------------------- */
  // b0 ACCUMULADOR
  always_ff @(posedge clk)
    if (ic_rst_ac) begin
      b0_ac_r <= 0;
    end else if (ic_en_ac) begin
      b0_ac_r <= b0_ac_r + id_p_ac;
    end

  // b1 REVISAR AHORA
  assign b1_pre_s = b0_ac_r[M-3:M-L];  // Los L-3 bits más altos que entran en la memoria 
  assign b1_pre_ctrl_s = b0_ac_r[M-2];  // aqui tengo la pendiente M-2 bit de control

  always_ff @(posedge clk) begin
    if (b1_pre_ctrl_s) b1_pre_addr_r <= (~b1_pre_s);
    else b1_pre_addr_r <= b1_pre_s;
  end

  // b2
  dp_mod_dds_rom #(
      .ADDR_WIDTH(L - 2),
      .DATA_WIDTH(W)
  ) dds_rom_sin_wave (
      .ic_addr(b1_pre_addr_r),
      .clk(clk),
      .od_rom(b2_od_sin_wave_s)
  );

  // b3
  always_ff @(posedge clk) begin
    b3_post_ctrl1_r <= b0_ac_r[M-1];  // Registra el Bit M-1 para el post procesado
    b3_post_ctrl_2r <= b3_post_ctrl1_r;  // esto registra
    if (b3_post_ctrl_2r) b3_od_sin_wave_r <= (~b2_od_sin_wave_s) + 1;
    else b3_od_sin_wave_r <= b2_od_sin_wave_s;  // esto registra
  end


  /* ASIGNACION SALIDAS ------------------------- */

  // ASSIGN SON CABLES YA QUE SON CABLES
  assign od_sin_wave = b3_od_sin_wave_r;

endmodule


/* MEMORIA ROM PARA dp_mod_dds */
module dp_mod_dds_rom #(
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

