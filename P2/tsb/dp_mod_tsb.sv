`timescale 1ns/1ps
import dp_mod_tsb_pkg::*; // PACKAGE WITH PARAMETERS TO CONFIGURE THE TB

module dp_mod_tsb();

parameter PER=10; // CLOCK PERIOD

logic rst_ac;
logic clk;
logic val_in;
logic conf_fm_am;
logic [23:0] p_frec_por;
logic [15:0] im_am;
logic [15:0] im_fm;
logic val_out;
logic signed [15:0] in_data;


// contadores y control
integer in_sample_cnt; // Contador de muestras de entrada
logic end_sim; // Indicación de simulación on/off
logic load_data;  // Inicio de lectura de datos
			// COMPLETAR --------------------------------

// Gestion I/O texto
integer data_in_file_val;
logic signed [15:0] data_in_file;
integer scan_data_in;
			// COMPLETAR --------------------------------


// Reloj
always #(PER/2) clk = !clk&end_sim;
 
// UUT
dp_mod UUT 
		   (.id_data(in_data),
			.id_frec_por(p_frec_por),
			.id_im_am(im_am),
			.id_im_fm(im_fm),
			.ic_fm_am(conf_fm_am),
			.ic_rst(rst_ac),
			.ic_val_data(val_in),
			.clk(clk),
			.od_data(out_data),
			.oc_val_data(val_out)
			);

initial	
	begin
		$display("########################################### ");
		$display("START TEST # ","%d", test_case);
		$display("########################################### ");
		data_in_file_val = $fopen("./iof/id_dp_mod.txt", "r");
		assert (!data_in_file_val) begin
			$display("---> Error opening file id_dp_mod.txt");
			$stop;
		end
		
		// MODIFICAR PARA QUE SE LEAN ESTOS VALORES DESDE 
		// EL FICHERO id_config_dp_mod.txt
		conf_fm_am = 0; 
		p_frec_por = 1869961; 
		im_am = 32767; 
		im_fm = 0; 
		//---------------------------------------------------
		
		// COMPLETAR CON LAS VARIABLES QUE FALTE POR INICIALIZAR


		//---------------------------------------------------
		end_sim = 1'b1;
		in_sample_cnt = 0;
		clk = 1'b1;
		val_in = 1'b0;
		rst_ac = 1'b1;
		load_data = 1'b0;
		#(10*PER);
		load_data = 1'b1;
	end

// Proceso de lectura de datos de entrada
always@(posedge clk)
     if (load_data)
         begin
			if (!$feof(data_in_file_val))
				begin
				in_sample_cnt = in_sample_cnt + 1;
				scan_data_in = $fscanf(data_in_file_val, "%b", data_in_file);						
				in_data <= #(PER/10) data_in_file; //Salida del fichero
				rst_ac  <= #(PER/10) 1'b0;
				val_in  <= #(PER/10) 1'b1;
				end
			else
				begin
				val_in <=   #(PER/10) 1'b0;
				load_data =   #(PER/10) 1'b0;
				end_sim = #(10*PER) 1'b0; // Hay que dejar un numero de peridodos 
				                          // mayor que la latencia del UUT
				$display(" Number of input samples ","%d", in_sample_cnt);
				
				end
				
		end
		
// Proceso de lectura de datos salida 


// Contador de errores y muestras


// Fin de simulación
always@(end_sim)
	if (!end_sim)
		begin
		
			// COMPLETAR --------------------------------

		#(PER*2) $stop;
		end



endmodule 