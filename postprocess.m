function [t,roll,pitch,f,roll_f,pitch_f] = postprocess(t0,Fs,x,y,z)
%% POSTPROCESS
%
% DESCRIPTION
%   Process data acquired from capture and configuration files and convert
%   into roll and pitch.
%
% INPUTS
%   x,y,z - Raw data captured in each plane
%   t0 - Starting time 
%   Fs - Sample rate
%
% OUTPUTS
%   roll - Roll time series
%   pitch - Pitch time series
%   roll_f - Roll in frequency domain
%   pitch_ f - Pitch in frequency domain
%   f - Frequency domain
%   t - Time vector
%
% COPYRIGHT (C) Lauren Miller 2016

Gx = 2 * 9.81 * x / 2^7; % Data in terms of gravity
Gy = 2 * 9.81 * y / 2^7;
Gz = 2 * 9.81 * z / 2^7;

roll = atan(-1 * Gx ./ Gz); % Compute roll (rad)
pitch = atan(Gy ./ sqrt(Gx.^2 + Gz.^2)); % Compute pitch (rad)

[~, roll_f, ~, roll] = frequency(roll, Fs, t0); % Perform fft
[f, pitch_f, t, pitch] = frequency(pitch, Fs, t0);

end

function [f,P1db,t,data] = frequency(data,Fs,t0)
%% FREQUENCY 
%
% DESCRIPTION
%   Collect roll and pitch time series' and perform fft.
%
% INPUTS
%   data1 - Original time series aquired
%   Fs - Sample rate 
%   t0 - Starting time
%
% OUTPUTS
%   data1 - Original time series aquired
%   f - Frequency domain
%   P1 - Spectrum
%   t - Time vector

L = length(data); % Length of signal
T = 1/Fs; % Time period 
t = (0:L-1)'*T + t0; % Time vector
Y = fft(data); % Perform fast fourier transform
P2 = abs(Y/L); % Compute double-sided spectrum
P1 = P2(1:L/2+1); % Compute single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1); % Compute even-valued signal length L
P1db = mag2db(P1); % Convert to dB
f = Fs*(0:L/2)'/L; % Define frequency domain

end