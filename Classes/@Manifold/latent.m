function [orig, vars] = latent(obj)

% -------------------------------------------------------------------------
% Returning latent variables extracted from manifold along with their
% original indices in the training dataset.
% -------------------------------------------------------------------------

% Ensure that the scaled output exists
if isempty(obj.scaled)
    disp("Error in latent.m: Scaled output is not available -- run Manifold.scale()")
    vars = nan; return
end

% Sort the indices used to learn the manifold
[orig, idx] = sort(obj.graph.indices, 'ascend');

% Return the latent variables
vars = obj.scaled(idx, :);

end

