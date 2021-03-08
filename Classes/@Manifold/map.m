function coordinates = map(obj, points, varargin)

% -------------------------------------------------------------------------
% This function plots high-dimensional coordinates to manifold coordinates
% with respect to their nearest neighbors in high dimensions via gradient
% descent.
%
% Arguments (required)
% - points      [MxN]   N points of dimension M for generating coordinates
%
% Arguments (optional)
% - maxIter             Maximum number of iterations for gradient descent (default 100)
% - neighbors           Number of neighbors to consider (default: 10)
% - lr                  Learning rate (default: 0.1)
% - verbose     FLAG    Print progress?
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'maxIter'); maxIter = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'neighbors'); neighbors = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lr'); lr = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'verbose'); verbose = true;
        end
    end
end

% Set defaults for optional arguments
if ~exist('maxIter', 'var'); maxIter = 100; end
if ~exist('neighbors', 'var'); neighbors = 10; end
if ~exist('lr', 'var'); lr = 0.1; end
if ~exist('verbose', 'var'); verbose = false; end

% Get the number of points to assess
numPoints = size(points, 2);

% Set placeholder for return value
coordinates = zeros(numPoints, 2);

% Get the training data
train = obj.data(:, obj.graph.indices); numTrain = size(train, 2);

% Initialize waitbar, if indicated
if verbose; f = waitbar(0, "Mapping Points..."); end

% For each point
for i = 1:numPoints
    
    % Print update, if necessary
    if verbose; waitbar(i/numPoints, f, "Mapping Point " + string(i) + ...
            " of " + string(numPoints)); end
    
    % Extract the point
    point = points(:, i);
    
    % Set placeholder for distance between point and all training points
    dist = zeros(numTrain, 1);
    
    % Find the distance between this point and all training points
    for j = 1:numTrain; dist(j) = norm(point - train(:, j)); end
    
    % Sort the training points by distance
    [B, I] = sort(dist, 'ascend');
    
    % Get the top points and their distances
    idx = I(1:neighbors); D = B(1:neighbors);
    
    % Find the scaled versions of the neighboring points
    neighborhood = obj.scaled(idx, :);
    
    % Define the starting position as the neighborhood centroid
    coordinates(i, :) = mean(neighborhood);
    
    % Set flag for loop
    FLAG = true; stopPatience = 0; counter = 0;
    
    % Perform gradient descent to tune location
    while FLAG
        
        % Initialize a matrix defining the gradient in all directions
        gradient = zeros(3, 3); transformation = [0, 0]; steps = [-lr 0 lr];
        
        % For each row in the matrix...
        for row = 1:3
            % For each column in the matrix...
            for col = 1:3
                
                % Skip the center
                if row == 2 && col == 2; continue; end
                
                % Compute the center distance
                centerDist = weightedDist(coordinates(i, :), neighborhood, D);
                
                % Compute the temporary coordinate update
                newCoord = coordinates(i, :) + [steps(row) steps(col)];
                
                % Compute the updated distance
                gradient(row, col) = weightedDist(newCoord, neighborhood, D) - centerDist;
                
            end
        end
        
        counter = counter + 1; % Increment the counter
        
        % Move the point, if necessary
        if min(gradient(:)) < 0
            [row, col] = find(gradient == min(gradient(:)));
            coordinates(i, :) = coordinates(i, :) + [steps(row) steps(col)];
        else; FLAG = false;     % Trip the flag
        end
        
        % If the the counter is too high, set the trip the flag
        if counter >= maxIter; FLAG = false; end
        
    end
    
end; if verbose; close(f); end

% Sub-function for computing weighted distance
    function dist = weightedDist(coordinates, neighborhood, weights)
        dist = 0;  % Initialize weighted distance
        for k = 1:length(weights); dist = dist + (1/weights(k))*norm(coordinates - neighborhood(k, :)); end
    end

end