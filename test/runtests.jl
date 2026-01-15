using ERGM
using Test
using Graphs
using DataFrames
using ERGM: edges, degree

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

    # Test MCMC
    model = Model([EdgeTerm(), DegreeTerm(2)], [-1.0, 0.5])
    g_start = ErgmGraph(Graph(10, 0))
    samples = mcmc_sampler(g_start, model, 100, burn_in = 10)
    @test length(samples) == 100

    # Test UI
    g_fit = ErgmGraph(Graph(10, 20))
    terms = [EdgeTerm(), DegreeTerm(2)]
    samples_fit = fit(terms, g_fit)
    @test length(samples_fit) == 1000

end
