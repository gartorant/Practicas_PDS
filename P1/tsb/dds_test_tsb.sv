`timescale 1ns/1ps
import dds_test_tsb_pkg::*; // PACKAGE WITH PARAMETERS TO CONFIGURE THE TB

module dds_test_tsb();

parameter PER=10; // CLOCK PERIOD

logic [M-1:0] P;
logic rst_ac;
logic en_ac;
logic clk;
logic val_in;
logic val_out;
logic signed [W-1:0] sin_wave;
logic signed [W-1:0] ramp_wave;
logic signed [W-1:0] sqr_wave;
logic signed [W-1:0] sin_wave_M, sin_wave_F;
logic signed [W-1:0] ramp_wave_M, ramp_wave_F;
logic signed [W-1:0] sqr_wave_M, sqr_wave_F;

// contadores y control
integer in_sample_cnt; // Contador de muestras de entrada
integer error_cnt; // Contador de errores
integer sample_cnt; // Contador de muestras comprobadas a la salida
logic end_sim; // Indicación de simulación on/off
logic load_data;  // Inicio de lectura de datos

// Gestion I/O texto
integer conf_in_file;
integer data_conf;
integer scan_data_conf;
integer data_out_file;
integer scan_data_out;
logic signed [W-1:0] dout_waves;

// Reloj
always #(PER/2) clk = !clk&end_sim;
 
// UUT
dds_test #(.M(M),.L(L),.W(W)) UUT 
		   (.id_p_ac(P),
			.ic_rst_ac(rst_ac),
			.ic_en_ac(en_ac),
			.ic_val_data(val_in),
			.clk(clk),
			.od_sqr_wave(sqr_wave),
			.od_ramp_wave(ramp_wave),
			.od_sin_wave(sin_wave),
			.oc_val_data(val_out)
			);


initial	
	begin
		$display("########################################### ");
		$display("START TEST # ","%d", test_case);
		$display("########################################### ");
		conf_in_file = $fopen("./iof/id_config_dds_test.txt", "r");
		data_out_file = $fopen("./iof/od_dds_test.txt", "r");
		scan_data_conf = $fscanf(conf_in_file, "%d\n", data_conf);
		P = data_conf; // Lectura del paso del acumulador
		end_sim = 1'b1;
		error_cnt = 0;
		sample_cnt = 0;
		in_sample_cnt = 0;
		clk = 1'b1;
		val_in = 1'b0;
		rst_ac = 1'b1;
		en_ac = 1'b0;
		load_data = 1'b0;
		#(10*PER);
		load_data = 1'b1;
	end

// Proceso de lectura de datos de entrada
always@(posedge clk)
     if (load_data)
         begin
			if (in_sample_cnt < in_sample_num)
				begin
				in_sample_cnt = in_sample_cnt + 1;
				rst_ac <= 1'b0;
				val_in <= 1'b1;
				en_ac <= 1'b1;
				end
			else
				begin
				val_in <= 1'b0;
				load_data = 1'b0;
				end_sim = #(10*PER) 1'b0; // Hay que dejar un numero de peridodos 
				                          // mayor que la latencia del UUT
				$display(" Number of input samples ","%d", in_sample_cnt);
				
				end
				
		end
		
// Proceso de lectura de salida 
always@(posedge clk)
       if (val_out)
			begin
				sample_cnt = sample_cnt +1;
				if (!$feof(data_out_file))
					begin
					scan_data_out = $fscanf(data_out_file, "%b", dout_waves);						
					sin_wave_F <= #(PER/10) dout_waves; //Salida del fichero
					sin_wave_M <= #(PER/10) sin_wave; //Salida del modulo UUT
					scan_data_out = $fscanf(data_out_file, "%b", dout_waves);	
					ramp_wave_F <= #(PER/10) dout_waves; //Salida del fichero
					ramp_wave_M <= #(PER/10) ramp_wave; //Salida del modulo UUT					
					scan_data_out = $fscanf(data_out_file, "%b\n", dout_waves);
					sqr_wave_F <= #(PER/10) dout_waves; //Salida del fichero
					sqr_wave_M <= #(PER/10) sqr_wave; //Salida del modulo UUT					
					end
				else
					end_sim = #(10*PER) 1'b0;
			end

// Contador de errores y muestras
always@(sin_wave_F,sin_wave_M,ramp_wave_F,ramp_wave_M,sqr_wave_F,sqr_wave_M)
	Assert_error_out:
		assert (sin_wave_F==sin_wave_M && ramp_wave_F==ramp_wave_M && sqr_wave_F==sqr_wave_M)
			//$display("OK ","%d", sample_cnt);
			else begin
				error_cnt = error_cnt + 1;
				$display("Error in sample number ","%d", sample_cnt);
				end   

// Fin de simulación
always@(end_sim)
	if (!end_sim)
		begin
			$display("########################################### ");
			$display("TEST # %d", test_case);
			$display("M = %d", M);
			$display("L = %d", L);
			$display("W = %d", W);
			$display("P = %d", P);
			$display("########################################### ");
			$display("Number of checked samples ","%d", sample_cnt);	
			$display("Number of errors ","%d", error_cnt);
			$display("########################################### ");
			#(PER*2) $stop;
		end
endmodule 