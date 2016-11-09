function jsondump(json, fname)
%% JSONDUMP
%
% DESCRIPTION
%   Dump MATLAB object to JSON file (no fancy indenting).
%
% INPUTS
%   json - MATLAB object representing JSON file.
%   fname - Filename to write to.
%
% OUTPUTS
%
% COPYRIGHT (C) Russell Maguire 2016

% Sanity checking.
if nargin < 1
    error('jsondump:notEnoughArgs',...
          'No filename specified. This function requires 2 inputs.');
end
if nargin < 2
    error('jsondump:notEnoughArgs',...
          'No object specified. This function requires 2 inputs.');
end

[f, msg] = fopen(fname, 'w+');
c = onCleanup(@()fclose(f));
if f == -1
    error('jsondump:fileNotFound', msg);
end
writejson(json);

    function writejson(json)
    %% WRITEJSON
    %
    % DESCRIPTION
    %   Write JSON entity to f.
    %
    % INPUTS
    %   json - JSON entity to write to file.
    if isempty(json)
        fprintf(f, '[]');
    else
        if isnumeric(json)
            json = double(json);
        end
        switch class(json)
            case {'logical'}
                if numel(json) > 1
                    json = nd2nested(json);
                    writearray(json)
                elseif json
                    fprintf(f, 'true');
                else
                    fprintf(f, 'false');
                end
            case {'char'}
                if numel(json) > 1
                    json = nd2nested(json);
                    writearray(json)
                else
                    fprintf(f, '"%s"', json);
                end
            case {'double'}
                if numel(json) > 1
                    json = nd2nested(json);
                    writearray(json)
                else
                    fprintf(f, num2str(json));
                end
            case {'struct'}
                if numel(json) > 1
                    json = nd2nested(json);
                    writearray(json);
                else
                    writeobj(json);
                end
            case {'cell'}
                writearray(json)
        end
    end
    end

    function writeobj(obj)
    %% WRITEOBJ
    %
    % DESCRIPTION
    %   Write MATLAB struct to f as JSON.
    %
    % INPUTS
    %   obj - Struct to write to file.
    names = fieldnames(obj);
    fprintf(f, '{');
    for idx = 1:length(names) - 1
        fprintf(f, '"%s":', names{idx});
        writejson(obj.(names{idx}));
        fprintf(f, ',');
    end
    if ~isempty(names)
        fprintf(f, '"%s":', names{end});
        writejson(obj.(names{end}));
    end
    fprintf(f, '}');
    end

    function writearray(array)
    %% WRITEARRAY
    %
    % DESCRIPTION
    %   Write MATLAB cell array to f as JSON.
    %
    % INPUTS
    %   array - Cell array to write to file.
    fprintf(f, '[');
    for idx = 1:length(array) - 1
        writejson(array{idx});
        fprintf(f, ',');
    end
    if ~isempty(array)
        writejson(array{end});
    end
    fprintf(f, ']');
    end
end

function nested = nd2nested(nd)
%% ND2NESTED
%
% DESCRIPTION
%   Convert n dimensional array to a nested cell array
%
% INPUTS
%   nd - N-dimensional array to convert.
%
% OUTPUTS
%   nested - Nested cell array.
nested = cell(size(nd, 1), 1);
for idx = 1:size(nd, 1)
    idxs = [{idx}, repmat({':'}, 1, size(nd, 1) - 1)];
    slice = nd(idxs{:});
    slice = squeeze(slice);
    if numel(slice) > 1
        slice = nd2nested(slice);
    end
    nested{idx} = slice;
end
end