clear all
warning off
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lab P2: MODULADOR AM/FM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generation of test files
file_test_gen = 1; %1-> yes; 0->no

% Open figures
open_figs = 1; %1-> yes; 0->no

% Name of the model to simulate
name_slx_model = 'dp_mod_model';

% Name of the SV testbench
tsb_name = 'dp_mod_tsb';

% Directory to place the test files and the package for tsb.
file_dir = '../sim/iof/';
tsb_dir = '../tsb/'; 

%% TEST CASES:
test_case = 1;

% List of test cases
% 1 : AM, fmod=1 KHz,   fc=10.7 MHz, im_am = (1-2^-15) 
% 2 : FM, fmod=1 KHz,   fc=10.7 MHz, im_fm = 150 kHz  
% 3 : AM, fmod=20 KHz,   fc=40 MHz, im_am = (1-2^-15)
% 4 : FM, fmod=20 KHz,   fc=40 MHz, im_fm = 500 kHz,

%%%%% TO COMPLETE BY THE STUDENT
% 5 : FM, fmod=5 KHz,   fc=10.7 MHz, im_fm = 500 kHz,
% 6 : AM, fmod=5 KHz,   fc=40   MHz, im_am = (1-2^-15)
switch test_case
    case 1 
         conf_fm_am = 0; % Control FM --> 1, AM --> 0
         fmod = 1; % KHz
         fc = 10.7; % MHz
         im_am = (1-2^-15);
         im_fm = 0; % kHz
         n_periods_to_display = 2; % Number of period to display 
    case 2 
         conf_fm_am = 1; % Control FM --> 1, AM --> 0
         fmod = 1; % KHz
         fc = 1; % MHz
         im_am = 0;
         im_fm = 700; % kHz
         n_periods_to_display = 1; % Number of period to display 
    case 3
         conf_fm_am=0; % Control FM --> 1, AM --> 0
         fmod = 20; % KHz
         fc = 40; % MHz;
         im_am = (1-2^-15);
         im_fm = 0; % kHz
         n_periods_to_display = 10; % Number of period to display 
    case 4
         conf_fm_am=1; % Control FM --> 1, AM --> 0
         fmod = 0.5; % KHz
         fc = 10.7; % MHz;
         im_am = 0.1;
         im_fm = 500; % kHz
         n_periods_to_display = 2; % Number of period to display
 
    %%%% TO COMPLETE BY THE STUDENT
     case 5
         conf_fm_am=1; % Control FM --> 1, AM --> 0
         fmod = 5; % KHz
         fc = 10.7; % MHz;
         im_am = 0.1;
         im_fm = 0; % kHz
         n_periods_to_display = 2; % Number of period to display

     case 6
         conf_fm_am=0; % Control FM --> 1, AM --> 0
         fmod = 5; % KHz
         fc = 40; % MHz;
         im_am = (1-2^-15);
         im_fm = 0; % kHz
         n_periods_to_display = 2; % Number of period to display

    otherwise
        error ('--> This test case is not defined <--') 
end


% Clock frequency (MHz) 
%%%%% DO NOT CHANGE THIS VALUE
fsc = 96; % MHz


%% Simulation 
%n_periods_to_display = 10; % Number of period to display 
sim_time = n_periods_to_display/fmod*1e3;

disp('*****************************************')
disp(['** Simulation case ' num2str(test_case)])
disp('*****************************************')
if conf_fm_am == 0
    disp(['-- MODULADOR AM --'])
else
    disp(['-- MODULADOR FM --'])
end
disp(['fclk = ' num2str(fsc) ' MHz'])
disp(['fmod = ' num2str(fmod) ' kHz'])
disp(['fc = ' num2str(fc) ' MHz'])
if conf_fm_am == 0
    disp(['im_am = ' num2str(im_am) ])
else
    disp(['im_fm = ' num2str(im_fm) ' kHz'])
end
disp('*****************************************')

%% Verilog simulation values
% Carrier frequency: U[24,24]
frec_por_int = round(fc/fsc*2^24);            
% AM index: U[16,15]
im_am_int =  round(im_am*2^15);
% FM index: U[16,16]
im_fm_int =  round(im_fm*1e-3/fsc*2^16);

