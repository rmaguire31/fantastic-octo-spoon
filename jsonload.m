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
        % Determine type of next JSON entity and parse it appropriately.
        switch s(idx)
            case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t')}
                % Ignore sensible whitespace.
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
            case {'t', 'T', 'f', 'F', 'n', 'N', 'i', 'I'}
                [json, idx] = parsekeyword(idx);
                break;
            otherwise
                error('jsonload:parsejson:unexpectedCharacter',...
                      'Unexpected character "%s" found parsing %s',...
                      s(idx), fname);
        end
    end
    idx1 = idx;
    end

    function [str, idx1] = parsestr(idx0)
    %% PARSESTR
    %
    % DESCRIPTION
    %   Find string starting at position idx0 and return that string and
    %   the position to continue parsing from.
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   str - MATLAB serialised JSON string.
    %   idx1 - Next index in s to be parsed.
    
    % Extract all characters until the next double quote.
    found = strfind(s(idx0:end), '"');
    if isempty(found)
        error('jsonload:parsestr:unmatchedQuotes',...
              'Unmatched ''"'' found when parsing %s', fname);
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
    
    % Expect objects to be of the form:
    %   {["<NAME>":<VALUE>[,"<NAME>":<VALUE>[...]]][,]}
    %
    % We should be pointed at the index after { and will return the index
    % after }.
    obj = struct();
    state = 'NAME';
    idx = idx0;
    while idx <= length(s)
        switch state
            case {'NAME'}
                switch s(idx)
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t')}
                        % Ignore sensible whitespace.
                        idx = idx + 1;
                    case {'"'}
                        % Extract and sanitise field name.
                        [raw_name, idx] = parsestr(idx + 1);
                        name = genvarname(raw_name);
                        state = 'VALUE';
                    case {'}'}
                        % Break in this state to handle empty objects and
                        % ,} case.
                        break;
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
            case {'VALUE'}
                switch s(idx)
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t')}
                        % Ignore sensible whitespace.
                        idx = idx + 1;
                    case {':'}
                        % Update MATLAB struct with new field, whose value
                        % could any bit of valid JSON.
                        [value, idx] = parsejson(idx + 1);
                        obj.(genvarname(name)) = value;
                        state = 'END';
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
            case {'END'}
                switch s(idx)
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t')}
                        idx = idx + 1;
                    case {','}
                        % Next field.
                        idx = idx + 1;
                        state = 'NAME';
                    case {'}'}
                        break;
                    otherwise
                        error('jsonload:parseobj:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
        end
    end
    if idx > length(s)
        error('jsonload:parseobj:unmatchedBrace',...
              'Unmatched "{" found when parsing %s', fname);
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
    
    % Expect arrays to be of the form:
    %   '['[<VALUE>[,<VALUE>[...]]][,]']'
    %
    % We should be pointed at the index after [ and will return the index
    % after ].
    %
    % Store values in a cell array whilst parsing, which we can convert to
    % a matrix at the end if suitable.
    array = {};
    state = 'VALUE';
    idx = idx0;
    while idx <= length(s)
        switch state
            case {'VALUE'}
                switch s(idx)
                    case {']'}
                        % Break in this state to handle empty arrays and
                        % ,] case.
                        break;
                    otherwise
                        % Update cell array with new value, which could be
                        % any bit of valid JSON.
                        [value, idx] = parsejson(idx);
                        array{end + 1} = value;
                        state = 'END';
                end
            case {'END'}
                switch s(idx)
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t')}
                        % Ignore sensible whitespace.
                        idx = idx + 1;
                    case {','}
                        idx = idx + 1;
                        state = 'VALUE';
                    case {']'}
                        break;
                    otherwise
                        error('jsonload:parsearray:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
        end
    end
    if idx > length(s)
        error('jsonload:parsearray:unmatchedBracket',...
              'Unmatched "[" found when parsing %s', fname);
    end
    idx1 = idx + 1;
    
    % Attempt to convert cell array to matrix, handling n-dimensional
    % arrays.
    try
        mat = cat(ndims(array{1}), array{:});
        mat = shiftdim(mat);
        if isnumeric(mat)
            array = mat;
        end
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
    
    % Expect numbers to be of the form:
    %   [<SIGN>][<INT>][.[<FRAC>]][e[<ESIGN>]<EXP>]
    %
    % We should be pointed at the start of the number and will return the
    % index after the last character in the number.
    idx = idx0;
    state = 'SIGN';
    while idx <= length(s)
        switch state
            case 'SIGN'
                switch s(idx)
                    case {'-', '+',...
                          '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        % First character could be a - or +.
                        idx = idx + 1;
                        state = 'INT';
                    case {'.'}
                        idx = idx + 1;
                        state = 'FRAC';
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
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
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
            case 'FRAC'
                switch s(idx)
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                    case {'e', 'E'}
                        idx = idx + 1;
                        state = 'ESIGN';
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
            case 'ESIGN'
                switch s(idx)
                    case {'-', '+',...
                          '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                        state = 'EXP';
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
            case 'EXP'
                switch s(idx)
                    case {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        idx = idx + 1;
                    case {' ', sprintf('\n'), sprintf('\r'), sprintf('\t'), ',', ']', '}'}
                        break;
                    otherwise
                        error('jsonload:parsenum:unexpectedCharacter',...
                              'Unexpected character "%s" found parsing %s',...
                              s(idx), fname);
                end
        end
        if idx > length(s)
            error('jsonload:parsenum:incompleteNumber',...
                  'Incomplete number found when parsing %s', fname);
        end
        
        % Convert to double. Loss of precision should not be an issue as
        % JSON numbers should be double anyway.
        num = str2double(s(idx0:idx - 1));
        idx1 = idx;
    end
    end

    function [value, idx1] = parsekeyword(idx0)
    %% PARSEKEYWORD
    %
    % DESCRIPTION
    %   Find keyword starting at position idx0 and return MATLAB equivalent
    %   value and the position to continue parsing from.
    %
    % INPUTS
    %   idx0 - Start index to begin parsing.
    %
    % OUTPUTS
    %   value - MATLAB serialised JSON keyword.
    %       'true': true
    %       'false': false
    %       'null': 'null'
    %       'nan': nan
    %       'inf': inf
    %   idx1 - Next index in s to be parsed.
    
    % Long form.
    if strcmpi(s(idx0:idx0 + 4), 'false')
        value = false;
        idx1 = idx0 + 5;
    elseif strcmpi(s(idx0:idx0 + 3), 'true')
        value = true;
        idx1 = idx0 + 4;
    elseif strcmpi(s(idx0:idx0 + 3), 'null')
        value = 'null';
        idx1 = idx0 + 4;
    elseif strcmpi(s(idx0:idx0 + 2), 'nan')
        value = nan;
        idx1 = idx0 + 3;
    elseif strcmpi(s(idx0:idx0 + 2), 'inf')
        value = inf;
        idx1 = idx0 + 3;
        
    % Short form.
    elseif strcmpi(s(idx0), 'f')
        value = false;
        idx1 = idx0 + 1;
    elseif strcmpi(s(idx0), 't')
        value = true;
        idx1 = idx0 + 1;
    end
    end
end


