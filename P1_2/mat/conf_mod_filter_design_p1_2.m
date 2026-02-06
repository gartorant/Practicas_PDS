%% Compensacion del DAC
h_comp_DAC=[-1/16 1-2^-3 -1/16];

[H,Wf]=freqz(h_comp_DAC);
H(1)=H(2);
%H = H/max(abs(H));
if show_figures_on == 1
    figure(20)
    subplot(3,1,1)
    plot(Wf/(2*pi),20*log10(abs(H)));
    
    grid
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['FIR compensador DAC'])
end

% DAC
R=10;M=1;N=1;
hdac=ones(M*R,1);
[H,Wf]=freqz(hdac/(sum(hdac)));
H(1)=H(2);

if show_figures_on == 1
    figure(20)
    subplot(3,1,2)
    plot(R*Wf/(2*pi),20*log10(abs(H)),'-r');
    axis([0 0.5 -4 0.2])
    grid
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['Respuesta DAC'])
    hfinal=conv(hdac,upsample(h_comp_DAC,R)/R);
    [h,Wf]=freqz(hfinal,1,1e5);
    
    
    figure(20)
    subplot(3,1,3)
    plot(R*Wf/(2*pi),20*log10(abs(h)));
    grid
    hold on
    [H,Wf]=freqz(hdac/(sum(hdac)));
    H(1)=H(2);
    plot(R*Wf/(2*pi),20*log10(abs(H)),'r');
    axis([0 0.5 -4 0.2])
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['Compensación del DAC'])
    legend('DAC compensado',['DAC'])
    hold off
end

%% Compensacion CIC interpolador x 2000
% Se asume escalado de la salida de 2^ceil(log2(2000^2))

% CIC
R=2000;M=1;N=3;
h1=ones(M*R,1);
hcic=1;
for i=1:N 
	hcic=conv(h1,hcic); 
end
G_cic_int = ((M*R)^N)/R;

f_cic_scale = ceil(log2(G_cic_int));

if show_figures_on == 1
    [H,Wf]=freqz(hcic/R,1,1e5);
    H(1)=H(2);
    %H = H/max(abs(H));
    figure(30)
    subplot(2,1,1)
    plot(Wf/(2*pi),20*log10(abs(H)));
    
    grid
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['CIC: R=' num2str(R) ' M=' num2str(M) ' N=' num2str(N)])
end

% Compensador del CIC
order_comp_filter = 16;
f_max_comp = 0.4; % Máxima frec (normalizada) a compensar

f1=0:0.01:f_max_comp;
f=f1/(M*R);
resp=abs(sin(pi*f*R*M)./sin(pi*f)).^N;
resp = resp/max(abs(resp));
resp(1)=resp(2);
g_cic04=resp(end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if show_figures_on == 1
    figure(30)
    subplot(2,1,2)
    plot(f,20*log10(abs(resp)/2000));
    grid
    %axis([0 0.5/(M*R) abs(resp(2)/R)-8 abs(resp(2)/R)+0.2])
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['CIC en el rango a compensar: R=' num2str(R) ' M=' num2str(M) ' N=' num2str(N)])
end

h_comp_cic=remez(order_comp_filter,2*[f1 0.5],[1./resp 1/resp(end)]);
h_comp_cic = round(h_comp_cic*2^16)*2^-16;
[h,Wf]=freqz(h_comp_cic,1,1e5);

%%%%%%%%%%%%%%%%%%
if show_figures_on == 1
    figure(31)
    subplot(2,1,1)
    plot(f*M*R,20*log10(abs(resp)));
    axis([0 0.5 -8 0.2])
    grid
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SL}')
    title(['CIC (normalizado a G=1): R=' num2str(R) ' M=' num2str(M) ' N=' num2str(N)])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,1,2)
    plot(Wf/(2*pi),20*log10(abs(h)));grid
    h_comp04=20*log10(abs(h(round(length(h)*4/5))));
    g_comp04=abs(h(round(length(h)*4/5)));
    comp_g04 = g_comp04*g_cic04;
    
    axis([0 0.5 -0.2 8])
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SL}')
    title(['Compensador CIC: orden ' num2str(order_comp_filter) '; G(0.4)=' num2str(g_comp04) ' (' num2str(20*log10(g_comp04)) ' dB)'])
end

hcic=hcic*2^-f_cic_scale;

hfinal=conv(hcic,upsample(h_comp_cic,R)/R);

if show_figures_on == 1
    [h,Wf]=freqz(hfinal,1,1e5);
    
    
    figure(33) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(Wf/(2*pi),20*log10(abs(h)));
    grid
    hold on
    [H,Wf]=freqz(hcic/(sum(hcic)),1,1e5);
    H(1)=H(2);
    plot(Wf/(2*pi),20*log10(abs(H)),'r');
    hold off
    axis([0 0.001 -50 0])
    ylabel('|H(f)| dBs')
    xlabel('f/f_{SH}')
    title(['Compensador de CIC y CIC'])
    legend('Compensated CIC',['CIC: R=' num2str(R) ' M=' num2str(M) ' N=' num2str(N)])
end