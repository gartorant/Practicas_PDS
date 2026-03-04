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
logic first_sample;        // Para detectar primera muestra y activar val/rst
integer err_cnt;           // Contador de errores
integer chk_sample_cnt;    // Contador de muestras comprobadas
logic do_check;            // Pulso interno para comparar (cuando val_out=1)
logic signed [15:0] o_data_F; // Salida esperada (File)
logic signed [15:0] o_data_M; // Salida del modelo (Module)


// Gestion I/O texto
integer data_in_file_val;
logic signed [15:0] data_in_file;
integer scan_data_in;
			// COMPLETAR --------------------------------
integer data_out_file_val;
logic signed [15:0] data_out_file;
integer scan_data_out;

integer cfg_file_val;
integer scan_cfg;

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
		//conf_fm_am = 0; 
		//p_frec_por = 1869961; 
		//im_am = 32767; 
		//im_fm = 0; 


        
        cfg_file_val = $fopen("./iof/id_config_dp_mod.txt", "r");
        assert (!cfg_file_val) begin
            $display("---> Error opening file id_config_dp_mod.txt");
			$stop;
		end
        
        scan_cfg = 0;
        scan_cfg = scan_cfg + $fscanf(cfg_file_val, "%d\n", p_frec_por);
        scan_cfg = scan_cfg + $fscanf(cfg_file_val, "%d\n", im_am);
        scan_cfg = scan_cfg + $fscanf(cfg_file_val, "%d\n", im_fm);
        scan_cfg = scan_cfg + $fscanf(cfg_file_val, "%d\n", conf_fm_am);
        if (scan_cfg != 4) begin
            $display("---> Error reading id_config_dp_mod.txt (expected 4 lines). Got=%0d", scan_cfg);
            $stop;
        end
        $fclose(cfg_file_val);

		//---------------------------------------------------
		// COMPLETAR CON LAS VARIABLES QUE FALTE POR INICIALIZAR
        err_cnt = 0;
        chk_sample_cnt = 0;
        first_sample = 1f'b1;
        do_check = 1'b0;
        o_data_F = '0;
        o_data_M = '0;
        
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
always@(posedge clk)
begin
    do_check <= 1'b0;

    // Cuando se active oc_val_data, leer od_dp_mod.txt y salida del UUT
    if (val_out)
    begin
        if (!$feof(data_out_file_val))
        begin
            scan_data_out = $fscanf(data_out_file_val, "%b", data_out_file);
            o_data_F <= #(PER/10) data_out_file;
            o_data_M <= #(PER/10) out_data;
            do_check <= 1'b1;
        end
        else
        begin
            $display("---> od_dp_mod.txt ended before DUT finished outputting.");
            $stop;
        end
    end
end

// Contador de errores y muestras
always@(posedge clk)
begin
    if (do_check)
    begin
        chk_sample_cnt = chk_sample_cnt + 1;
        if (o_data_F !== o_data_M)
            err_cnt = err_cnt + 1;
    end
end

// Fin de simulación
always@(end_sim)
	if (!end_sim)
		begin
		
			// COMPLETAR --------------------------------
            $display("########################################### ");
            $display(" TEST # ","%d", test_case);

            if (conf_fm_am==1'b0) $display(" AM MODULATION");
            else                  $display(" FM MODULATION");

            $display(" fsc = ","%0.2f"," MHz", fsc);
            $display(" fmod = ","%0.2f"," kHz", fmod);
            $display(" fc = ","%0.2f"," MHz", fc);

            $display(" Number of checked samples ","%d", chk_sample_cnt);
            $display(" Number of errors ","%d", err_cnt);
            $display("########################################### ");

            $fclose(data_out_file_val);
            //-------------------------------------------

        #(PER*2) $stop;
        end



endmodule 