function sink_dura(LII, LIV, LV, LVI, AvgCSD, SnglTrlCSD, BL=200)

    std_detect = 1.0;
    std_lev = 1.4;

    LayName  = ["LII","LIV","LV","LVI"]
    LayDat   = [LII, LIV, LV, LVI]
    StimName = string.(1:size(AvgCSD,1))

    Stim = Dict()
    for istim = 1:size(AvgCSD,1)

        Layer = Dict() # initialize here to not overwrite
        for ilay = 1:length(LayDat)

            # Generate thresholds, raw and smooth data for this stimuli and layer
            thresh_mean, thresh_std, smoothCSD, rawCSD, rawCSD_single =
                sinkdet_var(AvgCSD[istim], SnglTrlCSD[istim], LayDat[ilay],
                BL, std_detect, std_lev)

            # check the plots for sanity:
            # plot(rawCSD')
            # plot!(smoothCSD)
            # plot!(ones(length(rawCSD)) .* thresh_mean)
            # plot!(ones(length(rawCSD)) .* thresh_std)

            # list of intercepts with first threshold on smooth data
            P = interX(smoothCSD,thresh_mean) # in functions.jl

            # generate features, root mean square, peak amp, peak latency from raw data
            rmslist,pamplist,platlist = make_sinklist(P,smoothCSD,rawCSD,thresh_std) # in functions.jl

            # Collect the Data, function below
            Layer[LayName[ilay]] = LayerSink(P,rmslist,pamplist,platlist,BL,rawCSD_single)

        end
        Stim[StimName[istim]] = Layer
    end

    return Stim

end

function LayerSink(P,rmslist,pamplist,platlist,BL,rawCSD_single)

    Data = Dict()

    ### Average Trial

    if isempty(collect(skipmissing(rmslist))) #no detected sinks
        Data["SinkON"]   = missing
        Data["SinkOFF"]  = missing
        Data["SinkDUR"]  = missing
        Data["SinkRMS"]  = missing
        Data["SinkPAMP"] = missing
        Data["SinkPLAT"] = missing
    else # at least one detected sink
        sinklist = findall(rmslist .!== missing)
        Data["SinkON"]   = P[sinklist] .- BL
        Data["SinkOFF"]  = P[sinklist.+1] .- BL
        Data["SinkDUR"]  = Data["SinkOFF"] - Data["SinkON"]
        Data["SinkRMS"]  = rmslist[sinklist]
        Data["SinkPAMP"] = pamplist[sinklist]
        Data["SinkPLAT"] = platlist[sinklist] .- BL
    end

    ### Single Trial

    # skip the rest if there's no detected sinks
    if ismissing(Data["SinkRMS"])
        Data["Sngl_PAMP"] = missing
        Data["Sngl_PLAT"] = missing
        Data["Sngl_RMS"]  = missing
    else
        Data["Sngl_RMS"], Data["Sngl_PAMP"], Data["Sngl_PLAT"] =
            make_snglsinklist(rawCSD_single,Data["SinkON"],Data["SinkOFF"])  # in functions.jl
    end

    return Data
end
