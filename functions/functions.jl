function interX(data, threshold)
    # Written by Asim Hassan Dar 24.06.2020

    over = data .> threshold

    onsets=[]
    offsets=[]
    # Starting at two to compare to first point. Ending at second last data point. (workable?)
    for data_idx in 2:length(data)-1
        if data[data_idx] > threshold && data[data_idx-1] < threshold
            push!(onsets,data_idx)
        end

        if data[data_idx] < threshold && data[data_idx-1] > threshold
            offset = data_idx
            push!(offsets,data_idx)
        end

    end

    P = sort([onsets; offsets])
    return P

end

function make_sinklist(P,smoothCSD,rawCSD,thresh_std)
    # generate features, root mean square, peak amp, peak latency from raw data
    rmslist  = Array{Union{Missing, Float64}}(missing,length(P))
    pamplist = Array{Union{Missing, Float64}}(missing,length(P))
    platlist = Array{Union{Missing, Float64}}(missing,length(P))

    if length(P) > 1
        for iX = 1:length(P)-1
            # if the peak between points exceeds the second threshold then it's a sink
            if maximum(smoothCSD[P[iX]:P[iX+1]]) >= thresh_std
                rmslist[iX] = rms(rawCSD[P[iX]:P[iX+1]])
                pamplist[iX] = maximum(rawCSD[P[iX]:P[iX+1]])
                platlist[iX] = findfirst(rawCSD[P[iX]:P[iX+1]] .== pamplist[iX]) + P[iX]-1
            end
        end
    end
    return rmslist, pamplist, platlist
end

function make_snglsinklist(rawCSD_single,SinkON,SinkOFF)
    sngl_rmslist  = Array{Union{Missing, Float64}}(missing,size(rawCSD_single,1),length(SinkON))
    sngl_pamplist = Array{Union{Missing, Float64}}(missing,size(rawCSD_single,1),length(SinkON))
    sngl_platlist = Array{Union{Missing, Float64}}(missing,size(rawCSD_single,1),length(SinkON))

    for itrial = 1:size(rawCSD_single,1)
        curTrial =  rawCSD_single[itrial,:,:]

        rmslist  = Array{Union{Missing, Float64}}(missing,length(SinkON))
        pamplist = Array{Union{Missing, Float64}}(missing,length(SinkON))
        platlist = Array{Union{Missing, Float64}}(missing,length(SinkON))

        for isink = 1:length(SinkON)
            curSink = curTrial[SinkON[isink]:SinkOFF[isink]]
            rmslist[isink]  = rms(curSink)
            pamplist[isink] = maximum(curSink)
            platlist[isink] = findfirst(curSink .== pamplist[isink]) + SinkON[isink]
        end

        sngl_rmslist[itrial,:]  = Float64.(rmslist)'
        sngl_pamplist[itrial,:] = Float64.(pamplist)'
        sngl_platlist[itrial,:] = Float64.(platlist)'
    end
    return sngl_rmslist, sngl_pamplist, sngl_platlist
end
