module ApproxInferenceProblems
using ApproxInferenceBase, Distributions

export ApproxInferenceProblem, BlowFly

struct ApproxInferenceProblem{M,D,P,T}
    model::M
    data::D
    prior::P
    target::T
end
function Base.show(io::IO, mime::MIME"text/plain", p::ApproxInferenceProblem{M}) where M
    println(io, "ApproxInferenceProblem{M}")
end

include("blowfly.jl")

end # module
