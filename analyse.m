%% Analysis

% DESCRIPTION
%  Load data from JSONLOAD, conduct analysis and display plots
% INPUTS
%  roll - Roll time series
%  pitch - Pitch time series
%  roll_f - Roll in frequency domain
%  pitch_ f - Pitch in frequency domain
% OUTPUTS
%  mean_p - Mean pitch
%  mean_r - Mean roll
%  var_p - Variance of roll
%  var_r - Variance of pitch

function [mean_p,mean_r,var_p,var_r] = analyse(roll,pitch,roll_f,pitch_f,t,f)

subplot(4,1,1); % Display several plots at once
plot(t,roll);
title('Roll Time Series');
xlabel('t(s)');
ylabel('Roll Acceleration(ms^2)');
    
subplot(4,1,2);
plot(f,roll_f);
[pks,locs] = findpeaks(roll_f,f);
findpeaks(roll_f, f);
text(locs,pks,num2str((1:numel(pks))')); % Label peaks
title('Single-Sided Amplitude Spectrum of Roll(t)');
xlabel('f(Hz)');
ylabel('|P1(f)|');
    
subplot(4,1,3);
plot(t,pitch);
title('Pitch Time Series');
xlabel('t(s)');
ylabel('Pitch Acceleration(ms^2)');
    
subplot(4,1,4);
plot(f,pitch_f);
[pks2,locs2] = findpeaks(pitch_f,f);
findpeaks(pitch_f,f);
text(locs2,pks2,num2str((1:numel(pks2))'));
title('Single-Sided Amplitude Spectrum of Pitch(t)');
xlabel('f(Hz)');
ylabel('|P1(f)|');

% Choose tallest peak
% Repeat procedure for the tallest remaining peak
% Iterate until there are no more peaks to consider
    
mean_p = abs(mean(pitch)); % Conduct statistical analysis
mean_r = abs(mean(roll)); % Take absolute values
var_p = abs(var(pitch));
var_r = abs(var(roll));

end





    
    