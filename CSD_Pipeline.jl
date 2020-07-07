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

CondName = ["Pre" "CL"]
# generate lists of channels, layers, and measurements for each animal in this group
animalList,chanList,LIIList,LIVList,LVList,LVIList,CondList = callGroup(Group) # in groups folder

# loop through each animal (dictionary per animal)
for iAn = 1:length(animalList)
    # loop through each type of measurement condition (specified by CondName)
    for iCond = 1:length(CondName)
        # loop through each measurement within that condition for that animal
        for iMeas = 1:length(CondList[CondName[iCond]][iAn])

            #to test!
            # iAn, iCond, iMeas = 1, 1, 1
            channels = chanList[iAn]
            LII  = LIIList[iAn]
            LIV  = LIVList[iAn]
            LV   = LVList[iAn]
            LVI  = LVIList[iAn]
            # #
            measurement = animalList[iAn] * "_" * CondList[CondName[iCond]][iAn][iMeas] * ".mat"
            println("Analyzing measurement: " * measurement[1:end-4])

            csdData,snkData = Dynamic_CSD(measurement,channels,LII,LIV,
                LV,LVI,raw,figs,Group)

        end
    end
end
