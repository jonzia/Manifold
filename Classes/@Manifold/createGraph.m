function obj = createGraph(obj, data, varargin)

% -------------------------------------------------------------------------
% This function creates a discrete representation of the manifold by
% randomly selecting a subset of the data to serve as the nodes. A graph is
% then constructed by connecting the nodes if and only if there exists at
% least one point in the original dataset whose two closest nodes are
% present in the subgraph.
%
% See: https://web.mit.edu/cocosci/Papers/man_nips.pdf
%
% Arguments (required)
% - data        [NxM]       M observations of dimensionality N
%
% Arguments (optional)
% - numPoints               Number of points in the data subset
%                           (Default M/10)
% - neigbors                Number of nearest neigbors for wireframe
%                           (Default 0)
% - verbose                 Print updates to console?
% - plot        FLAG        Plot results?
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'numPoints'); numPoints = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'verbose'); verbose = true;
        elseif strcmp(varargin{arg}, 'plot'); Plot = true;
        elseif strcmp(varargin{arg}, 'neighbors'); neighbors = varargin{arg + 1};
        end
    end
end

% Get the dimensionality of the dataset
numObservations = size(data, 2);

% Set defaults for optional arguments
if ~exist('numPoints', 'var'); numPoints = round(numObservations/10); end
if ~exist('verbose', 'var'); verbose = false; end
if ~exist('Plot', 'var'); Plot = false; end
if ~exist('neighbors', 'var'); neighbors = 0; end

if verbose; f = waitbar(0, "Pre-processing..."); end

% Select a random subset of points for analysis
idx = randperm(numObservations, numPoints); subset = data(:, idx);

% Initialize adjacency table (find two closest points for each observation)
closest = zeros(numObservations, 2);

% For each observation...
for i = 1:numObservations
    
    % Update waitbar, if necessary
    if verbose && neighbors == 0
        waitbar(i/(2*numObservations), f, "Computing Distances...")
    elseif verbose
        waitbar(i/(numObservations + numPoints), f, "Computing Distances...")
    end
    
    % Find the indices of the two closest points
    I = obj.getDistances(subset, data(:, i)); closest(i, :) = I(1:2);
    
end

% Initialize adjacency table for subgraph
A = zeros(numPoints, numPoints);

if neighbors == 0

    % For each observation...
    for i = 1:numObservations

        % Update waitbar, if necessary
        if verbose; waitbar((i + numObservations)/(2*numObservations), f, "Finding Neighbors..."); end

        % Connect the two closest points to this observation in the
        % adjacency table (symmetrical)
        A(closest(i, 1), closest(i, 2)) = 1;
        A(closest(i, 2), closest(i, 1)) = 1;

    end
    
else
    
    % For each observation in the subgraph...
    for i = 1:numPoints
        
        % Update waitbar, if necessary
        if verbose; waitbar((i + numObservations)/(numObservations + numPoints), f, "Finding Neighbors..."); end
        
        % Rank the other points in the subgraph by ascending distance
        I = obj.getDistances(subset, subset(:, i));
        
        % For each nearest neighbor...
        for j = 1:neighbors
            
            % Connect the two points in the adjacency table (symmetrical)
            A(i, I(j)) = 1; A(I(j), i) = 1;
            
        end
        
    end
    
end

% Update waitbar, if necessary
if verbose; waitbar(1, f, "Removing Disconnected Subgraphs..."); end

% Find the indices of points that do not have any adjacent points
removeIdx = [];     % Initialize placeholder
for i = 1:numPoints % For each point in the subset
    % Record the index if it has no neighbors
    if sum(A(:, i)) == 0; removeIdx = [removeIdx i]; end
end
% Remove points from the subset and rows/cols from adjacency
idx(removeIdx) = []; subset(:, removeIdx) = [];
A(removeIdx, :) = []; A(:, removeIdx) = [];

% Return the data and graph
obj.data = data; obj.graph.adjacency = A; obj.graph.indices = idx;

% Update waitbar, if necessary
if verbose; close(f); end

% Plot the results, if indicated
if Plot && verbose; plotGraph(obj, 'verbose'); elseif Plot; plotGraph(obj); end

end

