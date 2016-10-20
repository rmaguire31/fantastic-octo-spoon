%% analyse
%
% DESCRIPTION
%   Analyse and display acceleration data having loaded it from JSONLOAD.
%
% INPUTS
%   json - MATLAB object representing JSON file.
%
% OUTPUTS
%   Various subplots, and technically relevant data statistics:
%   mean_p - mean pitching acceleration
%   mean_r - mean rolling acceleration
%   var_p - variance of rolling acceleration
%   var_r - variance of pitching acceleration
%
% COPYRIGHT (C) Russell Maguire, Imi Ward Parsons, Lauren Miller & Tom Poon 2016

function analyse

    capture = 'examples/CAPTURE.JSN';               %example data file on GIT
    json = jsonload(capture);
    
    r = json.roll_rad;                              %roll
    p = json.pitch_rad;                             %pitch
    t = json.end_time - json.start_time;            %time
    f = json.sample_rate_hz;                       %sample rate

    subplot(4,1,1);
    plot(t,r);
    title('Roll Time Domain');
    xlabel('Time(s)');
    ylabel('Rolling Acceleration(ms^2)');
    
    subplot(4,1,2);
    plot(f,r);
    title('Roll Frequency Domain');
    xlabel('Frequency(Hz)');
    ylabel('Rolling Acceleration(ms^2)');
    
    subplot(4,1,3);
    plot(t,p)
    title('Pitch Time Domain');
    xlabel('Time(s)');
    ylabel('Pitching Acceleration(ms^2)');
    
    subplot(4,1,4);
    plot(f,p);
    title('Pitch frequency Domain');
    xlabel('Frequency(Hz)');
    ylabel('Pitching Acceleration(ms^2)');
    
    mean_p = mean(p); 
    fprintf('Mean of Pitching Acceleration is: %\n', mean_p);
    mean_r = mean(r); 
    fprintf('Mean of Rolling Acceleration is: %\n\n', mean_r);
    var_p = var(p);
    fprintf('Variance of Pitching Acceleration is: %\n', var_p);
    var_r = var(r); 
    fprintf('Variance of Rolling Acceleration is: %\n\n', var_r);
    
    num_samples = floor(t / f); 
       
    peak_p = 0;
    peak_r = 0;
    min_p = 0;
    min_r = 0;
    p_i = 0;                    %markers to log i
    r_i = 0;
    
    for i = (0:1:num_samples)
        if p(i) > peak_p
            p(i) = peak_p;
            p_i = i;
        end
        if r(i) > peak_r
            r(i) = peak_r;
            r_i = i;
        end
        if p(i) < min_r
            p(i) = min_r;
        end
        if r(i) < min_r
            r(i) = min_r;
        end
        % attempt to calculate peak-to-peak values
        dist_peak_p = 0;
        dist_peak_r = 0;
        
        if p(i) > (0.9 * peak_p)
            dist_peak_p = p_i - i;
            fprintf('Peak to Peak Pitch Value is: %\n', dist_peak_p);
        end
            
        if r(i) > (0.9 * peak_r)
            dist_peak_r = r_i - i;
            fprintf('Peak to Peak Roll Value is: %\n', dist_peak_r);
        end

    fprintf('Peak Pitching Acceleration is: %\n', peak_p);
    fprintf('Peak Rolling Acceleration is: %\n\n', peak_r);
    fprintf('Minimum Pitching Acceleration is: %\n', min_p);
    fprintf('Minimum Rolling Acceleration is: %\n\n', min_r);    
    
    
    end
    