disp(' ')
disp('*****************************************')
disp('Values for HDL simulation')
disp('*****************************************')
disp(['ic_fm_am = ' num2str(conf_fm_am)])
disp(['id_frec_por = ' num2str(frec_por_int)])
disp(['id_im_am = ' num2str(im_am_int)])
disp(['id_im_fm = ' num2str(im_fm_int)])
disp('*****************************************')


sim([ name_slx_model '.slx']) % Launch Simulink model


%% Figures
if open_figs == 1
    L_s_in= length(s_in);
    if conf_fm_am == 0 % AM
        subplot(2,1,1)
        plot((1:L_s_in),s_in(1:L_s_in))
         ylabel('s_{mod}(n)')
        axis([0 L_s_in -1 1])
        subplot(2,1,2)
        plot((1:L_s_in),s_am(1:L_s_in))
        ylabel('s_{am}(n)')
        xlabel('n')
        axis([0 L_s_in -1 1])
        subplot(2,1,1)
        title('MODULADOR AM')
    else % FM
        subplot(2,1,1)
        plot((1:L_s_in),s_in(1:L_s_in))
        ylabel('s_{mod}(n)')
        axis([0 L_s_in -1 1])
        subplot(2,1,2)
        plot((1:L_s_in),s_fm(1:L_s_in))
        ylabel('s_{fm}(n)')
        xlabel('n')
        axis([0 L_s_in -1 1])
        subplot(2,1,1)
        title('MODULADOR FM')
    end
end

%% I/O test files
if file_test_gen == 1

    % Configuration file 'id_config_dp_mod.txt'
    f=sprintf([file_dir 'id_config_dp_mod.txt']);
    pack_f=fopen(f,'w');
	
		%%%% TO COMPLETE BY THE STUDENT
    fprintf(pack_f,'%d\n',frec_por_int);
    fprintf(pack_f,'%d\n',im_am_int);
    fprintf(pack_f,'%d\n',im_fm_int);
    fprintf(pack_f,'%d',conf_fm_am);   
    fclose(pack_f);

    % Input data file 'id_dp_mod.txt'
    q_in = quantizer([16 15],'wrap','floor');
    f=sprintf([file_dir 'id_dp_mod.txt']);
    num_data_in = length(s_in);
    pack_f=fopen(f,'w');
    for i=1:num_data_in-1
       fprintf(pack_f,[num2bin(q_in,s_in(i)) '\n']);
    end
    fprintf(pack_f,[num2bin(q_in,s_in(i+1))]);

    fclose(pack_f);

    % Output data file 'od_dp_mod.txt'
    q_out = quantizer([16 15],'wrap','floor');
    f=sprintf([file_dir 'od_dp_mod.txt']);
    pack_f=fopen(f,'w');
    
    % Elegir la señal de salida según AM/FM
    if conf_fm_am == 0
        s_out = s_am; % AM
    else
        s_out = s_fm; % FM
    end
    
    num_data_out = length(s_out);
    
    for i = 1:num_data_out-1
        fprintf(pack_f,[num2bin(q_out, s_out(i)) '\n']);
    end
    fprintf(pack_f,[num2bin(q_out, s_out(num_data_out))]);
    
    fclose(pack_f);


    % Package with parameters
    f=sprintf([tsb_dir tsb_name '_pkg.sv']);
    pack_f=fopen(f,'w');
    fprintf(pack_f,'package %s_pkg; \n',tsb_name);
    fprintf(pack_f,' \n');
    fprintf(pack_f,'integer test_case = %d; // #case for test \n',test_case);
    fprintf(pack_f,'integer in_sample_num = %d; // #processed input samples \n',num_data_in);
    fprintf(pack_f,' \n');
    
	    %%%% TO COMPLETE BY THE STUDENT
	fprintf(pack_f,'real fsc  = %0.15g; // MHz \n', fsc);
    fprintf(pack_f,'real fmod = %0.15g; // kHz \n', fmod);
    fprintf(pack_f,'real fc   = %0.15g; // MHz \n', fc);
    fprintf(pack_f,'real im_am = %0.15g; \n', im_am);
    fprintf(pack_f,'real im_fm = %0.15g; // kHz \n', im_fm);

	fprintf(pack_f,' \n');
    fprintf(pack_f,'endpackage');
    fclose(pack_f);

end