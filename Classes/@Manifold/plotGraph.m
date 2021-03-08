function plotGraph(obj, varargin)

% -------------------------------------------------------------------------
% This function plots the wireframe graph for Manifold objects.
% Manifold.createGrpah() must have been run.
%
% Arguments (optional)
% - verbose         FLAG    Print progress?
% - dissimilarity           Plot dissimilarity against point with specified
%                           index (specify index)
% - sameFigure      FLAG    Plot results on existing figure?
% - coeff                   PCA coefficient matrix
% - color           Map     Color of plot (default: Map.black)
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'verbose'); verbose = true;
        elseif strcmp(varargin{arg}, 'dissimilarity'); dissimilarity = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'sameFigure'); sameFigure = true;
        elseif strcmp(varargin{arg}, 'coeff'); coeff = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'color'); colorMap = varargin{arg + 1};
        end
    end
end

% Set defaults for optional input arguments
if ~exist('verbose', 'var'); verbose = false ; end
if ~exist('dissimilarity', 'var'); dissimilarity = 0; end
if ~exist('sameFigure', 'var'); sameFigure = false; end
if ~exist('coeff', 'var'); coeff = []; end
if ~exist('colorMap', 'var'); colorMap = Map.black; end

% Set the color of lines and points
switch colorMap
    case Map.blue
        lpcolor = [0 0.4770 0.7410];
    case Map.gray
        lpcolor = [0.5 0.5 0.5];
    case Map.green
        lpcolor = [0.4660 0.6740 0.1880];
    case Map.orange
        lpcolor = [0.8500 0.3250 0.0980];
    case Map.purple
        lpcolor = [0.4940 0.1840 0.5560];
    case Map.red
        lpcolor = [0.6350 0.0780 0.1840];
    case Map.yellow
        lpcolor = [0.9290 0.6940 0.1250];
    otherwise
        lpcolor = [0 0 0];
end

% Check whether the graph has been created
if isempty(obj.graph); disp("Error in plotGraph.m: Graph has not been created."); return; end
% Check whether the dissimilarity matrix has been computed, if necessary
if dissimilarity > 0 && ~isfield(obj.graph, 'shortestPath')
    disp("Error in plotGraph.m: Dissimilarity matrix has not been computed."); return
end

% Initialize the figure (if necessary)
if ~sameFigure; figure; hold on; grid on; end

% Provide a waitbar, if necessary
if verbose; f = waitbar(0, "Generating Edges..."); end

% Create a temporary copy of the adjacency matrix
temp = obj.graph.adjacency;

% Extract the data subset for graph creation
subset = obj.data(:, obj.graph.indices);

% Compute the PCA dimensions of the data subset (if necessary)
if isempty(coeff); [~, score] = pca(subset'); else; score = subset'*coeff; end

% Normalize the dissimilarity matrix, if indicated
if dissimilarity > 0; D = obj.graph.shortestPath(:, dissimilarity); D = D./max(D(~isinf(D))); end

% For each point in the subset...
for i = 1:length(obj.graph.indices)

    if dissimilarity == 0
    
        % Update waitbar, if necessary
        if verbose; waitbar(i/length(obj.graph.indices), f, ...
                "Generating Edges"); end

        % Plot the current point
        scatter3(score(i, 1), score(i, 2), score(i, 3), ...
            'MarkerEdgeColor', lpcolor, 'Marker', '.')

        % For each other point in the subset...
        for j = 1:length(obj.graph.indices)

            % For all points besides the current point...
            if i == j; continue; end

            % If the points are connected...
            if temp(i, j) == 1

                % Plot a line between the two points
                x = [score(i, 1); score(j, 1)];
                y = [score(i, 2); score(j, 2)];
                z = [score(i, 3); score(j, 3)];
                plot3(x, y, z, '-', 'Color', lpcolor)

                % Remove the connection from the temporary adjacency matrix
                % to prevent redundancy in plotting
                temp(i, j) = 0; temp(j, i) = 0;

            end

        end
        
    else
        
        % Update waitbar, if necessary
        if verbose; waitbar(i/length(obj.graph.indices), f, "Generating Graph"); end
        
        % Plot the current point, scaled for dissimilarity
        if ~isnan(D(i)) && ~isinf(D(i))
            scatter3(score(i, 1), score(i, 2), score(i, 3), '.', 'MarkerEdgeColor', [D(i), D(i), D(i)])
        end
    
    end

end

% Close the waitbar, if necessary
if verbose; close(f); end

end

