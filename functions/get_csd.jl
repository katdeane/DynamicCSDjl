function get_csd(lfp,chan_dist=50,BL=200,hamm_width=7)

    # check shape and change if necessary (time should be on x axis)
    if size(lfp,1) > size(lfp,2)
        lfp = permutedims(lfp, [2,1])
        shiftback = true
    else
        shiftback = false
    end

    # baseline correct if baseline specified
    if BL > 0
        BLmat = repeat(mean(lfp[:,1:BL],dims=2)',size(lfp,2))'
        BLcor = lfp-BLmat
    else
        BLcor = lfp
    end

    # pad the matrix for the filtering process (tapered padding):
    padd_size = Int.(floor(hamm_width/2)+1)
    paddtaper = ones(padd_size,size(BLcor,2)) .* Int.(padd_size:-1:1)
    paddmatT  = repeat((BLcor[1,:])',padd_size) - (paddtaper .*
                 repeat(diff(BLcor[1:2,:],dims=1),padd_size))
    paddmatB  = repeat((BLcor[end,:])',padd_size) + (reverse(paddtaper,dims=1) .*
                 repeat(diff(BLcor[end-1:end,:],dims=1),padd_size))
    paddmat   = vcat(paddmatT, BLcor, paddmatB)

    # create your hamming filter matrix
    hammmat = repeat(hamming(hamm_width), outer = [1,size(paddmat,2)])
    # filter your input (note the loss of half the filter width on both top and bottom)
    hamm = [mean(paddmat[i+1-padd_size:i-padd_size+hamm_width,:] .* hammmat, dims=1)
            for i = (padd_size:(size(paddmat,1)-padd_size+1))]

    # calculate the csd by second order difference of hamm along the 1st dimension
    # divided by sampling distance squared = final unit in V/mm^2
    csdpre1 = diff(hamm,dims=1)
    csdpre2 = ((-diff(csdpre1,dims=1))/(chan_dist^2))*10^3

    csd = ones(size(lfp,1),size(lfp,2))
    for i = 1:size(lfp,1)
        csd[i,:] = csdpre2[i]
    end

    if shiftback == true
        # shift dimensions back
        csd = permutedims(csd, [2,1])
    end

    return csd

end
