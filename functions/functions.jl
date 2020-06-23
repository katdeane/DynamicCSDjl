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
