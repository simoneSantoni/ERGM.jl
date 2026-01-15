module ERGM

using Graphs: AbstractGraph, nv, ne, has_edge, add_edge!, rem_edge!
using DataFrames: DataFrame

export ErgmGraph,
    set_vertex_attribute!,
    get_vertex_attribute,
    set_edge_attribute!,
    get_edge_attribute,
    set_graph_attribute!,
    get_graph_attribute,
    edges,
    degree,
    Model,
    mcmc_step,
    mcmc_sampler,
    MCMCResult,
    Change,
    delta_edges,
    delta_degree,
    Term,
    EdgeTerm,
    DegreeTerm,
    TriangleTerm,
    triangles,
    fit

"""
    ErgmGraph

The core data structure for `ERGM.jl`. It wraps a `Graphs.AbstractGraph` and augments it with
tables for vertex, edge, and graph-level attributes.

# Fields
- `graph::AbstractGraph`: The underlying graph structure (from `Graphs.jl`).
- `vertex_attributes::DataFrame`: A DataFrame where each row `i` corresponds to vertex `i`.
- `edge_attributes::Dict{Tuple{Int,Int},NamedTuple}`: A dictionary storing attributes for specific edges.
- `graph_attributes::Dict{Symbol,Any}`: A dictionary for global graph attributes (e.g., "name", "date").
"""
struct ErgmGraph
    graph::AbstractGraph
    vertex_attributes::DataFrame
    edge_attributes::Dict{Tuple{Int,Int},NamedTuple}
    graph_attributes::Dict{Symbol,Any}
end

"""
    ErgmGraph(graph::AbstractGraph)

Construct a new `ErgmGraph` from an existing `Graphs.AbstractGraph`.
Initializes empty attribute stores. Vertex attributes are initialized with an `id` column.
"""
function ErgmGraph(graph::AbstractGraph)
    num_vertices = nv(graph)
    vertex_attributes = DataFrame(id = 1:num_vertices)
    edge_attributes = Dict{Tuple{Int,Int},NamedTuple}()
    graph_attributes = Dict{Symbol,Any}()
    return ErgmGraph(graph, vertex_attributes, edge_attributes, graph_attributes)
end

"""
    set_vertex_attribute!(g::ErgmGraph, name::Symbol, value::AbstractVector)

Assign a vector of values to a vertex attribute `name`. The length of `value` must match the number of vertices.
"""
function set_vertex_attribute!(g::ErgmGraph, name::Symbol, value::AbstractVector)
    if length(value) != nv(g.graph)
        error("Length of attribute vector must be equal to the number of vertices.")
    end
    g.vertex_attributes[!, name] = value
end

"""
    get_vertex_attribute(g::ErgmGraph, name::Symbol)

Retrieve the vector of values for vertex attribute `name`.
"""
function get_vertex_attribute(g::ErgmGraph, name::Symbol)
    return g.vertex_attributes[!, name]
end

"""
    set_edge_attribute!(g::ErgmGraph, u::Int, v::Int, name::Symbol, value)

Set the value of attribute `name` for the edge connecting vertices `u` and `v`.
Errors if the edge does not exist.
"""
function set_edge_attribute!(g::ErgmGraph, u::Int, v::Int, name::Symbol, value)
    if !has_edge(g.graph, u, v)
        error("Edge ($u, $v) does not exist in the graph.")
    end
    key = (u, v)
    if haskey(g.edge_attributes, key)
        attrs = g.edge_attributes[key]
        g.edge_attributes[key] = merge(attrs, NamedTuple{(name,)}((value,)))
    else
        g.edge_attributes[key] = NamedTuple{(name,)}((value,))
    end
end

"""
    get_edge_attribute(g::ErgmGraph, u::Int, v::Int, name::Symbol)

Retrieve the value of attribute `name` for the edge (`u`, `v`). Returns `missing` if the attribute is not set.
"""
function get_edge_attribute(g::ErgmGraph, u::Int, v::Int, name::Symbol)
    key = (u, v)
    if haskey(g.edge_attributes, key) && haskey(g.edge_attributes[key], name)
        return g.edge_attributes[key][name]
    else
        return missing
    end
end

"""
    set_graph_attribute!(g::ErgmGraph, name::Symbol, value)

Set a global attribute `name` for the graph to `value`.
"""
function set_graph_attribute!(g::ErgmGraph, name::Symbol, value)
    g.graph_attributes[name] = value
end

"""
    get_graph_attribute(g::ErgmGraph, name::Symbol)

Retrieve the value of the global graph attribute `name`. Returns `missing` if not set.
"""
function get_graph_attribute(g::ErgmGraph, name::Symbol)
    if haskey(g.graph_attributes, name)
        return g.graph_attributes[name]
    else
        return missing
    end
end

include("model_terms.jl")
include("change_stats.jl")
include("mcmc.jl")
include("ui.jl")

end # module ERGM