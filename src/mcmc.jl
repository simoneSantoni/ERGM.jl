# MCMC sampler for Ergm.jl

"""
    Term

An abstract type for ERGM model terms.
"""
abstract type Term end

"""
    EdgeTerm

A term representing the number of edges in the graph.
"""
struct EdgeTerm <: Term end

"""
    DegreeTerm

A term representing the number of vertices with a given degree `k`.
"""
struct DegreeTerm <: Term
    k::Int
end

"""
    Model

A struct to represent an ERGM model, containing the model terms and parameters.
"""
struct Model
    terms::Vector{Term}
    params::Vector{Float64}
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
    mcmc_step(g::ErgmGraph, model::Model)

Perform a single step of the Metropolis-Hastings algorithm.
"""
function mcmc_step(g::ErgmGraph, model::Model)
    # 1. Propose a change
    n = nv(g.graph)
    u, v = rand(1:n, 2)
    while u == v
        u, v = rand(1:n, 2)
    end

    add = !has_edge(g.graph, u, v)
    change = Change(u, v, add)

    # 2. Calculate the change in statistics
    delta_g = [delta(g, change, term) for term in model.terms]

    # 3. Calculate the acceptance ratio
    log_alpha = model.params' * delta_g
    alpha = exp(log_alpha)

    # 4. Accept or reject
    if rand() < alpha
        g_prime = deepcopy(g)
        if add
            add_edge!(g_prime.graph, u, v)
        else
            rem_edge!(g_prime.graph, u, v)
        end
        return g_prime
    else
        return g
    end
end

"""
    mcmc_sampler(g::ErgmGraph, model::Model, n_steps::Int; burn_in::Int = 1000)

Run the MCMC sampler for a given number of steps.
"""
function mcmc_sampler(g::ErgmGraph, model::Model, n_steps::Int; burn_in::Int = 1000)
    samples = Vector{ErgmGraph}(undef, n_steps)
    current_g = g
    for i = 1:(n_steps+burn_in)
        current_g = mcmc_step(current_g, model)
        if i > burn_in
            samples[i-burn_in] = current_g
        end
    end
    return samples
end
