clc;
clear all;
close all;

%Index number  = 200693D
A = 6;
B = 9;
C = 3;

% Design Specifications
Ap  =   0.1+(0.01* A);          % Maximum passband ripple 
Aa  =   50 + B;                 % Minimum stopband attenuation 
w_p1 =   (C * 100) + 400;        % Lower passband edge 
w_p2 =   (C * 100) + 900;        % Upper passband edge 
w_s1 =   (C * 100) + 100;        % Lower stopband edge 
w_s2 =   (C * 100) + 1100;        % Upper stopband edge 
w_sm  =    2*(( C * 100) + 1500) ; % Sampling frequency

Ts=2*pi/w_sm; %sampling rate
fs=1/Ts;

wp=[w_p1 w_p2]; %passband range
w_sm=[w_s1 w_s2];   %stopband range

%warping
wp_warped=2*tan(wp*Ts/2)/Ts;    
ws_warped=2*tan(w_sm*Ts/2)/Ts;

%calculating order and passband range
[n,Wp] = ellipord(wp_warped, ws_warped , Ap, Aa,"s");  
[num,den] = ellip(n,Ap,Aa,Wp,"bandpass","s");

%apply bilinear transform
[dnum,dden]=bilinear(num,den,fs);   


%fvtool for coefficients of the transfer function of the IIR filter
fvtool(dnum,dden); 

[H,w]=freqz(dnum,dden,4001);
H_db=20*log10(abs(H));

%magnitude response of the digital filter for π ≤ ω < π rad/sample
figure;
plot([flip(-w); w], [flip(H_db); H_db])
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response')
ax = gca;
ax.YLim = [-200 20];
ax.XLim = [-pi pi];
grid on;
grid minor;

%magnitude response of passband
figure;
plot(w, H_db);
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response in passband')
ax = gca;
ax.YLim = [-0.2 0.2];
ax.XLim = [w_p1*Ts w_p2*Ts];
grid on;
grid minor;

