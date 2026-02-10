clear all
warning off
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lab P1: DDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generation of test files
file_test_gen = 1; %1-> yes; 0->no

% Open figures
open_figs = 1; %1-> yes; 0->no

% Name of the model to simulate
name_slx_model = 'dds_test_model';

% Name of the SV testbench
tsb_name = 'dds_test_tsb';

% Directory to place the test files and the package for tsb.
file_dir = '../sim/iof/';
tsb_dir = '../tsb/'; 

%% TEST CASES:
test_case = 1;

% List of test cases
% 1 : fo=1.1 MHz,   M = 27, L=15, W=14 
% 2 : fo=40 MHz,    M = 27, L=15, W=14 
% 3 : fo=0.013 MHz, M = 20, L=15, W=14 
% 4 : fo=0.24 MHz,  M = 20, L=15, W=16 

%%%%% TO COMPLETE BY THE STUDENT

% DEBUGGING CASES:
% 101 : fo=0.1 MHz, M = 16, L=6, W=16 Debug case 1
% 102 : fo=1 MHz, M = 16, L=6, W=16 Debug case 2



switch test_case
    case 1 
        fo=1.1; % DDS generated frequency MHz
        M=27; % Accumulator length in bits
        L=15; % Accumulator truncated phase in bits (L <= M)
        W=14; % Sine LUT word-length in bits
    case 2
        fo=40; % DDS generated frequency MHz
        M=27; % Accumulator length in bits
        L=15; % Accumulator truncated phase in bits (L <= M)
        W=14; % Sine LUT word-length in bit
    case 3
        fo=0.013; % DDS generated frequency MHz
        M=20; % Accumulator length in bits
        L=15; % Accumulator truncated phase in bits (L <= M)
        W=14; % Sine LUT word-length in bits
    case 4
        fo=2.3; % DDS generated frequency MHz
        M=20; % Accumulator length in bits
        L=15; % Accumulator truncated phase in bits (L <= M)
        W=16; % Sine LUT word-length in bits        

    %%%% TO COMPLETE BY THE STUDENT
    case 101 % Debug case 1
        fo=0.1; % DDS generated frequency MHz
        M=16; % Accumulator length in bits
        L=6; % Accumulator truncated phase in bits (L <= M)
        W=16; % Sine LUT word-length in bits

   case 102 % Debug case 2
        fo=1; % DDS generated frequency MHz
        M=16; % Accumulator length in bits
        L=6; % Accumulator truncated phase in bits (L <= M)
        W=16; % Sine LUT word-length in bits
    otherwise
        error ('--> This test case is not defined <--') 
end


% DDS clock frequency (MHz) 
%%%%% DO NOT CHANGE 
fclk = 96; % MHz

% Accumulator step Pesc 
%%%%% TO COMPLETE BY THE STUDENT
P = (2^M)*fo/fclk;
Pesc = P/(2^M);

%% DO NOT CHANGE 
%% Simulation 
n_periods_to_display = 10; % Number of period to display 
Nsamples = 5e2; % Maximum #sapmles
sim_time = n_periods_to_display/fo;
while ((sim_time>Nsamples/fclk) & (n_periods_to_display>1) )
    n_periods_to_display = n_periods_to_display - 1;
    sim_time = n_periods_to_display/fo+20/fclk;
end

disp('*****************************************')
disp(['** Simulation case ' num2str(test_case)])
disp('*****************************************')
disp(['fclk = ' num2str(fclk) ' MHz'])
disp(['fo = ' num2str(fo) ' kHz'])
disp('*****************************************')
disp(['M = ' num2str(M) ' bits'])
disp(['L = ' num2str(L) ' bits'])
disp(['W = ' num2str(W) ' bits'])
disp(['P = ' num2str(P)])
disp('*****************************************')
if L>M
    disp(' ')
    display ('-->ERROR: L debe ser menor o igual a M')
end

sim([ name_slx_model '.slx']) % Launch Simulink model


%% Figures
if open_figs == 1
    figure(101)
    t = (0:length(sin_wave)-1)/(fclk*1e6);
    subplot(3,1,1)
    plot(t,sin_wave)
    legend('sin\_wave')
    ylabel('Amplitud')
    xlabel('t')
    xlim([t(1) t(end)])
    subplot(3,1,2)
    plot(t,ramp_wave)
    legend('ramp\_wave')
    ylabel('Amplitud')
    xlabel('t')
    xlim([t(1) t(end)])
    subplot(3,1,3)
    plot(t,sqr_wave)
    legend('sqr\_wave')
    ylabel('Amplitud')
    xlabel('t (s)')
    xlim([t(1) t(end)])
    subplot(3,1,1)
    title(['fo= ' num2str(fo) ' Mhz'])
end

%% I/O test files
if file_test_gen == 1
    % Configuration file
    f=sprintf([file_dir 'id_config_dds_test.txt']);
    pack_f=fopen(f,'w');
    fprintf(pack_f,[num2str(Pesc*2^M) '\n']);
    fclose(pack_f);
    
    % output files
    q_out = quantizer([W W-1],'wrap','floor');
    f=sprintf([file_dir 'od_dds_test.txt']);
    num_data = length(sin_wave);
    pack_f=fopen(f,'w');
    for i=1:length(sin_wave)
       fprintf(pack_f,[num2bin(q_out,sin_wave(i)) ' '...
                       num2bin(q_out,ramp_wave(i)) ' '...
                       num2bin(q_out,sqr_wave(i))  '\n']);
    end
    fclose(pack_f);


    % Package with parameters
    f=sprintf([tsb_dir tsb_name '_pkg.sv']);
    pack_f=fopen(f,'w');
    fprintf(pack_f,'package %s_pkg; \n',tsb_name);
    fprintf(pack_f,' \n');
    fprintf(pack_f,'integer test_case = %d; // #case for test \n',test_case);
    fprintf(pack_f,'integer in_sample_num = %d; // #processed input samples \n',num_data);
    fprintf(pack_f,' \n');
    fprintf(pack_f,'parameter M = %d; // DDS accumulator wordlength\n',M);
    fprintf(pack_f,'parameter L = %d; // DDS phase truncation wordlength\n',L);
    fprintf(pack_f,'parameter W = %d; // DDS ROM wordlength\n',W);
    fprintf(pack_f,' \n');
    fprintf(pack_f,'endpackage');
    fclose(pack_f);

end