function interX(vdata,pdata)

    # vdata should be the vector of data
    # pdata should be the real value to which the threshold is set

    # create bool list for where vdata lies above (1) or below (0) the threshold
    allabove = findall(vdata.>pdata)
    if length(allabove) < 2
        P = missing
    else
        P = Array{Union{Missing, Int64}}(missing,length(allabove))
        P[1] = findfirst(vdata.>pdata)

        for iX = 1:length(allabove)-1

            if (allabove[iX+1] - allabove[iX]) .!= 1
                P[iX+1] = allabove[iX]
            end

        end

        P = collect(skipmissing(P))
        push!(P,findlast(vdata.>pdata))
        # P is now a list of the closest ms before each line cross
    end
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
