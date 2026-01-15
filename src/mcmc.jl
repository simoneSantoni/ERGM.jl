# MCMC sampler for Ergm.jl

using LinearAlgebra

"""
    Term

Abstract base type for all ERGM model terms. Subtypes (e.g., `EdgeTerm`, `TriangleTerm`) define specific network statistics.
"""
abstract type Term end

"""
    EdgeTerm <: Term

A model term representing the total number of edges in the graph. 
Associated with the density of the network.
"""
struct EdgeTerm <: Term end

"""
    DegreeTerm <: Term

A model term representing the number of vertices with a specific degree `k`.
Useful for modeling degree distributions.

# Fields
- `k::Int`: The degree count to model.
"""
struct DegreeTerm <: Term
    k::Int
end

"""
    TriangleTerm <: Term

A model term representing the total number of triangles (3-cycles) in the graph.
Associated with the transitivity or clustering of the network.
"""
struct TriangleTerm <: Term end

"""
    Model

Represents an ERGM specification, consisting of a set of statistics (`terms`) and their corresponding coefficients (`params`).

# Fields
- `terms::Vector{Term}`: The list of network statistics included in the model.
- `params::Vector{Float64}`: The parameter values (coefficients) for each term.
"""
struct Model
    terms::Vector{Term}
    params::Vector{Float64}
end

"""
    MCMCResult

Stores the output of an MCMC simulation.

# Fields
- `samples::Vector{ErgmGraph}`: A list of sampled graphs. This will be empty unless `sample_graphs=true` is passed to the sampler.
- `stats::Matrix{Float64}`: A matrix where row `i` contains the network statistics for the `i`-th sample. Columns correspond to the order of `terms` in the `Model`.
"""
struct MCMCResult
    samples::Vector{ErgmGraph} # Sampled graphs (optional)
    stats::Matrix{Float64}     # Statistics for each sample
end

"""
    delta(g::ErgmGraph, change::Change, term::EdgeTerm)

Calculate the change in the number of edges for a given change.
"""
function delta(g::ErgmGraph, change::Change, term::EdgeTerm)
    return delta_edges(g, change)
end

"""
    delta(g::ErgmGraph, change::Change, term::DegreeTerm)

Calculate the change in the number of vertices with degree `k` for a given change.
"""
function delta(g::ErgmGraph, change::Change, term::DegreeTerm)
    return delta_degree(g, term.k, change)
end

"""
    delta(g::ErgmGraph, change::Change, term::TriangleTerm)

Calculate the change in the number of triangles for a given change.
"""
function delta(g::ErgmGraph, change::Change, term::TriangleTerm)
    return delta_triangles(g, change)
end

"""
    calculate_stats(g::ErgmGraph, model::Model)

Calculate the current statistics vector for the graph based on the model terms.
"""
function calculate_stats(g::ErgmGraph, model::Model)
    stats = zeros(Float64, length(model.terms))
    for (i, term) in enumerate(model.terms)
        if term isa EdgeTerm
            stats[i] = edges(g)
        elseif term isa DegreeTerm
            stats[i] = degree(g, term.k)
        elseif term isa TriangleTerm
            stats[i] = triangles(g)
        end
    end
    return stats
end

"""
    mcmc_step!(g::ErgmGraph, model::Model, delta_buffer::Vector{Float64})

Perform a single step of the Metropolis-Hastings algorithm, modifying the graph in place.
Returns `true` if the change was accepted, `false` otherwise.
Updates `delta_buffer` with the change in statistics.
"""
function mcmc_step!(g::ErgmGraph, model::Model, delta_buffer::Vector{Float64})
    # 1. Propose a change
    n = nv(g.graph)
    u, v = rand(1:n, 2)
    while u == v
        u, v = rand(1:n, 2)
    end

    add = !has_edge(g.graph, u, v)
    change = Change(u, v, add)

    # 2. Calculate the change in statistics
    # Use a loop to avoid allocation
    for (i, term) in enumerate(model.terms)
        delta_buffer[i] = delta(g, change, term)
    end

    # 3. Calculate the acceptance ratio
    # log_alpha = model.params' * delta_buffer
    log_alpha = dot(model.params, delta_buffer)
    alpha = exp(log_alpha)

    # 4. Accept or reject
    if rand() < alpha
        if add
            add_edge!(g.graph, u, v)
        else
            rem_edge!(g.graph, u, v)
        end
        return true
    else
        return false
    end
end

"""
    mcmc_sampler(g::ErgmGraph, model::Model, n_steps::Int; burn_in::Int = 1000, sample_graphs::Bool = false, thinning::Int = 1)

Execute a Metropolis-Hastings MCMC sampler to simulate networks from the specified ERGM.

# Arguments
- `g::ErgmGraph`: The initial network state.
- `model::Model`: The ERGM model definition (terms and parameters).
- `n_steps::Int`: The number of samples to collect.
- `burn_in::Int`: The number of initial steps to discard to allow the chain to mix (default: 1000).
- `sample_graphs::Bool`: If `true`, the full graph state for each sample is stored and returned. **Warning**: This can consume excessive memory for large graphs or long chains (default: `false`).
- `thinning::Int`: The number of steps to perform between collected samples to reduce autocorrelation (default: 1).

# Returns
- `MCMCResult`: A struct containing the history of sufficient statistics (`stats`) and, if requested, the sampled graphs (`samples`).
"""
function mcmc_sampler(g::ErgmGraph, model::Model, n_steps::Int; burn_in::Int = 1000, sample_graphs::Bool = false, thinning::Int = 1)
    
    current_g = deepcopy(g) # Use a working copy
    
    num_terms = length(model.terms)
    delta_buffer = Vector{Float64}(undef, num_terms)
    
    # Pre-calculate initial stats
    current_stats = calculate_stats(current_g, model)
    
    # Pre-allocate results
    # Only store graphs if requested. For 1M nodes, this must be false by default.
    saved_samples = sample_graphs ? Vector{ErgmGraph}(undef, n_steps) : Vector{ErgmGraph}()
    stats_history = Matrix{Float64}(undef, n_steps, num_terms)

    # Burn-in phase
    for _ in 1:burn_in
        accepted = mcmc_step!(current_g, model, delta_buffer)
        if accepted
            current_stats .+= delta_buffer
        end
    end

    # Sampling phase
    for i in 1:n_steps
        # Perform 'thinning' steps
        for _ in 1:thinning
             accepted = mcmc_step!(current_g, model, delta_buffer)
             if accepted
                 current_stats .+= delta_buffer
             end
        end

        # Record statistics
        stats_history[i, :] = current_stats

        # Record graph if requested
        if sample_graphs
            saved_samples[i] = deepcopy(current_g)
        end
    end
    
    return MCMCResult(saved_samples, stats_history)
end