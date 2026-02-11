module dds_test #(
    parameter M = 24,  // DDS accumulator wordlength
    parameter L = 15,  // DDS phase truncation wordlength
    parameter W = 16
)  // DDS ROM wordlength
(
    input         [M-1:0] id_p_ac,        // U[M,0]
    input                 ic_rst_ac,      // bit
    input                 ic_en_ac,       // bit
    input                 ic_val_data,    // bit
    input                 clk,            // bit
    output signed [W-1:0] od_sqr_wave,    // S[W,W-1]
    output signed [W-1:0] od_ramp_wave,   // S[W,W-1]
    output signed [W-1:0] od_sin_wave,    // S[W,W-1]
    output                oc_val_data     // bit
);

  /* DECLARACIONES ------------------------- */
  // b0 ACUMULADOR
  logic [M-1:0] b0_ac_r;  // U[M,M]
  
  // b1 PRE PROCESADO
  logic [L-3:0] b1_pre_w;     // U[L-2,L-2]
  logic b1_pre_ctrl_s;        // bit
  logic [L-3:0] b1_pre_addr_r;// U[L-2,L-2]
  
  // b2 
  logic [W-1:0] b2_od_sin_wave_w; // U[W,W]

  // b3 post procesado
  logic b3_post_ctrl1_r; // bit
  logic b3_post_ctrl_r2; // bit
  logic [W-1:0] b3_od_sin_wave_r; // U[W,W]

  // b4 
  logic [W-1:0]b4_shift0_r;  //U[W,W]
  logic [W-1:0]b4_shift1_r;  //U[W,W] cambiar en numero en el shift
  logic [W-1:0]b4_shift2_r;  //U[W,W]
  logic [W-1:0]b4_shift_r;

  // b5
  logic b5_shift0_r;  // bit
  logic b5_shift1_r;  // bit
  logic [W-1:0]b5_ROM_r;  // bit

  //b6
  logic b6_shift0_r;  //bit
  logic b6_shift1_r;  //bit
  logic b6_shift2_r;  //bit
  logic b6_val_data_r; // bit
  /* DESCRIPCION ------------------------- */
  // b0 ACCUMULADOR
  always_ff @(posedge clk)
    if (ic_rst_ac) begin
      b0_ac_r <= 0;
    end else if (ic_en_ac) begin
      b0_ac_r <= b0_ac_r + id_p_ac;
    end
  
  // b1 REVISAR AHORA
    //assign b1_pre_w = b0_ac_r[M-1 : M-L]; // los L BITS MSB (los más altos) TODO: REVISAR no estoy de acuerdo
    assign b1_pre_w = b0_ac_r[M-W-3:0]; // Los L bits más bajos de M 
    assign b1_pre_ctrl_s = b0_ac_r[M-W-2]; // aqui tengo la pendiente L-2 bit de control

    always_ff @(posedge clk) begin
      if(b1_pre_ctrl_s)
       b1_pre_addr_r <= (~b1_pre_w);
      else 
       b1_pre_addr_r <= b1_pre_w;
    end
    
    // b2
    dds_test_rom dds_rom_sin_wave (.ic_addr(b1_pre_addr_r), 
                   .clk(clk),
                   .od_rom(b2_od_sin_wave_w)); //TODO: esta es cable cambiar w por s
    
    // b3
    always_ff @(posedge clk) begin
      b3_post_ctrl1_r <= b0_ac_r[M-W-1]; // Registra el Bit L-1 para el post procesado
      b3_post_ctrl_r2 <= b3_post_ctrl1_r; // esto registra
      if(b3_post_ctrl_r2) 
          b3_od_sin_wave_r <= (~b2_od_sin_wave_w); // 
        else
          b3_od_sin_wave_r <= b2_od_sin_wave_w; // esto registra
    end

    // b4
    assign b4_shift0_r = b0_ac_r[M-1:M-W]; // los W bits más altos de M
    always_ff @(posedge clk) begin
      b4_shift1_r <= b4_shift0_r;
      b4_shift_r <= b4_shift1_r;
    end
    
    // b5
    always_ff @(posedge clk ) begin
      b5_shift0_r <= b0_ac_r[M-1];
      b5_shift1_r <= b5_shift0_r;
    end

    always_ff @(posedge clk) begin
      if (b5_shift1_r) begin
        b5_ROM_r <= '1;
      end else begin
        b5_ROM_r <= '0;
      end
    end
    // b6
    assign b6_shift0_r = ic_val_data;
    always_ff @(posedge clk ) begin
      // todo falta un registro o uno completo de 4
      b6_shift1_r <= b6_shift0_r;
      b6_shift2_r <= b6_shift1_r;
      b6_val_data_r <= b6_shift2_r; 
    end
  /* ASIGNACION SALIDAS ------------------------- */
    
    // ASSIGN SON CABLES YA QUE SON CABLES
    assign od_sqr_wave = b5_ROM_r;
    assign od_ramp_wave = b4_shift_r;
    assign od_sin_wave = b3_od_sin_wave_r;
    assign oc_val_data = b6_val_data_r;
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

