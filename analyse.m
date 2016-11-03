function [t_mean, t_var, t_peaks, t_locs, f_peaks, f_locs] = analyse(t, data_t, f, data_f)
%% ANALYSE
%
%  TODO(LAUREN)

% Conduct statistical analysis
% Take absolute values
t_mean = abs(mean(data_t)); 
t_var = abs(var(data_t));

% Find peaks.
if exist('findpeaks','builtin')
    [t_peaks,t_locs] = findpeaks(data_t,t,'SortStr','descend');
    [f_peaks,f_locs] = findpeaks(data_f,f,'SortStr','descend');
else
    t_peaks = [];
    t_locs = [];
    f_peaks = [];
    f_locs = [];
end

    
    