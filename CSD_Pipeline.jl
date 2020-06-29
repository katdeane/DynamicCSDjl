### Set up
using Statistics
using DSP
using Plots
using MAT
using DataFrames
using Colors

# get to correct directory and label it home
home    = @__DIR__
raw     = joinpath(home,"raw")
func    = joinpath(home,"functions")
figs    = joinpath(home,"figs")
group   = joinpath(home,"groups")

include(joinpath(func,"Dynamic_CSD.jl"))
include(joinpath(func,"SingleTrialCSD.jl"))
include(joinpath(func,"get_csd.jl")) # used in SingleTrialCSD.jl
include(joinpath(func,"sink_dura.jl"))
include(joinpath(func,"functions.jl"))
include(joinpath(group,"callGroup.jl"))

# determine data to read -- this will be a more complicated process later!
# groups, animal, condition, measurement
Group = "KIT"
#'Pre' 'preAM' 'preAMtono' 'preCL' 'preCLtono' 'spPre1' 'spPost1' 'CL' 'CLtono' 'spPre2' 'spPost2' 'AM' 'AMtono' 'spEnd'
CondName = ["Pre"]
animals,channels,LII,LIV,LV,LVI,Cond = callGroup(Group)
for iAn = 1:length(animals)
    for iCond = 1:length(CondName)
        for 
        csdData,snkData = Dynamic_CSD(measurement,channels[iAn],LII[iAn],LIV[iAn],
            LV[iAn],LVI[iAn],raw,figs,Group)
    end
end
