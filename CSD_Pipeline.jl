### Set up
using Statistics
using DSP
using Plots
using MAT
using DataFrames
using Colors

# get to correct directory and label it home
home = @__DIR__
raw = joinpath(home,"raw")
func = joinpath(home,"functions")
figs = joinpath(home,"figs")

include(joinpath(func,"DynamicCSDjl.jl"))
include(joinpath(func,"SingleTrialCSD.jl"))
include(joinpath(func,"get_csd.jl")) # used in SingleTrialCSD.jl
include(joinpath(func,"sink_dura.jl"))
include(joinpath(func,"functions.jl"))

# determine data to read -- this will be a more complicated process later!
# groups, animal, condition, measurement
Group = "KIT"
measurement = "KIT02_0017.mat"
channels = Int64[29 13 27 11 25  9 32 16 28  1 30 14 23  2 26 12 21  3 24 10]
LII = [1:4...] # or collect(1:4)
LIV = [5:11...]
LV  = [12:15...]
LVI = [16:20...]

csdData,snkData = Dynamic_CSD(measurement,channels,LII,LIV,LV,LVI,raw,figs,Group)
