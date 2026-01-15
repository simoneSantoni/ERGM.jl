using ERGM
using Test
using Graphs
using DataFrames
using ERGM: edges, degree, triangles

@testset "Ergm.jl" begin
    # Test ErgmGraph
    g = ErgmGraph(Graph(10, 20))
    @test nv(g.graph) == 10
    @test ne(g.graph) == 20
    @test "id" in names(g.vertex_attributes)

    set_vertex_attribute!(g, :age, rand(18:65, 10))
    @test "age" in names(g.vertex_attributes)
    @test length(get_vertex_attribute(g, :age)) == 10

    add_edge!(g.graph, 1, 2)
    set_edge_attribute!(g, 1, 2, :weight, 2.5)
    @test get_edge_attribute(g, 1, 2, :weight) == 2.5

    set_graph_attribute!(g, :name, "My Graph")
    @test get_graph_attribute(g, :name) == "My Graph"

    # Test model terms
    @test edges(g) == ne(g.graph)
    @test degree(g, 2) == count(d -> d == 2, Graphs.degree(g.graph))
    
    # Test TriangleTerm
    # Construct a graph with known triangles
    g_tri = ErgmGraph(Graph(4))
    add_edge!(g_tri.graph, 1, 2)
    add_edge!(g_tri.graph, 2, 3)
    add_edge!(g_tri.graph, 3, 1) # One triangle (1-2-3)
    add_edge!(g_tri.graph, 3, 4)
    # Total triangles should be 1
    @test triangles(g_tri) == 1
    
    add_edge!(g_tri.graph, 2, 4) # Now (2-3-4) is another triangle. Total 2.
    @test triangles(g_tri) == 2

    # Test MCMC
    model = Model([EdgeTerm(), DegreeTerm(2), TriangleTerm()], [-1.0, 0.5, 0.1])
    g_start = ErgmGraph(Graph(10, 0))
    
    # Test default behavior (no graphs returned)
    result = mcmc_sampler(g_start, model, 100, burn_in = 10)
    @test result isa MCMCResult
    @test isempty(result.samples)
    @test size(result.stats) == (100, 3) # 100 samples, 3 terms

    # Test with sample_graphs = true
    result_with_graphs = mcmc_sampler(g_start, model, 10, burn_in = 5, sample_graphs = true)
    @test length(result_with_graphs.samples) == 10
    @test result_with_graphs.samples[1] isa ErgmGraph

    # Test UI
    g_fit = ErgmGraph(Graph(10, 20))
    terms = [EdgeTerm(), DegreeTerm(2), TriangleTerm()]
    result_fit = fit(terms, g_fit)
    @test result_fit isa MCMCResult
    @test size(result_fit.stats) == (1000, 3)
    @test isempty(result_fit.samples)

end
