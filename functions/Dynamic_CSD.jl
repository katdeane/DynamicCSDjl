function Dynamic_CSD(measurement,channels,LII,LIV,LV,LVI,raw,figs,Group)
    # load specified converted data in from raw folder
    Dat = matread(joinpath(raw,measurement))

    # the Baseline is the time before the tone * the sampling frequency
    BL = Int64(Dat["Header"]["t_pre"] * Dat["P"]["Fs_AD"][1])
    # tone duration is the time of the signal * the sampling frequency
    tone = Int64(Dat["Header"]["t_sig"][1] * Dat["P"]["Fs_AD"][1])
    # frequency stim list contains all frequencies presented during this measurement
    frqz = Dat["Header"]["stimlist"][:,1]

    ### Calculate CSD, LFP, Avrec, Relres, Absrec:

    csdData = SingleTrialCSD(Dat["SWEEP"], channels, BL)
    # note that avgAVREC is full csd average rectified, while AvgRectCSD is the average
    # of the csd rectified over channels (trialwise mean(abs(csd)) vs abs(csd))

    ### Calculate sink features in layers

    # output sorted by stimuli, layer, and then sink feature
    snkData = sink_dura(LII,LVI,LV,LVI,csdData["AvgCSD"],csdData["SnglTrlCSD"],BL)

    ## CSD PLOT
    csd_plot = plot(layout = (2,Int64(ceil(length(csdData["AvgCSD"])/2))))
    for icsd = 1:length(csdData["AvgCSD"])
        heatmap!(
            csd_plot,
            csdData["AvgCSD"][icsd],
            size    = (1480,1000),
            c       = :jet, # requires Colors.jl
            clims   = (-0.0005,0.0005),
            yflip   = true,
            subplot = icsd,
            title   = string(frqz[icsd]) )
    end

    name = "D:\\Julia\\DynamicCSDjl\\figs\\KIT\\KIT02_0017_CSD.pdf"
    savefig(csd_plot, name)

    return csdData, snkData
end
