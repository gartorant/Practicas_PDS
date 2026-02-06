clear all
close all
warning ('off','all');

% Show frequency responses of filters: 1->on, 0->off
show_figures_on = 0; 

%% AM MOD CONFIGURATION
fsc = 96;           % Sampling frequency (MHz) ->NO CAMBIAR<-
m_am = 1*(1-2^-15); % AM modulation index (range [0,1[) ->NO CAMBIAR<-
fc = 30;            % Carrier frequency (MHz)

%% TEST CASES:
test_case = 1

% List of test cases
% 1 : fmod = 2 kHz
% 2 : fmod = 5 kHz
% 3 : fmod = 10 kHz
% 4 : fmod = 20 kHz

switch test_case
    case 1 
        fmod= 2;    % Modulating frequency (kHz)
        n_periods_to_display = 4; % #periods to display
    case 2 
        fmod= 5;    % Modulating frequency (kHz)
        n_periods_to_display = 6; % #periods to display
    case 3 
        fmod= 10;    % Modulating frequency (kHz)
        n_periods_to_display = 8; % #periods to display
    case 4 
        fmod= 20;    % Modulating frequency (kHz)
        n_periods_to_display = 10; % #periods to display
    otherwise
        error ('--> This test case is not defined <--') 
end




%%
conf_mod_filter_design_p1_2
% Simulation time
sim_time = n_periods_to_display/fmod*1e3;

sim('modelo_dp_mod_am.slx') 
