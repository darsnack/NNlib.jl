function softmax!(out::AbstractVecOrMat, xs::AbstractVecOrMat)
  # out[end, :] .= maximum(xs, 1)
  for j = 1:size(xs, 2)
    out[end, j] = 0
    for i = 1:size(xs, 1)
      @inbounds out[end, j] = max(out[end, j], xs[i, j])
    end
  end
  # out .= exp(xs .- out[end, :])
  for j = 1:size(out, 2), i = 1:size(out, 1)
    @inbounds out[i, j] = exp(xs[i, j] - out[end, j])
  end
  # out ./= sum(out, 1)
  for j = 1:size(out, 2)
    s = zero(eltype(out))
    for i = 1:size(out, 1)
      @inbounds s += out[i, j]
    end
    for i = 1:size(out, 1)
      @inbounds out[i, j] /= s
    end
  end
  return out
end

softmax!(xs) = softmax!(xs, xs)
softmax(xs) = softmax!(similar(xs), xs)

function ∇softmax!(out::AbstractVecOrMat, Δ::AbstractVecOrMat, xs::AbstractVecOrMat)
  s = sum(exp, xs, 1)
  out .= exp.(xs)./s.*(Δ .- sum(Δ .* exp.(xs), 1)./s)
end

∇softmax!(Δ, xs) = ∇softmax!(Δ, Δ, xs)
∇softmax(Δ, xs) = ∇softmax!(similar(Δ), Δ, xs)

"""
    softmax(xs) = exp.(xs) ./ sum(exp.(xs))

[Softmax](https://en.wikipedia.org/wiki/Softmax_function) takes
log-probabilities (any real vector) and returns a probability distribution that
sums to 1.

If given a matrix it will treat it as a batch of vectors, with each column
independent.

    julia> softmax([1,2,3.])
    3-element Array{Float64,1}:
      0.0900306
      0.244728
      0.665241
"""
softmax
