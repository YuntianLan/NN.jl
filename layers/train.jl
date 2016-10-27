function sgd(net::SequentialNet, batch_X, batch_Y; lr::Float64 = 0.01, alpha::Float64 = 0.9)
    local batch_size = size(batch_X)[1]
    local ttl_loss   = []
    local gradients  = []
    for i = 1:length(net.layers)
        local layer = net.layers[i]
        append!(gradients,zeros(size(getParam(layer))))
    end
    for b = 1:batch_size
        local X = batch_X[b,:] 
        local Y = batch_Y[b,:]
        local loss = forward(net, X, Y)
        backward(net, Y)
        for i = 1:length(net.layers)
            gradients[i] += gradient(net.layers[i]) 

        end
        append!(ttl_loss, loss)
    end
    for i = 1:length(net.layers)
        local layer = net.layers[i]
        local theta = getParam(layer) - lr * gradients[i] / batch_size + alpha * getLDiff(layer)
        setParam!(layer, theta)
    end

    return mean(ttl_loss)
end

function train(net::SequentialNet, X, Y; batch_size::Int64 = 64, ttl_epo::Int64 = 10, lrSchedule = (x -> 0.01))
    local N = size(Y)[1]
    local batch=0
    local epo_losses = []
    for epo = 1:ttl_epo
        println("Epo $(epo):")
        local num_batch = ceil(N/batch_size)-1
        println("NUMBER OF BATCH:$(num_batch)")
        all_losses = []
        for bid = 0:num_batch
            batch += 1
            local sidx::Int = convert(Int64, bid*batch_size+1)
            local eidx::Int = convert(Int64, min(N, (bid+1)*batch_size))
            local batch_X = X[sidx:eidx,:]
            local batch_Y = Y[sidx:eidx,:]
            local loss = sgd(net, batch_X, batch_Y; lr=lrSchedule(epo))
            append!(all_losses, loss)
            println("[$(bid)/$(num_batch)]Loss is: $(loss)")
        end
        local epo_loss = mean(all_losses)
        append!(epo_losses, epo_loss)
        println("Epo $(epo) has loss : $(epo_loss)")
    end
end
