form Make resynth figure
	sentence segDonorWav NWM05_33-05.wav
	sentence segDonorTG NWM05_33-05.TextGrid
	sentence manip NWM05_33-05.Manipulation
	sentence figureFilename creakJitterShimmer.eps
	real segStart 1.410822410264919
	real segEnd 1.6402072562358276
	real proStart 1.550969387755102
	real proEnd 1.8329841465885104
endform

# offset to avoid preceding textgrid interval from printing
segStart = segStart + 0.000001
proStart = proStart + 0.000001

seg = Read from file... 'segDonorWav$'
segTG = Read from file... 'segDonorTG$'
#pro = Read from file... 'proDonorWav$'
#proTG = Read from file... 'proDonorTG$'
#resynth = Read from file... 'resynthWav$'
manip = Read from file... 'manip$'

select manip
puls = Extract pulses
select manip
ptch = Extract pitch tier

x1 = 0.25
x2 = 6.25
y1 = 0.25
y2 = 2
y1pulse = 0.25
y2pulse = 0.4
y1wav = 0.5
y2wav = 1.25
y1int = 1.2
y2int = 1.8

offsetB = 2
offsetC = 4.5

# FIGURE OUT WHICH IS LONGER, AND EXTEND THE SELECTION ON THE OTHER ONE TO MATCH
segDur = segEnd - segStart
proDur = proEnd - proStart

if proDur > segDur
	proEnd = proEnd - (proDur-segDur)
#	segEnd = segEnd + proDur - segDur
else
	proEnd = proEnd + segDur - proDur
endif


# START DRAWING
Erase all

# SUBFIGURE LETTER
Select inner viewport... x1 x2 y1 y2
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.25 left 2.25 top Times 16 0  a)

Select inner viewport... x1 x2 y1+offsetB y2+offsetB
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.25 left 2 top Times 16 0  b)


# TEXTGRID
Select inner viewport... x1 x2 y1+1 y2
	Colour... 0.4
	Solid line
	select segTG
	Draw... segStart segEnd no no no

Select inner viewport... x1 x2 y1+1+offsetB y2+offsetB
	Grey
	Solid line
	select segTG
	Draw... segStart segEnd no no no
	Marks bottom... 2 yes yes no
	Text bottom... yes Time (seconds)


# PITCH TRACK
Select inner viewport... x1 x2 y1int y2int
	Blue
	Dashed line
	select seg
	segPitch = To Pitch (cc)... 0 50 15 yes 0.03 0.45 0.01 0.35 0.14 300
	Draw... segStart segEnd 40 140 no
	Marks right... 2 yes yes no
	Text right... yes %f_0 (Hz)

Select inner viewport... x1 x2 y1int+offsetB y2int+offsetB
	Blue
	Dashed line
	select ptch
	Draw... segStart segEnd 40 140 no lines
	Marks right... 2 yes yes no
	Text right... yes %f_0 (Hz)


# PULSES
Select inner viewport... x1 x2 y1pulse+0.2 y2pulse+0.2
	Red
	Solid line
	select seg
	segPulse = To PointProcess (periodic, cc)... 50 300
	Draw... segStart segEnd no

	# ARROW
	Red
	Axes... x1 x2 y2pulse y1pulse
	Draw arrow... 3.94 y2pulse-y1pulse-0.25 3.94 y2pulse-y1pulse+0.05

Select inner viewport... x1 x2 y1pulse+offsetB+0.1 y2pulse+offsetB+0.1
	Red
	Solid line
	select puls
	Draw... segStart segEnd no


# WAVEFORM
Select inner viewport... x1 x2 y1wav y2wav
	Black
	Solid line
	select seg
	Draw... segStart segEnd -0.2 0.2 no Curve
#	Marks right... 3 yes yes no

Select inner viewport... x1 x2 y1wav+offsetB y2wav+offsetB
	Black
	Solid line
	select seg
	Draw... segStart segEnd -0.2 0.2 no Curve
#	Marks right... 3 yes yes no


Select inner viewport... x1 x2 y1 y2+offsetB
Save as EPS file... 'figureFilename$'

select seg
plus segTG
plus segPitch
plus segPulse
plus manip
plus ptch
plus puls
Remove
