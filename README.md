# Manifold Mapping with ISOMAP

## Summary
This repository contains the `Manifold` class which uses the [ISOMAP](http://web.mit.edu/cocosci/Papers/sci_reprint.pdf) method (Tenenbaum, 2000) to characterize manifolds and extract latent variables. This latter component is accomplished with multidimensional scaling, though other methods such as locally linear embedding may be substituted. The notable drawback to ISOMAP is that it may be easily broken with outlier datapoints owing to its reliance on accurate geodesic distance calculation. However, ISOMAP remains an impressively accurate method of manifold mapping with few prior assumptions placed on the data. Other drawbacks include that the algorithm has O(N^3) complexity and that the manifold is defined by the downsampled graph rather than a set of equations that could be used to generate more points conforming to the underlying dynamics captured by the manifold.

## How to Use
To use this class, we first initialize the `Manifold` object using `manifold = Manifold("Description")` and load the data using `manifold = manifold.createGraph(data)`. The resulting graph may be visualized with the function `manifold.plotGraph()`. To implement the ISOMAP algorithm, we must first compute the geodesic distances between all nodes in the graph using the function `manifold = manifold.shortestPath()`, followed by latent variable extraction via `manifold = manifold.scale()`, which performs multidimensional scaling.

### Data Formatting
The data should be formatted as a MxN matrix with M observations and N dimensions.

### Member Functions
| Function | Purpose |
| --- | --- |
| `createGraph()` | Create adjacency graph for performing ISOMAP |
| `latent()` | Function returning latent variables and corresponding original datapoints |
| `map()` | Map new datapoints to learned manifold |
| `plotGraph()` | Plot datapoints on adjacency graph |
| `scale()` | Perform multidimensional scaling using dissimilarity matrix |
| `shortestPath()` | Computing geodesic distances between points in adjacency graph |

## References
This repository was used in the [linked paper](https://www.researchgate.net/publication/343446322_Harnessing_the_Manifold_Structure_of_Cardiomechanical_Signals_for_Physiological_Monitoring_during_Hemorrhage), which contains a more detailed explanation of ISOMAP and its drawbacks.
