# Tutorial: Modeling a Social Network

This tutorial walks you through a complete workflow using `ERGM.jl`: creating a synthetic social network, defining a model, and simulating new networks that share the same structural properties.

## 1. Introduction

We will model a hypothetical friendship network among 50 students. We assume that:
1.  Friendships are relatively sparse (low density).
2.  Popular students tend to become even more popular (preferential attachment / degree effect).
3.  "A friend of a friend is a friend" (transitivity / triangle closure).

## 2. Setup

First, load the necessary packages.

```julia
using ERGM
using Graphs
using Random
using Statistics

# Set a random seed for reproducibility
Random.seed!(123)
```

## 3. Creating the Network

We'll start by initializing an empty graph with 50 nodes.

```julia
# Create an empty graph with 50 nodes
num_nodes = 50
initial_graph = Graph(num_nodes)
g = ErgmGraph(initial_graph)

println("Initial graph has $(nv(g.graph)) nodes and $(ne(g.graph)) edges.")
```

## 4. Defining the Model

We define an ERGM that captures our assumptions using three terms:
*   **`EdgeTerm()`**: Controls the overall density. A negative parameter makes edges costly (sparse network).
*   **`DegreeTerm(k)`**: We'll use this to encourage nodes to have a specific degree, e.g., degree 3, representing a typical number of close friends.
*   **`TriangleTerm()`**: Controls the clustering. A positive parameter encourages triangle formation.

```julia
# Define the model terms
terms = [
    EdgeTerm(),        # Density
    DegreeTerm(3),     # Tendency to have 3 friends
    TriangleTerm()     # Clustering
]

# Define the corresponding parameters (coefficients)
# -2.0: Penalize edges (keep it sparse)
#  0.5: Small bonus for having exactly 3 friends
#  1.2: Strong bonus for triangles (clustering)
params = [-2.0, 0.5, 1.2]

model = Model(terms, params)
```

## 5. Running the Simulation (MCMC)

Now we run the Markov Chain Monte Carlo (MCMC) sampler to simulate networks from this distribution. We'll generate 2,000 samples, discarding the first 5,000 steps as "burn-in" to ensure the chain reaches equilibrium.

```julia
# Run the sampler
# We also apply 'thinning' to reduce correlation between consecutive samples
result = mcmc_sampler(
    g, 
    model, 
    2000; 
    burn_in = 5000, 
    thinning = 10
)

println("Simulation complete.")
```

## 6. Analyzing the Results

The `result` object contains the statistics for all sampled networks. Let's analyze the structural properties of our simulated "social networks."

```julia
# Extract statistics
edge_counts = result.stats[:, 1]
degree_3_counts = result.stats[:, 2]
triangle_counts = result.stats[:, 3]

# Calculate averages
avg_edges = mean(edge_counts)
avg_triangles = mean(triangle_counts)
density = avg_edges / (num_nodes * (num_nodes - 1) / 2)

println("-"^30)
println("Simulation Results (Averages):")
println("Edges:      $(round(avg_edges, digits=1))")
println("Density:    $(round(density, digits=3))")
println("Nodes w/ k=3: $(round(mean(degree_3_counts), digits=1))")
println("Triangles:  $(round(avg_triangles, digits=1))")
println("-"^30)
```

## 7. Next Steps

*   **Attribute-Based Models**: You can extend this by adding vertex attributes (e.g., `age`, `gender`) and creating custom terms to model homophily (e.g., "students of the same age are more likely to be friends").
*   **Parameter Estimation**: In a real-world scenario, you would use `fit` (once fully implemented) to estimate the `params` from an observed network rather than defining them manually.
