# Dummy Layer to create the input shape for initilization
# include("LayerBase.jl")
type InputLayer <: DataLayer
    has_init :: Bool
    shape    :: Tuple
    x        :: Array{Float64}
    y        :: Array{Float64}
    dldy     :: Array{Float64}
    dldx     :: Array{Float64}
    function InputLayer(shape)
        # TODO: could allocate less memory by having only two arrays to pass around
        return new(true, shape, Array{Float64}(shape), Array{Float64}(shape), Array{Float64}(shape), Array{Float64}(shape))
    end
end

function init(l::InputLayer, p::Union{Layer,Void}, config::Dict{String,Any}; kwargs...)
    nothing
end

function update(l::InputLayer, input_size::Tuple;)
    # Reinitialize the memory due to the updated of the batch_size
    l.shape = input_size
    # println("Input layer shape update:$(l.shape)")
end

function forward(l::InputLayer, X::Union{SubArray{Float64},Array{Float64}}; kwargs...)
    if size(X) != l.shape
        update(l, size(X))
    end
    l.x = X
    l.y = X
    return l.y
end

function backward(l::InputLayer, DLDY::Union{SubArray{Float64},Array{Float64}}; kwargs...)
    l.dldy = DLDY
    l.dldx = DLDY
    return l.dldx
end

function getInputSize(l::InputLayer)
    return l.shape
end

function getOutputSize(l::InputLayer)
    return l.shape
end

# l = InputLayer((1000,5))
# X = rand(1000, 500)
# Y = rand(1000, 500)
# println("Compile the method for the first time...")
# @time init(l, nothing, Dict{String, Any}("batch_size" => 1000, "input_size" => [500]))
# @time forward(l,X)
# @time backward(l,Y)
#
# println("Start profiling...")
# print("Forward:")
# @time begin
#   for i = 1:10
#     forward(l,X)
#   end
# end
#
# @time begin
#   for i = 1:1000
#     forward(l, X)
#   end
# end
#
# print("Backward")
# @time begin
#   for i = 1:10
#     backward(l,Y)
#   end
# end
#
# @time begin
#   for i = 1:1000
#     forward(l, X)
#   end
# end
