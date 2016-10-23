%% Analysis

% DESCRIPTION
%  Load data from JSONLOAD, conduct analysis and display plots
% INPUTS
%  json - MATLAB object representing JSON file
%  roll - Roll time series
%  pitch - Pitch time series
%  roll_f - Roll in frequency domain
%  pitch_ f - Pitch in frequency domain
%  t0 - Starting time
%  Fs - Sample rate
% OUTPUTS
%  mean_p - Mean pitch
%  mean_r - Mean roll
%  var_p - Variance of roll
%  var_r - Variance of pitch
%  t - Time vector
%  f - Domain


function [t,f,mean_p,mean_r,var_p,var_r] = analyse(json,roll,pitch,roll_f,pitch_f,t0,Fs)
load json
T = 1/Fs; % Time period 
t = (0:L-1)'*T + t0; % Time vector
f = Fs*(0:L/2)'/L; % Define frequency domain

subplot(4,1,1); % Display several plots at once
plot(t,roll);
title('Roll Time Series');
xlabel('t(s)');
ylabel('Roll Acceleration(ms^2)');
    
subplot(4,1,2);
plot(f,roll_f);
title('Single-Sided Amplitude Spectrum of Roll(t)')
xlabel('f(Hz)');
ylabel('|P1(f)|');
    
subplot(4,1,3);
plot(t,pitch)
title('Pitch Time Series');
xlabel('t(s)');
ylabel('Pitch Acceleration(ms^2)');
    
subplot(4,1,4);
plot(f,pitch_f);
title('Single-Sided Amplitude Spectrum of Pitch(t)')
xlabel('f(Hz)');
ylabel('|P1(f)|');
    
mean_p = mean(pitch); % Conduct statistical analysis
fprintf('Mean of Pitch Acceleration is: %\n', mean_p);
mean_r = mean(roll); 
fprintf('Mean of Roll Acceleration is: %\n\n', mean_r);
var_p = var(pitch);
fprintf('Variance of Pitch Acceleration is: %\n', var_p);
var_r = var(roll); 
fprintf('Variance of Roll Acceleration is: %\n\n', var_r);

num_samples = floor(t/f); % Define time intervals 
select = json(0:1:num_samples); % Select range of spectrum 
[pks,locs] = findpeaks(select,Fs,'MinPeakDistance',0.005); 

% Choose tallest peak
% Eliminate all peaks within 5 ms of it
% Repeat procedure for the tallest remaining peak
% Iterate until there are no more peaks to consider

text(locs+.02,pks,num2str((1:numel(pks))')) % Label peaks

end





    
    