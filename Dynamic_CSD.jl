### Set up
using Statistics
using DSP
using Plots
using MAT
using DataFrames

# get to correct directory and label it home
home = @__DIR__
raw = joinpath(home,"raw")
func = joinpath(home,"functions")

include(joinpath(func,"SingleTrialCSD.jl"))
include(joinpath(func,"get_csd.jl")) # used in SingleTrialCSD.jl
include(joinpath(func,"sink_dura.jl"))

# determine data to read -- this will be a more complicated process later!
# groups, animal, condition, measurement
measurement = "KIT02_0017.mat"
channels = Int64[29 13 27 11 25  9 32 16 28  1 30 14 23  2 26 12 21  3 24 10]
LII = [1:4...] # or collect(1:4)
LIV = [5:11...]
LV  = [12:15...]
LVI = [16:20...]
### Load data and take basic features

# load specified converted data in from raw folder
Dat = matread(joinpath(raw,measurement))

# the Baseline is the time before the tone * the sampling frequency
BL = Int64(Dat["Header"]["t_pre"] * Dat["P"]["Fs_AD"][1])
# tone duration is the time of the signal * the sampling frequency
tone = Int64(Dat["Header"]["t_sig"][1] * Dat["P"]["Fs_AD"][1])
# frequency stim list contains all frequencies presented during this measurement
frqz = Dat["Header"]["stimlist"][:,1]

### Calculate CSD, LFP, Avrec, Relres, Absrec:

Data = SingleTrialCSD(Dat["SWEEP"], channels, BL)
# note that avgAVREC is full csd average rectified, while AvgRectCSD is the average
# of the csd rectified over channels (trialwise mean(abs(csd)) vs abs(csd))

### Calculate sink features in layers

sink_dura()



#
# plotly()
# heatmap(csd, c=:bgyw, yflip = true)
# heatmap(csd, c=:bmw, yflip = true)
# heatmap(matlab_csd, c=:kdc, yflip = true)
