classdef Manifold
    
    % Class containing methods and properties for learning manifolds, or
    % low-dimensional embeddings in higher-dimensional spaces.
    
    % Class Properties (public)
    properties (SetAccess = public, GetAccess = public)
        description
    end
    
    % Class Properties (semi-private)
    properties (SetAccess = public, GetAccess = public)
        data        % Dataset
        graph       % Struct containing manifold map and related parameters
        scaled      % Output of multidimensional scaling (MDS)
    end
    
    % Public Methods
    methods (Access = public)
        
        % Class Constructor
        function obj = Manifold(varargin)
            
            % The class description may optionally be provided
            if ~isempty(varargin); obj.description = varargin{1}; end
            
        end
        
        % Learn a discrete representation of the manifold
        obj = createGraph(obj, data, varargin)
        
        % Compute shortest distance between each pair in the graph
        obj = shortestPath(obj, varargin)
        
        % Plot wireframe graph of manifold
        plotGraph(obj, varargin)
        
        % Perform multidimensional scaling on created graph
        obj = scale(obj, varargin)
        
        % Map high dimensional coordinates to manifold coordinates
        coordinates = map(obj, points, varargin)
        
        % Extract latent variables from learned graph
        [idx, vars] = latent(obj)
        
    end
    
    % Private Methods
    methods (Access = private)
        
        % Compute distance between point and all other points besides
        % itself, and return a list of indices by ascending distance
        function dist = getDistances(~, matrix, vector)
            
            % Find the L2 norm between the observation and all others
            distance = sqrt(sum((vector - matrix).^2, 1));
            
            % Sort the observations by ascending distance
            [~, I] = sort(distance, 'ascend');
            
            % Remove the current observation and return a list of distances
            dist = I(distance > 0);
            
        end
        
    end
    
end

