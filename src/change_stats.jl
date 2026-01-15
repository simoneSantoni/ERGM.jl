# Change statistics for Ergm.jl

using Graphs: degree, common_neighbors

"""
    Change

A struct to represent a change in the graph, i.e., adding or removing an edge.
"""
struct Change
    u::Int
    v::Int
    add::Bool # true if edge is added, false if removed
end

"""
    delta_edges(g::ErgmGraph, change::Change)

Calculate the change in the number of edges given a `Change` object.
"""
function delta_edges(g::ErgmGraph, change::Change)
    return change.add ? 1 : -1
end

"""
    delta_degree(g::ErgmGraph, k::Int, change::Change)

Calculate the change in the number of vertices with degree `k` given a `Change` object.
"""
function delta_degree(g::ErgmGraph, k::Int, change::Change)
    # Optimized: get degree of specific vertices directly
    du = degree(g.graph, change.u)
    dv = degree(g.graph, change.v)

    delta = 0
    if change.add
        if du == k - 1
            delta += 1
        end
        if dv == k - 1
            delta += 1
        end
        if du == k
            delta -= 1
        end
        if dv == k
            delta -= 1
        end
    else # remove
        if du == k + 1
            delta += 1
        end
        if dv == k + 1
            delta += 1
        end
        if du == k
            delta -= 1
        end
        if dv == k
            delta -= 1
        end
    end
    return delta
end

"""
    delta_triangles(g::ErgmGraph, change::Change)

Calculate the change in the number of triangles given a `Change` object.
"""
function delta_triangles(g::ErgmGraph, change::Change)
    # The number of new/removed triangles is exactly the number of common neighbors
    num_common = length(common_neighbors(g.graph, change.u, change.v))
    return change.add ? num_common : -num_common
end