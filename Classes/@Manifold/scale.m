function obj = scale(obj, varargin)

% -------------------------------------------------------------------------
% This function performs multidimensional scaling (MDS) on the generated
% manifold given that the dissimilarity matrix is known.
%
% Arguments (optional)
% - plot        FLAG    Plot results?
% - classical   FLAG    Classical MDS? (Default: Nonclassical)
% - sammon      FLAG    Sammon criterion for nonclassical MDS?
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'plot'); Plot = true;
        elseif strcmp(varargin{arg}, 'classical'); classical = true;
        elseif strcmp(varargin{arg}, 'sammon'); sammon = true;
        end
    end
end

% Set defaults for optional input arguments
if ~exist('Plot', 'var'); Plot = false; end
if ~exist('classical', 'var'); classical = false; end
if ~exist('sammon', 'var'); sammon = false; end
if sammon && classical
    disp("Error in scale.m: Sammon criterion may only be used for nonclassical MDS")
    return
end

% Check whether the graph has been created
if isempty(obj.graph); disp("Error in scale.m: Graph has not been created."); return; end
% Check whether the dissimilarity matrix has been computed, if necessary
if ~isfield(obj.graph, 'shortestPath')
    disp("Error in scale.m: Dissimilarity matrix has not been computed."); return
end

% Extract the dissimilarity matrix and perform MDS
D = obj.graph.shortestPath; vecD = D(:); maxVal = max(vecD(~isinf(vecD)));
D(isinf(D)) = maxVal; 
if classical; [obj.scaled, ~] = cmdscale(D, 2);
elseif ~sammon; obj.scaled = mdscale(D, 2);
else; obj.scaled = mdscale(D, 2, 'Criterion', 'sammon');
end

if ~classical; obj.scaled = mdscale(D, 2); else; ...
        [obj.scaled, ~] = cmdscale(D, 2); end

% Plot results, if indicated
if Plot
    figure; hold on; grid on; D = D(:, 1); D = D./max(D(~isinf(D)));
    for i = 1:size(obj.scaled); scatter(obj.scaled(i, 1), obj.scaled(i, 2), ...
            '.', 'MarkerEdgeColor', [D(i), D(i), D(i)]); end
end

end