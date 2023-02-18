clc;
clear;
close all;
%Index number = 200693D
A = 6;
B = 9;
C = 3;
%Filter Specifications
Ap = 0.1 + (0.01*A); %Maximum passband ripple in dB
Aa = 50 + B; %Minimum stopband attenuation in dB
w_p1 = (C*100) + 400; %Lower passband edge in rad/s
w_p2 = (C*100) + 900; %Upper passband edge in rad/s
w_a1 = (C*100) + 100; %Lower stopband edge in rad/s
w_a2 = (C*100) + 1100; %Upper stopband edge in rad/s
w_s = 2*((C*100) + 1500); %Sampling frequency in rad/s
Ts = 2*pi/w_s; %Sampling period in s
Bt = min((w_p1-w_a1),(w_a2-w_p2)); %Transition width in rad/s
w_c1 = w_p1 - Bt/2; %Lower cutoff frequency in rad/s
w_c2 = w_p2 + Bt/2; %Upper cutoff frequency in rad/s

%Determining Kaiser Window Parameters
%Calculating delta_p
dp = (10^(0.05*Ap)-1)/((10^(0.05*Ap)+1));
%Calculating delta_a
da = 10^(-0.05*Aa);
%Selecting the minimum delta
delta = min(dp,da);
%Actual passband ripple in dB
Ap = 20*log10((1+delta)/(1-delta));
%Actual stopband attenuation in dB
Aa = -20*log10(delta);
%Choosing alpha
if Aa <= 21
alpha = 0;
elseif Aa > 21 && Aa <= 50
alpha = 0.5842*(Aa-21)^0.4 + 0.07886*(Aa-21);
else
alpha = 0.1102*(Aa-8.7);
end
%Choosing D
if Aa <= 21
D = 0.9222;
else
D = (Aa - 7.95)/14.36;
end
%Choosing the length of the filter
N = ceil((w_s*D/Bt)+1);
if rem(N,2) == 0
N = N+1;
end
%Filter duration
range = 0:1:N-1;
M = (N-1)/2;
n = 0:1:M;
%Calculating beta

beta = alpha*sqrt(1-((2*n)/(N-1)).^2);
%No.of iterations
Iter = 100;
%Generating I(alpha)
I_alpha = 1;
for i = 1:Iter
I_alpha = I_alpha + ((1/factorial(i))*((alpha/2)^i))^2;
end
%Generating I(beta)
I_beta = 1;
for i = 1:Iter
I_beta = I_beta + ((1/factorial(i))*((beta/2).^i)).^2;
end
%defining the kaiser window
kaiser_win = I_beta/I_alpha;
kaiser_win = [fliplr(kaiser_win(2:end)) kaiser_win];
%assuming an idealized frequency response
hnT = zeros(1,N);
for i = 0:M
if i == 0
hnT(i+M+1) = (2/w_s)*(w_c2 - w_c1);
else
hnT(i+M+1) = (1/(i*pi))*(sin(w_c2*i*Ts) - sin(w_c1*i*Ts));
end
end
hnT(1:M) = fliplr(hnT(M+2:end));
%Defining the filter
filter = kaiser_win.*hnT;

%Plotting the impulse response of the filter - time domain
stem(range, filter)
axis([0 N-1 -0.2 0.3])
grid on
xlabel('n')
ylabel('Amplitude h[n]')
title('Impulse Response - Time Domain')

%magnitude response of the digital filter for -π ≤ ω < π rad/sample
[H_dB,w] = freqz(filter);
H_dB = 20*log10(abs(H_dB));
figure;
plot([flip(-w); w], [flip(H_dB); H_dB])
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response')
axis([-pi pi -120 20])
grid on;

%magnitude response of pass band
figure;
plot(w/pi,db(H_dB))
xlim([w_p1*2/w_s w_p2*2/w_s])
xlabel('\Omega (rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude response in passband')
grid on;
