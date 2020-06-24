function sink_dura(LII, LIV, LV, LVI, AvgCSD, SnglTrlCSD, BL=200)

    std_detect = 1.1;
    std_lev = 1.5;

    LayName  = ["LII","LIV","LV","LVI"]
    LayDat   = [LII, LIV, LV, LVI]
    StimName = string.(1:size(AvgCSD,1))

    Stim = Dict()

    for istim = 1:size(AvgCSD,1)

        Layer = Dict() # initialize here to not overwrite
        for ilay = 1:length(LayDat)

### Average Trial

            # find the standard deviation and mean of the current stim baseline
            csdBL = AvgCSD[istim][:,1:BL]
            stdBL, meanBL = std(csdBL), mean(csdBL)

            # current stimulus in the current layer, averaged and single trial
            rawCSD = mean(AvgCSD[istim][LayDat[ilay],:], dims=1) * -1 #sinks positive
            rawCSD_single = mean(SnglTrlCSD[istim][:,LayDat[ilay],:], dims=2) * -1

            # zero all source info and shape data for sink detection
            zeroCSD = AvgCSD[istim][LayDat[ilay],:]
            zeroCSD[zeroCSD .>= 0.0] .= 0.0;
            zeroCSD = mean(zeroCSD, dims=1) * -1

            # create gaussian filter for smoothing and apply it
            gauswin = gaussian(11,0.15) #fairly conservative alpha
            smoothCSD = (conv(zeroCSD[:],gauswin) ./sum(gauswin))[6:805] #cut off filter padding
            # cap the beginning and end of the data
            smoothCSD[1:BL] .= meanBL - stdBL
            smoothCSD[end]   = meanBL - stdBL
            # generate threshold line for detecting and keeping a sink
            thresh_mean = (meanBL + (stdBL*std_detect))
            thresh_std  = (meanBL + (stdBL*std_lev))

            # check the plots for sanity:
            # plot(zeroCSD')
            # plot(smoothCSD)
            # plot!(ones(length(rawCSD)) .* thresh_mean)
            # plot!(ones(length(rawCSD)) .* thresh_std)

            ### Find the sinks

            # list of intercepts with first threshold
            P = interX(smoothCSD,thresh_mean) # in functions.jl
            # generate features, root mean square, peak amp, peak latency from raw data
            rmslist,pamplist,platlist = make_sinklist(P,smoothCSD,rawCSD,thresh_std) # in functions.jl

            ### Collect the Data
            Data = Dict()
            if sum(skipmissing(rmslist)) == 0 #no detected sinks
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
                continue
            end

            Data["Sngl_RMS"],Data["Sngl_PAMP"],Data["Sngl_PLAT"] =
                make_snglsinklist(rawCSD_single,SinkON,SinkOFF)  # in functions.jl

            Layer[LayName[ilay]] = Data
        end
        Stim[StimName[istim]] = Layer
    end

    return Stim

end
