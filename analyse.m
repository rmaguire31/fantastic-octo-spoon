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
[pks,locs] = findpeaks(roll,t);
findpeaks(roll, t);

% Choose tallest peak
% Repeat procedure for the tallest remaining peak
% Iterate until there are no more peaks to consider

text(locs,pks,num2str((1:numel(pks))')); % Label peaks
title('Roll Time Series');
xlabel('t(s)');
ylabel('Roll Acceleration(ms^2)');
    
subplot(4,1,2);
plot(f,roll_f);
[pks2,locs2] = findpeaks(roll_f,f);
findpeaks(roll_f, f);
text(locs2,pks2,num2str((1:numel(pks2))'));
title('Single-Sided Amplitude Spectrum of Roll(t)');
xlabel('f(Hz)');
ylabel('|P1(f)|');
    
subplot(4,1,3);
plot(t,pitch);
[pks3,locs3] = findpeaks(pitch,t);
findpeaks(pitch, t);
text(locs3,pks3,num2str((1:numel(pks3))'));
title('Pitch Time Series');
xlabel('t(s)');
ylabel('Pitch Acceleration (ms^2)');

subplot(4,1,4);
plot(f,pitch_f);
[pks4,locs4] = findpeaks(pitch_f,f);
findpeaks(pitch_f,f);
text(locs4,pks4,num2str((1:numel(pks4))'));
title('Single-Sided Amplitude Spectrum of Pitch(t)');
xlabel('f(Hz)');
ylabel('|P1(f)|');
    
mean_p = abs(mean(pitch)); % Conduct statistical analysis
mean_r = abs(mean(roll)); % Take absolute values
var_p = abs(var(pitch));
var_r = abs(var(roll));

    fprintf('\nPLOT 1\n\n')
    for i = 1: length(locs) - 1 % Begin iterations %
        peak_to_peak = abs(pks(i+1) - pks(i)); % Compute required peak to peak values
        fprintf('The difference between peaks %d and %d = %d\n',i,i+1,peak_to_peak);
    end

    fprintf('\nPLOT 2\n\n')
    for i = 1: length(locs2) - 1
        peak_to_peak2 = abs(pks2(i+1) - pks2(i));
        fprintf('The difference between peaks %d and %d = %d\n',i,i+1,peak_to_peak2);
    end

    fprintf('\nPLOT 3\n\n')
    for i = 1: length(locs3) - 1
        peak_to_peak3 = abs(pks3(i+1) - pks3(i));
        fprintf('The difference between peaks %d and %d = %d\n',i,i+1,peak_to_peak3);
    end

    fprintf('\nPLOT 4\n\n')
    for i = 1: length(locs4) - 1
        peak_to_peak4 = abs(pks4(i+1) - pks4(i)); 
        fprintf('The difference between peaks %d and %d = %d\n',i,i+1,peak_to_peak4);
    end

end

    
    