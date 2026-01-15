using ERGM
using Documenter

makedocs(;
    modules=[ERGM],
    authors="simoneSantoni <simone.santoni.1@city.ac.uk>",
    repo="https://github.com/simoneSantoni/ERGM.jl/blob/{commit}{path}#{line}",
    sitename="ERGM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://simoneSantoni.github.io/ERGM.jl",
        assets=String[],
        repolink="https://github.com/simoneSantoni/ERGM.jl",
        edit_link="main",
        ansicolor=true,
        collapselevel=1,
    ),
    pages=[
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/simoneSantoni/ERGM.jl",
    devbranch="main",
)