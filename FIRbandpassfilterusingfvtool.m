clc;
clear all;
close all;
%Index number = 200693D
A = 6;
B = 9;
C = 3;
%Calculating filter specifications
Ap = 0.1+(0.01*A); %Maximum passband ripple in dB
Aa = 50+B; %Minimum stopband attenuation in dB
w_p1 = (C*100)+400; %Lower passband edge in rad/s
w_p2 = (C*100)+900; %Upper passband edge in rad/s
w_s1 = (C*100)+100; %Lower stopband edge in rad/s
w_s2 = (C*100)+1100; %Upper stopband edge in rad/s
w_sm = 2*((C*100)+1500); %Sampling frequency in rad/s

Ts = (2*pi)/w_sm; %Sampling period in s
fs=1/Ts; %Sampling frequency in Hz

%Determining Kaiser Window Parameters
Bt = min((w_p1-w_s1), (w_s2 - w_p2)); %critical transition width in rad/s
Oc1 = w_p1 - (Bt/2); %lower cutoff frequency in rad/s
Oc2 = w_p2 + (Bt/2); %upper cutoff frequency in rad/s
dp = (10^(0.05*Ap) - 1)/(10^(0.05*Ap) + 1); %Calculating delta_p
da = 10^(-0.05*Aa); %Calculating delta_a

%Corresponding discrete frequencies
wp1 = w_p1 * Ts;
wp2 = w_p2 * Ts;
ws1 = w_s1 * Ts;
ws2 = w_s2 * Ts;

%Window coefficients
f_edges = [w_s1 w_p1 w_p2 w_s2] / (2 * pi);
amplitudes = [0 1 0];
deviations = [da dp da];
[N,Wn,beta,ftype] = kaiserord(f_edges, amplitudes, deviations, fs);

%Kaiser window
kaiser_window = kaiser(N+1, beta); % n+1 is no of points in window
%FIR filter
h = fir1(N, Wn, ftype, kaiser_window, 'noscale'); %Impulse response
fvtool(h);

% Magnitude and phase response
[H,w] = freqz(h, 1, 2001);
Hdb = 20 * log10(abs(H));
grid on;
grid minor;
figure;
plot([flip(-w); w], [flip(Hdb); Hdb])
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response')

ax = gca;
ax.YLim = [-120 20];
ax.XLim = [-pi pi];
grid on;
grid minor;
figure;
plot(w, Hdb);
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response in passband')
ax = gca;
ax.YLim = [-0.05 0.05];
ax.XLim = [wp1 wp2];
grid on;
grid minor;


