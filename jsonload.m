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
    while idx <= length(s)
        switch s(idx)
            case {' ', sprintf('\n')}
                idx = idx + 1;
            case {'"'}
                [json, idx] = parsestr(idx + 1);
                break;
            case {'{'}
                [json, idx] = parseobj(idx + 1);
                break;
            case {'['}
                [json, idx] = parsearray(idx + 1);
                break;
            case {'-', '+', '.',...
                  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                [json, idx] = parsenum(idx);
                break;
            case {'t', 'f'}
                [json, idx] = parsebool(idx);
                break;
            otherwise
                error('jsonload:parsejson:unexpectedCharacter',...
                      'Unexpected character found parsing %s', fname);
        end
    end
    idx1 = idx;
    end

    function [bool, idx1] = parsebool(idx0)
    %% PARSESTR
    %
    % DESCRIPTION
    %   Find string starting at position idx0 and return that string and
    %   the position
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   str - MATLAB serialised JSON string.
    %   idx1 - Next index in s to be parsed.
    if strcmpi(s(idx0:idx0 + 4), 'false')
        bool = false;
        idx1 = idx0 + 5;
    elseif strcmpi(s(idx0:idx0 + 3), 'true')
        bool = true;
        idx1 = idx0 + 4;
    elseif strcmpi(s(idx0), 'f')
        bool = false;
        idx1 = idx0 + 1;
    elseif strcmpi(s(idx0), 't')
        bool = true;
        idx1 = idx0 + 1;
    end
    end

    function [str, idx1] = parsestr(idx0)
    %% PARSESTR
    %
    % DESCRIPTION
    %   Find string starting at position idx0 and return that string and
    %   the position
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   str - MATLAB serialised JSON string.
    %   idx1 - Next index in s to be parsed.
    found = strfind(s(idx0:end), '"');
    if isempty(found)
        error('jsonload:parsestr:unmatchedQuotes',...
              'Unmatched quote found when parsing %s', fname);
    end
    str = s(idx0:idx0 + found(1) - 2);
    idx1 = idx0 + found(1);
    end

    function [obj, idx1] = parseobj(idx0)
    %% PARSEOBJ
    %
    % DESCRIPTION
    %   Find the JSON object starting at position idx0 and return that
    %   object as a MATLAB struct and the position.
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   obj - MATLAB serialised JSON object.
    %   idx1 - Next index in s to be parsed.
    obj = struct();
    state = 'NAME';
    idx = idx0;
    while idx <= length(s)
        switch state
            case {'NAME'}
                switch s(idx)
                    case {' ', sprintf('\n')}
                        idx = idx + 1;
                    case {'"'}
                        % Extract and sanitise field name.
                        [raw_name, idx] = parsestr(idx + 1);
                        name = genvarname(raw_name);
                        state = 'VALUE';
                    case {'}'}
                        break;
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case {'VALUE'}
                switch s(idx)
                    case {' ', sprintf('\n')}
                        idx = idx + 1;
                    case {':'}
                        [value, idx] = parsejson(idx + 1);
                        obj.(genvarname(name)) = value;
                        state = 'END';
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case {'END'}
                switch s(idx)
                    case {' ', sprintf('\n')}
                        idx = idx + 1;
                    case {','}
                        idx = idx + 1;
                        state = 'NAME';
                    case {'}'}
                        break;
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
        end
    end
    if idx > length(s)
        error('jsonload:parseobj:unmatchedBrace',...
              'Unmatched brace found when parsing %s', fname);
    end
    idx1 = idx + 1;
    end

    function [array, idx1] = parsearray(idx0)
    %% PARSEARRAY
    %
    % DESCRIPTION
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   array - MATLAB serialised JSON array, either a matrix if numeric,
    %       otherwise a cell array.
    %   idx1 - Next index in s to be parsed.
    array = {};
    state = 'VALUE';
    idx = idx0;
    while idx <= length(s)
        switch state
            case {'VALUE'}
                switch s(idx)
                    case {']'}
                        break;
                    otherwise
                        [value, idx] = parsejson(idx);
                        array{end + 1} = value;
                        state = 'END';
                end
            case {'END'}
                switch s(idx)
                    case {' ', sprintf('\n')}
                        idx = idx + 1;
                    case {','}
                        idx = idx + 1;
                        state = 'VALUE';
                    case {']'}
                        break;
                    otherwise
                        error('jsonload:parsearray:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
        end
    end
    if idx > length(s)
        error('jsonload:parsearray:unmatchedBrace',...
              'Unmatched brace found when parsing %s', fname);
    end
    idx1 = idx + 1;
    
    % Attempt to convert cell array to matrix, handling ndimensional
    % arrays.
    try
        mat = cat(ndims(array{1}), array{:});
        mat = shiftdim(mat);
        array = mat;
    catch e
        switch e.identifier
            case {'MATLAB:badsubscript'}
                % Empty array.
                array = [];
            case {'MATLAB:cell2mat:MixedDataTypes',...
                  'MATLAB:catenate:dimensionMismatch'}
                % Cannot be represented by a matrix, leave as cell array.
            otherwise
                rethrow(e)
        end
    end
    end

    function [num, idx1] = parsenum(idx0)
    %% PARSENUM
    %
    % DESCRIPTION
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   num - MATLAB serialised JSON number.
    %   idx1 - Next index in s to be parsed.
    idx = idx0;
    state = 'SIGN';
    while idx <= length(s)
        switch state
            case 'SIGN'
                switch s(idx)
                    case {'-', '+',...
                          '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                        state = 'INT';
                    case {'.'}
                        idx = idx + 1;
                        state = 'FRAC';
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case 'INT'
                switch s(idx)
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                    case {'.'}
                        idx = idx + 1;
                        state = 'FRAC';
                    case {'e', 'E'}
                        idx = idx + 1;
                        state = 'ESIGN';
                    case {' ', sprintf('\n'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case 'FRAC'
                switch s(idx)
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                    case {'e', 'E'}
                        idx = idx + 1;
                        state = 'ESIGN';
                    case {' ', sprintf('\n'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case 'ESIGN'
                switch s(idx)
                    case {'-', '+',...
                          '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                        state = 'EXP';
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
            case 'EXP'
                switch s(idx)
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                    case {' ', sprintf('\n'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character found parsing %s',...
                              fname);
                end
        end
        if idx > length(s)
            error('jsonload:parsenum:incompleteNumber',...
                  'Incomplete number found when parsing %s', fname);
        end
        num = str2double(s(idx0:idx - 1));
        idx1 = idx;
    end
    end
end


