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
            csd_plot,#csd_plot,
            csdData["AvgCSD"][icsd],
            size    = (1480,1000),
            c       = :jet, # requires Colors.jl
            clims   = (-0.0005,0.0005),
            yflip   = true,
            subplot = icsd,
            title   = string(frqz[icsd]))

        curCSD = snkData[string(icsd)]

        if haskey(curCSD,"LII")
            for isink = 1:length(curCSD["LII"]["SinkON"])
                start = curCSD["LII"]["SinkON"][isink] .+ BL
                stop = curCSD["LII"]["SinkOFF"][isink] .+ BL
                startline, stopline = repeat([start],length(LII)), repeat([stop],length(LII))
                topline, botline =  repeat([LII[1]],stop-start+1), repeat([LII[end]],stop-start+1)
                plot!(csd_plot, startline, LII,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, stopline, LII,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], botline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], topline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
            end
        end

        if haskey(curCSD,"LIV")
            for isink = 1:length(curCSD["LIV"]["SinkON"])
                start = curCSD["LIV"]["SinkON"][isink] .+ BL
                stop = curCSD["LIV"]["SinkOFF"][isink] .+ BL
                startline, stopline = repeat([start],length(LIV)), repeat([stop],length(LIV))
                topline, botline =  repeat([LIV[1]],stop-start+1), repeat([LIV[end]],stop-start+1)
                plot!(csd_plot, startline, LIV,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, stopline, LIV,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], botline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], topline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
            end
        end

        if haskey(curCSD,"LV")
            for isink = 1:length(curCSD["LV"]["SinkON"])
                start = curCSD["LV"]["SinkON"][isink] .+ BL
                stop = curCSD["LV"]["SinkOFF"][isink] .+ BL
                startline, stopline = repeat([start],length(LV)), repeat([stop],length(LV))
                topline, botline =  repeat([LV[1]],stop-start+1), repeat([LV[end]],stop-start+1)
                plot!(csd_plot, startline, LV,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, stopline, LV,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], botline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], topline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
            end
        end

        if haskey(curCSD,"LVI")
            for isink = 1:length(curCSD["LVI"]["SinkON"])
                start = curCSD["LVI"]["SinkON"][isink] .+ BL
                stop = curCSD["LVI"]["SinkOFF"][isink] .+ BL
                startline, stopline = repeat([start],length(LVI)), repeat([stop],length(LVI))
                topline, botline =  repeat([LVI[1]],stop-start+1), repeat([LVI[end]],stop-start+1)
                plot!(csd_plot, startline, LVI,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, stopline, LVI,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], botline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
                plot!(csd_plot, [start:stop...], topline,
                    subplot = icsd, legend=false, linewidth = 4, c = :black)
            end
        end
    end

    if !isdir(joinpath(figs,Group))
        mkdir(joinpath(figs,Group))
    end
    name = joinpath(figs,Group,measurement[1:end-4]) * "_CSD.pdf"
    savefig(csd_plot, name)

    return csdData, snkData
end
