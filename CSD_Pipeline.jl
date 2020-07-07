### Set up
using Statistics
using DSP
using Plots
using MAT
using DataFrames
using Colors
using JLD

# get to correct directory and label it home
home    = @__DIR__
raw     = joinpath(home,"raw")
func    = joinpath(home,"functions")
figs    = joinpath(home,"figs")
group   = joinpath(home,"groups")
datap   = joinpath(home,"Data")

include(joinpath(func,"Dynamic_CSD.jl"))
include(joinpath(func,"SingleTrialCSD.jl"))
include(joinpath(func,"get_csd.jl")) # used in SingleTrialCSD.jl
include(joinpath(func,"sink_dura.jl"))
include(joinpath(func,"functions.jl"))
include(joinpath(group,"callGroup.jl"))

# determine data to read -- this will be a more complicated process later!
Group = ["KIC" "KIT" "KIV"]
#"Pre" "preAM" "preAMtono" "preCL" "preCLtono" "spPre1" "spPost1" "CL" "CLtono" "spPre2" "spPost2" "AM" "AMtono" "spEnd"
CondName = ["Pre" "CL"]

# loop through groups
for iGr = 1:length(Group)
    # generate lists of channels, layers, and measurements for each animal in this group
    animalList,chanList,LIIList,LIVList,LVList,LVIList,CondList = callGroup(Group[iGr]) # in groups folder

    # loop through each animal (dictionary per animal)
    Animal = Dict()
    for iAn = 1:length(animalList)

        AnimalName = animalList[iAn]

        # loop through each type of measurement condition (specified by CondName)
        Condition = Dict()
        for iCond = 1:length(CondName)
            # loop through each measurement within that condition for that animal
            Measurement = Dict()
            for iMeas = 1:length(CondList[CondName[iCond]][iAn])

                channels = chanList[iAn]
                LII  = LIIList[iAn]
                LIV  = LIVList[iAn]
                LV   = LVList[iAn]
                LVI  = LVIList[iAn]

                measurement = AnimalName * "_" * CondList[CondName[iCond]][iAn][iMeas] * ".mat"
                println("Analyzing measurement: " * measurement[1:end-4])

                csdData,snkData = Dynamic_CSD(measurement,channels,LII,LIV,
                    LV,LVI,raw,figs,Group);

                Measurement[CondList[CondName[iCond]][iAn][iMeas]] = csdData,snkData;
            end
            Condition[CondName[iCond]] = Measurement
        end
        Animal[AnimalName] = Condition
        name = joinpath(datap,AnimalName) * "_Data.jld"
        save(name, Animal[AnimalName])
    end
end

# to load: Data  = load("D:\\Julia\\DynamicCSDjl\\Data\\KIT05_Data.jld")