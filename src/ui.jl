# User interface for Ergm.jl

"""
    fit(terms::Vector{<:Term}, g::ErgmGraph; n_steps = 1000, burn_in = 1000)

Fit an ERGM to a graph.

This function is a placeholder and does not yet perform a proper model fit.
It runs the MCMC sampler with dummy parameters and returns the sampled graphs.
"""
function fit(terms::Vector{<:Term}, g::ErgmGraph; n_steps = 1000, burn_in = 1000)
    params = ones(length(terms))
    model = Model(terms, params)

    return mcmc_sampler(g, model, n_steps, burn_in = burn_in)
end
