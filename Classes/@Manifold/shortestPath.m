function obj = shortestPath(obj, varargin)

% -------------------------------------------------------------------------
% This function computes the shortest path between each pair of points in
% the graph, returning the answer as a weighted adjacency matrix. The
% function Manifold.createGraph() must have been successfully run.
%
% Distances are estimated using Floyd's Algorithm.
% See: https://brilliant.org/wiki/floyd-warshall-algorithm/
%
% Arguments (optional)
% - verbose     FLAG    Print progress?
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'verbose'); verbose = true; end
    end
end

% Set defaults for optional input arguments
if ~exist('verbose', 'var'); verbose = false; end

% Import data from the graph
A = obj.graph.adjacency;    % Adjacency matrix
idx = obj.graph.indices;    % Indices of subgraph
data = obj.data;            % Original dataset
subgraph = data(:, idx);    % Subset of data used to form graph
numPoints = length(idx);    % Number of points in subgraph

% Create placeholder for return value (shortest path matrix)
M = inf*ones(numPoints, numPoints);

% Initialize zero-distances in the shortest path matrix
for i = 1:numPoints; M(i, i) = 0; end

% -------------------------------------------------------------------------
% Floyd's Algorithm
% -------------------------------------------------------------------------

% Initialize counter
counter = 0;

% Initialize waitbar, if necessary
if verbose; f = waitbar(counter, "Initializing Shortest Path Matrix..."); end

% For each node in the shortest path matrix...
for i = 1:numPoints
    
    % Find the neighbors of the current node
    neighbors = find(A(i, :) == 1);
    
    % For each neighbor of the current node...
    for j = neighbors
        
        % Return the distance between the current point and its neighbor
        M(i, j) = norm(subgraph(:, i) - subgraph(:, j));
        
    end
    
    % Increment the counter
    counter = counter + 1;
    
    % Update the waitbar, if necessary
    if verbose; waitbar(counter/numPoints, f, "Initializing Shortest Path Matrix..."); end
    
end

% Compute the total number of operations and reset the counter
ops = numPoints^3; counter = 0;

% Floyd's algorithm implementation
for k = 1:numPoints
    for i = 1:numPoints
        for j = 1:numPoints
            
            % Update shortest path matrix, if indicated
            if M(i, j) > M(i, k) + M(k, j)
                M(i, j) = M(i, k) + M(k, j);
            end
            
            % Increment the counter
            counter = counter + 1;
            
            if verbose && mod(counter, 100) == 0
                
                % Update waitbar, if necessary
                waitbar(counter/ops, f, round(100*counter/ops, 2) + "% Complete")
            
            end
            
        end
    end
end

% Close the waitbar, if necessary
if verbose; close(f); end

% Return shortest path matrix
obj.graph.shortestPath = M;

end

