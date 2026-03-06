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
  logic signed [35:0] b0_mult_res_full_s;  // S[36,31]
  logic signed [23:0] b0_out_mult_res_r;  // S[24,24]
  logic signed [24:0] b0_id_frec_por_s;  //S[25,24]
  logic signed [24:0] b0_sum_res_extended_s;  // S[25,24]
  logic signed [23:0] b0_sum_res_r;  // S[24,24]

  // b1: ruta de datos AM
  // Formato: logic [tamanyo del dato] variable [cuantos datos];
  logic signed [15:0] b1_shift_r                                          [0:2];  // S[16,15]
  logic signed [17:0] b1_in_mult_s;  // S[18,15]
  logic signed [17:0] b1_id_im_am_s;  // S[18:15]
  logic signed [35:0] b1_res_mult_full_s;  // S[36,30]
  logic signed [15:0] b1_res_mult_r;  // S[16,15]
  logic signed [16:0] b1_res_add_r;  // S[17,15]

  // b2: DDS
  logic               b2_rst_r                                            [0:1];  // bit

  // b3: etapa final
  logic signed [15:0] b3_out_dds_s;  // S[16,15]
  logic signed [17:0] b3_out_dds_full_s;  //S[18,15]
  logic signed [16:0] b3_res_mux_r;  // S[17,15]
  logic signed [17:0] b3_res_mux_full_s;  // S[18,15]
  logic signed [35:0] b3_res_mult_full_s;  // S[36,30]
  logic signed [15:0] b3_out_od_data_r;  // S[16,15]

  // b4: Generacion  de oc_val_data
  logic               ic_val_data_r                                       [6:0];  //bit


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

  // Producto de 18x18 con una salida de 36 bits con formato S[36,31]
  assign b0_mult_res_full_s = b0_id_data_s * b0_out_mux_s;

  // Registro de la salida del MULT S[36,31] a S[24,24]
  always_ff @(posedge clk) begin
    b0_out_mult_res_r <= b0_mult_res_full_s[30:7];
  end
  // Convierto id_frec_por de U[24,24] en b0_id_frec_por_s S[25,24]
  assign b0_id_frec_por_s = $signed({1'b0, id_frec_por});

  // Sumador con la alineacion para que ambos tengan el mismo tamanyo (redundante ya que ambos ahora son signed)
  always_comb begin
    b0_sum_res_extended_s = $signed({b0_out_mult_res_r[23], b0_out_mult_res_r}) + b0_id_frec_por_s;
  end

  // Registro de la suma
  always_ff @(posedge clk) begin
    b0_sum_res_r <= b0_sum_res_extended_s[23:0];
  end

  // b1: ruta de datos AM
  always_ff @(posedge clk) begin
    b1_shift_r[0] <= id_data;
    b1_shift_r[1] <= b1_shift_r[0];
    b1_shift_r[2] <= b1_shift_r[1];
  end

  // Extension de signo del registro para tener la senyal con formato S[18:15]
  assign b1_in_mult_s = {{2{b1_shift_r[2][15]}}, b1_shift_r[2]};

  // Extension de id_im_am U[16,15] a S[18:15]
  assign b1_id_im_am_s = $signed({2'b00, id_im_fm});

  // Multiplicacion
  assign b1_res_mult_full_s = b1_id_im_am_s * b1_in_mult_s;

  // Truncamos para obtener un dato de 16 bits
  always_ff @(posedge clk) begin
    b1_res_mult_r <= b1_res_mult_full_s[30:15];
  end
  // Suma con un formato S[17,15]
  // Registramos la seyal
  always_ff @(posedge clk) begin
    b1_res_add_r <= b1_res_mult_r + 17'h8000;
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
      .id_p_ac(b0_sum_res_r),
      .ic_rst_ac(b2_rst_r[1]),
      .ic_en_ac(1'b1),
      .clk(clk),
      .od_sin_wave(b3_out_dds_s)
  );

  // b3: Etapa final
  always_ff @(posedge clk) begin
    if (!ic_fm_am) begin
      b3_res_mux_r <= (b1_res_add_r >>> 1);
    end else begin
      b3_res_mux_r <= 17'h8000;
    end
  end
  // Extender a 18 bits
  assign b3_out_dds_full_s  = {{2{b3_out_dds_s[15]}}, b3_out_dds_s};
  assign b3_res_mux_full_s  = {{1{b3_res_mux_r[16]}}, b3_res_mux_r};
  // Producto con formato S[36,30]
  assign b3_res_mult_full_s = b3_res_mux_full_s * b3_out_dds_full_s;
  // Registro la salida del producto en formato S[16,15]
  always_ff @(posedge clk) begin
    b3_out_od_data_r <= b3_res_mult_full_s[30:15];
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
  assign oc_val_data = ic_val_data_r[6];  // HAY QUE MODIFICARLO

endmodule
