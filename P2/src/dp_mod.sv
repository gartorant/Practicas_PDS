module dp_mod (
    input signed [15:0] id_data, // S[16,15] 
    input [23:0] id_frec_por,  // U[24,24]
    input [15:0] id_im_am,   // U[16,15]
    input [15:0] id_im_fm,   // U[16,16]
    input ic_fm_am,     // Control modo fm/am
    input ic_rst,     // rst sincrono activo a 1
    input ic_val_data,
    input clk,
    output signed [15:0] od_data, // S[16,15]
    output oc_val_data
);

  /* DECLARACIONES ------------------------- */

  // b0: ruta datos FM
  logic signed [16:0] b0_out_mux_r;  // S[17,16]
  logic signed [17:0] b0_out_mux_s;  // S[18,16] -> con estension de signo
  logic signed [17:0] b0_id_data_s;  // S[18,15] -> con estension de signo
  logic signed [32:0] b0_mult_res_full_s;  // S[33,31]
  logic signed [23:0] b0_mult_res_r;  // S[24,24]
  logic signed [24:0] b0_sum_res_extended_s;  // S[25,24]
  logic signed [23:0] b0_sum_res_r;  // S[24,24]

  // b1: ruta de datos AM
  // Formato: logic [tamanyo del dato] variable [cuantos datos];
  logic signed [15:0] b1_shift_r                                          [0:2];
  logic signed [15:0] b1_res_mult_s;
  logic signed [15:0] b1_res_mult_r;
  logic signed [16:0] b1_res_add_s;
  logic signed [16:0] b1_res_add_r;

  // b2: DDS
  logic               b2_rst_r                                            [0:1];

  // b3: etapa final
  logic signed [15:0] b3_oud_dds_s;
  logic signed [16:0] b3_res_mux_r;
  logic signed [16:0] b3_res_mux_s;
  logic signed [15:0] b3_out_od_data_s;
  logic signed [15:0] b3_out_od_data_r;

  // b4: Generaci�n  de oc_val_data
  logic               ic_val_data_r                                       [6:0];


  /* DESCRIPCION ------------------------- */

  // b0: ruta datos FM
  // MUX 1
  always_ff @(posedge clk) begin
    if (ic_fm_am) begin
      b0_out_mux_r <= $signed({1'b0, id_im_fm});
    end else begin
      b0_out_mux_r <= '0;
    end
  end

  // Forzamos los 18 bits para que el sintetizador entienda que estamos 
  // queriendo usar los multiplicadores de 18 x 18
  assign b0_id_data_s = {{2{id_data[15]}}, id_data};
  assign b0_out_mux_s = {{1{b0_out_mux_r[16]}}, b0_out_mux_r};

  always_comb begin
    b0_mult_res_full_s = b0_id_data_s;
  end
  // b1: ruta de datos AM
  always_ff @(posedge clk) begin
    b1_shift_r[0] <= id_data;
    b1_shift_r[1] <= b1_shift_r[0];
    b1_shift_r[2] <= b1_shift_r[1];
  end

  assign b1_res_mult_s = $signed(id_im_am) * b1_shift_r[2];

  always_ff @(posedge clk) begin
    b1_res_mult_r <= b1_res_mult_s;
  end

  assign b1_res_add_s = b1_res_mult_r + 16'h8000;

  always_ff @(posedge clk) begin
    b1_res_add_r <= b1_res_add_s;
  end

  // b2: DDS
  always_ff @(posedge clk) begin
    b2_rst_r[0] <= ic_rst;
    b2_rst_r[1] <= b2_rst_r[0];
  end
  dp_mod_dds #(
      .M(24),
      .L(15),
      .W(16)
  ) dp_mod_dds_module (
      .id_p_ac(),
      .ic_rst_ac(b2_rst_r[1]),
      .ic_en_ac(1'b1),
      .clk(clk),
      .od_sin_wave(b3_oud_dds_s)
  );
  // b3: Etapa final
  always_ff @(posedge clk) begin
    if (!ic_fm_am) begin
      b3_res_mux_r <= (b1_res_add_r >>> 1);
    end else begin
      b3_res_mux_r <= 16'h8000;
    end
  end

  assign b3_out_od_data_s = b3_res_mux_r * b3_oud_dds_s;

  always_ff @(posedge clk) begin
    b3_out_od_data_r <= b3_out_od_data_s;
  end

  // b4: propagacion de val_data
  always_ff @(posedge clk) begin
    ic_val_data_r[0] <= ic_val_data;
    ic_val_data_r[1] <= ic_val_data_r[0];
    ic_val_data_r[2] <= ic_val_data_r[1];
    ic_val_data_r[3] <= ic_val_data_r[2];
    ic_val_data_r[4] <= ic_val_data_r[3];
    ic_val_data_r[5] <= ic_val_data_r[4];
    ic_val_data_r[6] <= ic_val_data_r[5];
  end

  /* ASIGNACION SALIDAS ------------------------- */
  assign od_data = b3_out_od_data_r;
  assign oc_val_data = ic_val_data;  // HAY QUE MODIFICARLO

endmodule
