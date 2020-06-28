using Documenter, ApproxInferenceProblems

makedocs(
    modules = [ApproxInferenceProblems],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Johanni Brea",
    sitename = "ApproxInferenceProblems.jl",
    pages = Any["index.md"],
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(repo = "github.com/jbrea/ApproxInferenceProblems.jl.git", push_preview = true)
