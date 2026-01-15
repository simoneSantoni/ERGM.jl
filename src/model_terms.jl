# Model terms for Ergm.jl

using Graphs: ne
import Graphs: degree

"""
    edges(g::ErgmGraph)

Calculate the number of edges in the graph. This is a fundamental model term in ERGMs.
"""
function edges(g::ErgmGraph)
    return ne(g.graph)
end

"""
    degree(g::ErgmGraph, k::Int)

Calculate the number of vertices with degree `k`. This term is used to model the degree distribution of the network.
"""
function degree(g::ErgmGraph, k::Int)
    return count(d -> d == k, degree(g.graph))
end
