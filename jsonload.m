function json = jsonload(fname)
%% CONFIGLOAD
%
% DESCRIPTION
%
% INPUTS
%
% OUTPUTS
%
% COPYRIGHT (C) Russell Maguire 2015

if nargin < 1
    error('jsonload:fileNotFound', 'No filename specified.');
end

if ~exist(fname, 'file')
    error('jsonload:fileNotFound', 'Unable to find file %s', fname);
end

f = fopen(fname);
s = fread(f, '*char')';

idx = 0;
while idx < length(s)
    switch s(idx)
        case {' ', '\n'}
            idx = idx + 1;
        case {'"'}
            [json, idx] = parsestr(idx+1);
        case {'{'}
            [json, idx] = parseobj(idx+1);
        case {'['}
            [json, idx] = parsearray(idx+1);
        case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
            [json, idx] = parsenum(idx+1);
    end
end

    function [str, idx1] = parsestr(idx0)
    %% PARSESTR
    %
    % DESCRIPTION
    %
    % INPUTS
    %
    % OUTPUTS
    %
    found = strfind(s(idx0:end), '"');
    str = s(idx0:found(1)-1);
    idx1 = found(1) + 1;

    function [obj, idx1] = parseobj(idx0)
    %% PARSEOBJ
    %
    % DESCRIPTION
    %
    % INPUTS
    %
    % OUTPUTS
    %
    obj = struct();
    
    idx = idx0;
    while idx < length(s)
        switch s(idx)
            case {' ', '\n'}
                idx = idx + 1;
            case {'"'}
                [name, idx] = parsestr(idx+1);
                found = strfind(s(idx:end), ':')
                idx = found(1)
            case {'}'}
                idx1 = idx + 1;
                return
            otherwise
                error('jsonload:parseobj:unexpectedCharacter',...
                      'Unexpected character found parsing %s', fname);
        end
    end
    error('jsonload:parseobj:unmatchedBrace',...
          'Matching brace not found parsing %s', fname);
    end

    function [array, idx1] = parsearray(idx0)
    %% PARSEARRAY
    %
    % DESCRIPTION
    %
    % INPUTS
    %
    % OUTPUTS
    %

    end


    function [num, idx1] = parsenum(idx0)
    %% PARSENUM
    %
    % DESCRIPTION
    %
    % INPUTS
    %
    % OUTPUTS
    %

    end
end