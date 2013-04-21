form Make resynth figure
	sentence segDonorWav NWM05_33-05.wav
	sentence segDonorTG NWM05_33-05.TextGrid
#	sentence proDonorWav NWM02_33-05.wav
#	sentence proDonorTG NWM02_33-05.TextGrid
#	sentence resynthWav NWM52_33-05.wav
	sentence manip NWM05_33-05.Manipulation
	sentence figureFilename creakJitterShimmer.eps
	positive segStart 1.410822410264919
	real segEnd 1.6402072562358276
	positive proStart 1.550969387755102
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
y2 = 2.25
y1int = 0.6
y2int = 1.85
y1wav = 0.35
y2wav = 1.85

offsetB = 2.25
offsetC = 4.5

Erase all

# FIGURE OUT WHICH IS LONGER, AND EXTEND THE SELECTION ON THE OTHER ONE TO MATCH
segDur = segEnd - segStart
proDur = proEnd - proStart

if proDur > segDur
	proEnd = proEnd - (proDur-segDur)
#	segEnd = segEnd + proDur - segDur
else
	proEnd = proEnd + segDur - proDur
endif


# # # # #
# PART A #
# # # # #

select seg
plus segTG
segName$ = selected$("TextGrid")
View & Edit

Grey
Solid line
Select inner viewport... x1 x2 y1 y2
	editor TextGrid 'segName$'
		Show analyses... no yes no no yes 10
		Pitch settings... 50 300 Hertz cross-correlation speckles
		Advanced pitch settings... 1 300 yes 15 0.03 0.45 0.01 0.35 0.14
		Zoom... segStart segEnd
		Draw visible TextGrid... no no no no no
	endeditor

Blue
# Dashed line
Select inner viewport... x1 x2 y1int y2int
	editor TextGrid 'segName$'
		Draw visible pitch contour... no no no no no no ; the second argument is "speckle"
	endeditor

# pulses
Red
Solid line
Select inner viewport... x1 x2 y1wav+0.4 y2wav-1
	editor TextGrid 'segName$'
		Draw visible pulses... no no no no no
	endeditor

Black
Select inner viewport... x1 x2 y1wav y2wav
	editor TextGrid 'segName$'
		Draw visible sound... no yes -0.5 0.5 no no no no
	endeditor


Red
Axes... x1 x2 y1wav y2wav
Draw arrow... 4.05 1.75 4.05 1.5

Black
Select inner viewport... x1 x1+0.5 y1 y1+0.5
Axes... 0 1 0 1
Text special... 0 centre 0.5 half Times 18 0  a)


# # # # #
# PART B #
# # # # #

Grey
Solid line
Select inner viewport... x1 x2 y1+offsetB y2+offsetB
	editor TextGrid 'segName$'
		Zoom... segStart segEnd
		Draw visible TextGrid... no no no no no
	endeditor

Blue
# Dashed line
Select inner viewport... x1 x2 y1int+offsetB y2int+offsetB
	select ptch
	Draw... segStart segEnd 0 300 no lines
#	editor TextGrid 'segName$'
#		Draw visible pitch contour... no no no no no no ; the second argument is "speckle"
#	endeditor

# pulses
Red
Solid line
Select inner viewport... x1 x2 y1wav+0.4+offsetB y2wav-1+offsetB
	select puls
	Draw... segStart segEnd no
#	editor TextGrid 'segName$'
#		Draw visible pulses... no no no no no
#	endeditor

Black
Select inner viewport... x1 x2 y1wav+offsetB y2wav+offsetB
	editor TextGrid 'segName$'
		Draw visible sound... no yes -0.5 0.5 no no no no
		Close
	endeditor


#Red
#Axes... x1 x2 y1wav+offsetB y2wav+offsetB
#Draw arrow... 4.05 1.75 4.05 1.5

Black
Select inner viewport... x1 x1+0.5 y1+offsetB y1+0.5+offsetB
Axes... 0 1 0 1
Text special... 0 centre 0.5 half Times 18 0  b)


# # # # #
# PART C #
# # # # #

#select resynth
#rsName$ = selected$("Sound")
#View & Edit

#Grey
#Solid line
#Select inner viewport... x1 x2 y1+offsetC y2+offsetC
#	editor TextGrid 'proName$'
#		Zoom... proStart proEnd
#		Draw visible TextGrid... no no no no no
#		Close
#	endeditor

#Blue
#Dashed line
#Select inner viewport... x1 x2 y1int+offsetC y2int+offsetC
#	editor Sound 'rsName$'
#		Draw visible pitch contour... no no no no no no
#	endeditor

#Black
#Solid line
#Select inner viewport... x1 x2 y1wav+offsetC y2wav+offsetC
#	editor Sound 'rsName$'
#		Draw visible sound... no yes -0.5 0.5 no no no no
#		Close
#	endeditor

#Red
#Draw arrow... 0.662 -0.35 0.662 -0.15

#Black
#Select inner viewport... x1 x1+0.5 y1+offsetC y1+0.5+offsetC
#Axes... 0 1 0 1
#Text special... 0 centre 0.5 half Times 18 0  c)

Select inner viewport... x1 x2 y1 y2+offsetB
Save as EPS file... 'figureFilename$'

select seg
plus segTG
#plus pro
#plus proTG
#plus resynth
plus manip
plus ptch
plus puls
Remove
