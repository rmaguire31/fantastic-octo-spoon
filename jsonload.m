function json = jsonload(fname)
%% JSONLOAD
%
% DESCRIPTION
%   Load JSON file and serialise it into MATLAB datatypes.
%
% INPUTS
%   fname - JSON file to parse.
%
% OUTPUTS
%   json - MATLAB object representing JSON file.
%
% COPYRIGHT (C) Russell Maguire 2016

% Sanity checking.
if nargin < 1
    error('jsonload:fileNotFound', 'No filename specified.');
end

if ~exist(fname, 'file')
    error('jsonload:fileNotFound', 'Unable to find file %s', fname);
end

% Read JSON file in as a string.
f = fopen(fname);
s = fread(f, '*char')';

% Now parse it.
json = parsejson(1);

    function [json, idx1] = parsejson(idx0)
    %% PARSEJSON
    %
    % DESCRIPTION
    %   Parse next JSON datatype found in s(idx0:end) and return MATLAB
    %   serialised JSON along with next available index in the string.
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   json - MATLAB serialised JSON.
    %   idx1 - Next index in s to be parsed.
    idx = idx0;
    while idx < length(s)
        switch s(idx)
            case {' ', '\n'}
                idx = idx + 1;
            case {'"'}
                [json, idx] = parsestr(idx + 1);
                break
            case {'{'}
                [json, idx] = parseobj(idx + 1);
                break
            case {'['}
                [json, idx] = parsearray(idx + 1);
                break
            case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                [json, idx] = parsenum(idx + 1);
                break
            otherwise
                error('jsonload:parsejson:unexpectedCharacter',...
                      'Unexpected character found parsing %s', fname);
        end
    end
    idx1 = idx + 1;
    end

    function [str, idx1] = parsestr(idx0)
    %% PARSESTR
    %
    % DESCRIPTION
    %   Find string starting at position idx0 and return that string and
    %   the position
    %
    % INPUTS
    %
    % OUTPUTS
    %
    found = strfind(s(idx0:end), '"');
    str = s(idx0:found(1)-1);
    idx1 = found(1) + 1;
    end

    function [obj, idx1] = parseobj(idx0)
    %% PARSEOBJ
    %
    % DESCRIPTION
    %   Find the JSON object starting at position idx0 and return that
    %   object as a MATLAB struct and the position.
    %
    % INPUTS
    %
    % OUTPUTS
    %
    obj = struct();
    
    state = 'NAME';
    idx = idx0;
    while idx < length(s)
        switch state
            case {'NAME'}
                switch s(idx)
                    case {' ', '\n'}
                        idx = idx + 1;
                    case {'"'}
                        [name, idx] = parsestr(idx + 1);
                        state = 'COLON';
                    case {'}'}
                        break
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case {'COLON'}
                switch s(idx)
                    case {' ', '\n'}
                        idx = idx + 1;
                    case {':'}
                        idx = idx + 1;
                        state = 'VALUE';
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case {'VALUE'}
                switch s(idx)
                    case {' ', '\n'}
                        idx = idx + 1;
                    case {':'}
                        [value, idx] = parsejson(idx + 1)
                        obj.(name) = value;
                        state = 'END';
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case {'END'}
                switch s(idx)
                    case {' ', '\n'}
                        idx = idx + 1;
                    case {','}
                        idx = idx + 1;
                        state = 'NAME'
                    case {'}'}
                        break
        end
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