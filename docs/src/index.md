# ERGM.jl

A Julia package for Exponential Random Graph Models (ERGMs).

## Overview

Exponential Random Graph Models (ERGMs) are a family of statistical models for analyzing data about networks. ERGMs are used to model the structural regularities of a network, such as the tendency for nodes to form triangles (transitivity) or the propensity for nodes with similar attributes to be connected (homophily).

`ERGM.jl` provides a high-performance, native Julia implementation for simulating and fitting these models. It leverages `Graphs.jl` for efficient graph operations and `DataFrames.jl` for attribute management.

## Features

- **Efficient MCMC Simulation**: Uses a highly optimized Metropolis-Hastings sampler capable of handling large networks (millions of nodes) by using incremental statistic updates and minimal memory allocation.
- **Flexible Model Specification**: Easily define models using terms like `EdgeTerm`, `DegreeTerm`, and `TriangleTerm`.
- **Attribute Support**: Manage vertex and edge attributes seamlessly using DataFrames.
- **Scalability**: By default, simulations return compact statistics matrices rather than storing full graph trajectories, ensuring memory efficiency for large-scale simulations.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/simoneSantoni/ERGM.jl")
```

## Quick Start

Here is a simple example of how to simulate a network with specific structural properties.

```julia
using ERGM
using Graphs

# 1. Initialize an empty graph with 50 nodes
g = ErgmGraph(Graph(50, 0))

# 2. Define a model
# We want a network with:
# - Low density (negative parameter for edges)
# - High clustering (positive parameter for triangles)
model = Model(
    [EdgeTerm(), TriangleTerm()], 
    [-2.0, 1.5]
)

# 3. Run the simulation
# Generate 1000 samples, discarding the first 1000 steps (burn-in)
result = mcmc_sampler(g, model, 1000; burn_in=1000)

# 4. Analyze results
println("Simulation complete.")
println("Average Edges: ", sum(result.stats[:, 1]) / 1000)
println("Average Triangles: ", sum(result.stats[:, 2]) / 1000)
```

## Model Specification

Models are defined by a list of `Term`s and a corresponding vector of parameters.

| Term | Description |
| :--- | :--- |
| `EdgeTerm()` | Controls the density of the network (equivalent to the number of edges). |
| `DegreeTerm(k)` | Controls the number of nodes with degree `k`. |
| `TriangleTerm()` | Controls the number of triangles (transitivity/clustering). |

## API Reference

See the [API Reference](api.md) for detailed documentation of all functions and types.