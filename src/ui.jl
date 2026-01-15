# User interface for Ergm.jl

"""
    fit(terms::Vector{<:Term}, g::ErgmGraph; n_steps = 1000, burn_in = 1000)

Fit an ERGM model to an observed graph.

**Note**: Currently, this function performs a *simulation* of the model defined by the provided `terms` with initial dummy parameters (all ones), rather than performing Maximum Likelihood Estimation (MLE). It serves as a placeholder for the future estimation workflow.

# Arguments
- `terms::Vector{<:Term}`: A list of model terms (statistics) to include in the model.
- `g::ErgmGraph`: The observed network.
- `n_steps::Int`: Number of MCMC samples to draw (default: 1000).
- `burn_in::Int`: Number of burn-in steps (default: 1000).

# Returns
- `MCMCResult`: The result of the simulation, containing the statistics of the sampled graphs.
"""
function fit(terms::Vector{<:Term}, g::ErgmGraph; n_steps = 1000, burn_in = 1000)
    params = ones(length(terms))
    model = Model(terms, params)

    # Return MCMCResult. By default, do not sample graphs to save memory.
    return mcmc_sampler(g, model, n_steps, burn_in = burn_in, sample_graphs = false)
end