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
    Change,
    delta_edges,
    delta_degree,
    Term,
    EdgeTerm,
    DegreeTerm,
    fit

"""
    ErgmGraph

A struct to represent a graph for ERGM analysis. It contains the graph itself,
as well as attributes for vertices, edges, and the graph as a whole.
"""
struct ErgmGraph
    graph::AbstractGraph
    vertex_attributes::DataFrame
    edge_attributes::Dict{Tuple{Int,Int},NamedTuple}
    graph_attributes::Dict{Symbol,Any}
end

"""
    ErgmGraph(graph::AbstractGraph)

Create an `ErgmGraph` from a `Graphs.jl` graph object.
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

Set a vertex attribute for all vertices in the graph.
"""
function set_vertex_attribute!(g::ErgmGraph, name::Symbol, value::AbstractVector)
    if length(value) != nv(g.graph)
        error("Length of attribute vector must be equal to the number of vertices.")
    end
    g.vertex_attributes[!, name] = value
end

"""
    get_vertex_attribute(g::ErgmGraph, name::Symbol)

Get a vertex attribute for all vertices in the graph.
"""
function get_vertex_attribute(g::ErgmGraph, name::Symbol)
    return g.vertex_attributes[!, name]
end

"""
    set_edge_attribute!(g::ErgmGraph, u::Int, v::Int, name::Symbol, value)

Set an attribute for a specific edge.
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

Get an attribute for a specific edge.
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

Set a graph-level attribute.
"""
function set_graph_attribute!(g::ErgmGraph, name::Symbol, value)
    g.graph_attributes[name] = value
end

"""
    get_graph_attribute(g::ErgmGraph, name::Symbol)

Get a graph-level attribute.
"""
function get_graph_attribute(g::ErgmGraph, name::Symbol)
    if haskey(g.graph_attributes, name)
        return g.graph_attributes[name]
    else
        return missing
    end
end

include("model_terms.jl")
include("changelog.jl")
include("mcmc.jl")
include("ui.jl")

end # module ERGM
