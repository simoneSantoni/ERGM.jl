# ERGM.jl

A Julia package for Exponential Random Graph Models.

## Overview

Exponential Random Graph Models (ERGMs) are a family of statistical models for analyzing data about networks. ERGMs are used to model the structural regularities of a network, such as the tendency for nodes to form triangles or the propensity for nodes with similar attributes to be connected.

This package provides tools for simulating and fitting ERGMs in Julia.

## Features

- MCMC-based simulation of ERGMs
- A flexible framework for specifying model terms
- Integration with `Graphs.jl` for graph representation

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/simoneSantoni/ERGM.jl")
```

Or for development:

```julia
using Pkg
Pkg.develop(path="/path/to/ERGM.jl")
```

## Quick Start

```julia
using ERGM
using Graphs

# Create an ErgmGraph
g = ErgmGraph(Graph(10, 20))

# Define a model with edge and degree terms
model = Model([EdgeTerm(), DegreeTerm(2)], [-1.0, 0.5])

# Run the MCMC sampler
samples = mcmc_sampler(g, model, 100, burn_in = 10)

println("Generated ", length(samples), " graph samples.")
```

## Documentation

```@contents
Pages = ["api.md"]
Depth = 2
```
