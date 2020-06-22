function SingleTrialCSD(SWEEP, channels, BL=200)

    ### pull single trial data analysis out

    # determines filter width, 300 very conservative, 450 ok, 600 getting smooth
    kernel      = 300
    # Neuronexus Probes distance
    chan_dist   = 50
    # hamming window size and padding window size
    hamm_width  = Int64((kernel./chan_dist) + (mod((kernel./chan_dist),2)-1) * -1)
    padd_size   = Int64(floor(hamm_width/2) + 1)
    # stimulation presentation order by trial
    stim_list = Int64.(SWEEP["Header"])

    # pre-allocate
    LFP    = ones(size(stim_list,1),size(channels,2),size(SWEEP["AD"][1],1))
    CSD    = ones(size(stim_list,1),size(channels,2),size(SWEEP["AD"][1],1))
    AVREC  = ones(size(stim_list,1),size(SWEEP["AD"][1],1))
    RELRES = ones(size(stim_list,1),size(SWEEP["AD"][1],1))
    ABSRES = ones(size(stim_list,1),size(SWEEP["AD"][1],1))
    LayerAVREC  = ones(size(stim_list,1),size(channels,2),size(SWEEP["AD"][1],1))

    for i_trial = 1:size(stim_list,1)

        # Channel AD, or direct LFP recording
        lfp = dropdims( (SWEEP["AD"][i_trial][:,channels']), dims=3)'
        # convert LFP to CSD
        csd = get_csd(lfp, chan_dist, BL, hamm_width)

        LFP[i_trial,:,:]    = lfp
        CSD[i_trial,:,:]    = csd

        # average rectified csd (mean of the absolute values along time)
        AVREC[i_trial,:,:]       = mean(broadcast(abs,csd),dims=1)
        LayerAVREC[i_trial,:,:]  = broadcast(abs,csd)
        # relative residuals (sum of csd divided by the sum of the absolute csd)
        RELRES[i_trial,:,:]      = sum(csd,dims=1)./sum(broadcast(abs,csd),dims=1)
        ABSRES[i_trial,:,:]      = sum(csd,dims=1)

    end

    ### arrange single trial data by stimulus and average

    un_stim = unique(stim_list)
    # Base data and CSD
    AvgLFP         = Array{Any}(undef,length(un_stim))
    SnglTrlLFP     = Array{Any}(undef,length(un_stim))
    AvgCSD         = Array{Any}(undef,length(un_stim))
    SnglTrlCSD     = Array{Any}(undef,length(un_stim))
    # calculations on the CSD
    AvgAVREC       = Array{Any}(undef,length(un_stim))
    SnglTrlAVREC   = Array{Any}(undef,length(un_stim))
    AvgRELRES      = Array{Any}(undef,length(un_stim))
    SnglTrlRELRES  = Array{Any}(undef,length(un_stim))
    AvgABSRES      = Array{Any}(undef,length(un_stim))
    SnglTrlABSRES  = Array{Any}(undef,length(un_stim))
    # these are rectified for layer-wise avrec calculations downstream
    AvgRectCSD     = Array{Any}(undef,length(un_stim))
    SnglTrlRectCSD = Array{Any}(undef,length(un_stim))

    for i_stim = 1:length(un_stim)
        # isolate all trials for this stimulus:
        curTrial = findall(x->x==i_stim, stim_list[:])
        # Local field potential and current source density:
        SnglTrlLFP[i_stim] = LFP[curTrial,:,:]
        AvgLFP[i_stim] = dropdims(mean(SnglTrlLFP[i_stim],dims=1),dims=1)
        SnglTrlCSD[i_stim] = CSD[curTrial,:,:]
        AvgCSD[i_stim] = dropdims(mean(SnglTrlCSD[i_stim],dims=1),dims=1)
        # Average rectified, relative residual, absolute residual:
        SnglTrlAVREC[i_stim] = AVREC[curTrial,:]
        AvgAVREC[i_stim] = mean(SnglTrlAVREC[i_stim],dims=1)
        SnglTrlRELRES[i_stim] = RELRES[curTrial,:]
        AvgRELRES[i_stim] = mean(SnglTrlRELRES[i_stim],dims=1)
        SnglTrlABSRES[i_stim] = ABSRES[curTrial,:]
        AvgABSRES[i_stim] = mean(SnglTrlABSRES[i_stim],dims=1)
        # Rectified CSD for use in layer-wise AVREC downstream
        SnglTrlRectCSD[i_stim] = LayerAVREC[curTrial,:,:]
        AvgRectCSD[i_stim] = dropdims(mean(SnglTrlRectCSD[i_stim],dims=1),dims=1)
    end
    # time to figure out what type of data frame I want to turn this into.


    Data = Dict()
    Data["AvgLFP"]          = AvgLFP
    Data["SnglTrlLFP"]      = SnglTrlLFP
    Data["AvgCSD"]          = AvgCSD
    Data["SnglTrlCSD"]      = SnglTrlCSD
    Data["AvgAVREC"]        = AvgAVREC
    Data["SnglTrlAVREC"]    = SnglTrlAVREC
    Data["AvgRELRES"]       = AvgRELRES
    Data["SnglTrlRELRES"]   = SnglTrlRELRES
    Data["AvgABSRES"]       = AvgABSRES
    Data["SnglTrlABSRES"]   = SnglTrlABSRES
    Data["AvgRectCSD"]      = AvgRectCSD
    Data["SnglTrlRectCSD"]  = SnglTrlRectCSD

    return Data
end
