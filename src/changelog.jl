# Changelog for Ergm.jl

using Graphs: degree

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
    du = degree(g.graph)[change.u]
    dv = degree(g.graph)[change.v]

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
