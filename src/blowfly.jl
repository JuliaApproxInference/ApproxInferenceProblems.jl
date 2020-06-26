"""
Likelihood-free inference for the blow-fly model was introduced by [Simon N.
Wood](http://dx.doi.org/10.1038/nature09319). We model here the discrete time
stochastic dynamics of the size ``N`` of an adult blowfly population as given in [section 1.2.3 of the supplementary
information](https://static-content.springer.com/esm/art%3A10.1038%2Fnature09319/MediaObjects/41586_2010_BFnature09319_MOESM302_ESM.pdf).
```math
N_{t+1} = P N_{t-τ} exp(-N_{t-τ}/N₀)eₜ + Nₜ exp(-δ ϵₜ)
```
where ``eₜ`` and ``ϵₜ`` are independent Gamma random deviates with
mean 1 and variance ``σ_p²`` and ``σ_d²``, respectively.
"""
module BlowFlyModel
using Random, Distributions, StatsBase

Base.@kwdef struct BlowFly{R,S}
    burnin::Int = 50
    T::Int = 1000
    rng::R = MersenneTwister()
    statistics::S = histogram_summary_statistics
end
function (m::BlowFly)(P, N₀, σd, σp, τ, δ)
    p1 = Gamma(1/σp^2, σp^2)
    p2 = Gamma(1/σd^2, σd^2)
    T = m.T + m.burnin + τ
    N = fill(180., T)
    for t in τ+1:T-1
        N[t+1] = P * N[t-τ] * exp(-N[t-τ]/N₀)*rand(m.rng, p1) + N[t]*exp(-δ*rand(m.rng, p2))
    end
    m.statistics(N[end-m.T+1:end])
end

histogram_summary_statistics(N) = fit(Histogram, N, 140:16:16140).weights

# We will use a normal prior on log-transformed parameters.
function parameter(logparams)
    lP, lN₀, lσd, lσp, lτ, lδ = logparams
    (P = round(exp(2 + 2lP)),
    N₀ = round(exp(4 + .5lN₀)),
    σd = exp(-.5 + lσd),
    σp = exp(-.5 + lσp),
    τ = round(Int, max(1, min(500, exp(2 + lτ)))),
    δ = exp(-1 + .4lδ))
end
(m::BlowFly)(logparams) = m(parameter(logparams)...)

end # module

import .BlowFlyModel: BlowFly
default_parameters(::Type{BlowFly}) = [(log(29) - 2)/2, (log(260) - 4)*2,
                                       log(.6) + .5, log(.3) + .5, log(7) - 2,
                                       (log(.2) + 1)/.4]
prior(::Type{BlowFly}) = MultivariateNormal(zeros(6), ones(6))
function ApproxInferenceProblem(::Type{BlowFly};
                                prior = prior(BlowFly),
                                target = default_parameters(BlowFly),
                                kwargs...)
    model = BlowFly(; kwargs...)
    ApproxInferenceProblem(model, model(target), prior, target)
end

