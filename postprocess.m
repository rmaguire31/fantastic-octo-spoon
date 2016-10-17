%% Post Processing
%
% DESCRIPTION
%  Process data acquired from capture and configuration files and
%  determine various signal characteristics
%
% INPUTS
%  data1 - Original time series aquired
%  Fs - Sample rate 
%
% OUTPUTS
%  f - Domain
%  P1 - Spectrum

function [f,P1] = postprocess(data1,Fs)

L = length(data1); % Length of signal 
T = 1/Fs; % Time period 
t = (0:L-1)*T; % Time vector
Y = fft(data1); % Perform fast fourier transform
P2 = abs(Y/L); % Compute double-sided spectrum
P1 = P2(1:L/2+1); % Compute single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1); % Compute even-valued signal length L
f = Fs*(0:(L/2))/L; % Define frequency domain
plot(f,P1) % Display spectrum
title('Single-Sided Amplitude Spectrum of Time Series')
xlabel('f (Hz)')
ylabel('|P1(f)|')

end

