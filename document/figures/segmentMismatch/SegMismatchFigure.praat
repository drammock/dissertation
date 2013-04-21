form Make resynth figure
	sentence segDonorWav ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/06-05_NWM07_06-05.wav
	sentence segDonorTG ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/06-05_NWM07_06-05.TextGrid
	sentence proDonorWav ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/06-05_NWM02_06-05.wav
	sentence proDonorTG ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/06-05_NWM02_06-05.TextGrid
	sentence resynthWav ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/NWM72_06-05.wav
	sentence figureFilename ~/Documents/academics/research/dissertation/document/figures/segmentMismatch/segmentMismatch.eps
#	positive segStart 1.3912925170068027
	positive segStart 1.041888650196921
	real segEnd 1.9237868480725624
#	positive proStart 1.85
	positive proStart 1.451686507936508
	real proEnd 2.3827210884353742
endform

seg = Read from file... 'segDonorWav$'
segTG = Read from file... 'segDonorTG$'
pro = Read from file... 'proDonorWav$'
proTG = Read from file... 'proDonorTG$'
resynth = Read from file... 'resynthWav$'

x1 = 0.25
x2 = 6.25
y1 = 0.25
y2 = 2.25
y1int = 0
y2int = 1.25
y1wav = 0.5
y2wav = 2

offsetB = 2.25
offsetC = 4.5

# EXTRACT PARTS
select seg
segDur = Get total duration
if segEnd <= 0
	segEnd = segDur
endif
seg2 = Extract part... segStart segEnd rectangular 1 no
select segTG
segTG2 = Extract part... segStart segEnd no
segName$ = selected$("TextGrid")

select pro
proDur = Get total duration
if proEnd <= 0
	proEnd = proDur
endif
pro2 = Extract part... proStart proEnd rectangular 1 no
select proTG
proTG2 = Extract part... proStart proEnd no
proName$ = selected$("TextGrid")

# EQUALIZE DURATIONS BY ADDING SILENCE TO SHORTER SOUND
select pro2
proDur2 = Get total duration
select seg2
segDur2 = Get total duration
diff = abs(segDur2 - proDur2)
silentBit = Create Sound from formula... foo 1 0 diff 44100 0
silentTG = To TextGrid... foo

if segDur2 < proDur2
	select seg2
	plus silentBit
	seg3 = Concatenate
	select segTG2
	plus silentTG
	segTG3 = Concatenate
	segName$ = selected$("TextGrid")
	select seg3
	plus segTG3
else
	select pro2
	plus silentBit
	pro3 = Concatenate
	select proTG2
	plus silentTG
	proTG3 = Concatenate
	proName$ = selected$("TextGrid")
	select seg2
	plus segTG2
endif

View & Edit
Erase all

# # # # #
# PART A #
# # # # #

Grey
# Select inner viewport... 0.25 6.25 0.25 2.25
Select inner viewport... x1 x2 y1 y2
	editor TextGrid 'segName$'
		Draw visible TextGrid... no no no no no
	endeditor

Blue
Dashed line
# Select inner viewport... 0.25 6.25 0.25 1.5
Select inner viewport... x1 x2 y1int y2int
	editor TextGrid 'segName$'
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
# Select inner viewport... 0.25 6.25 0.5 2
Select inner viewport... x1 x2 y1wav y2wav
	editor TextGrid 'segName$'
		Draw visible sound... no yes -0.5 0.5 no no no no
		Close
	endeditor

Red
Draw arrow... 0.61 -0.3 0.61 -0.1

Black
Select inner viewport... x1 x1+0.5 y1 y1+0.5
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  a)

# # # # #
# PART B #
# # # # #

if segDur2 < proDur2
	select pro2
	plus proTG2
else
	select pro3
	plus proTG3
endif

View & Edit

Grey
Solid line
# Select inner viewport... 0.25 6.25 2.5 4.5
Select inner viewport... x1 x2 y1+offsetB y2+offsetB
	editor TextGrid 'proName$'
		Draw visible TextGrid... no no no no no
	endeditor

Blue
Dashed line
# Select inner viewport... 0.25 6.25 2.5 3.75
Select inner viewport... x1 x2 y1int+offsetB y2int+offsetB
	editor TextGrid 'proName$'
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
# Select inner viewport... 0.25 6.25 2.75 4
Select inner viewport... x1 x2 y1wav+offsetB y2wav+offsetB
	editor TextGrid 'proName$'
		Draw visible sound... no yes -0.5 0.5 no no no no
	endeditor

#Select inner viewport... 0.25 0.75 2.5 3
Select inner viewport... x1 x1+0.5 y1+offsetB y1+0.5+offsetB
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  b)

# # # # #
# PART C #
# # # # #

select resynth
resynth2 = Extract part... proStart proEnd rectangular 1 no
rsName$ = selected$("Sound")
View & Edit

Grey
Solid line
# Select inner viewport... 0.25 6.25 4.75 6.75
Select inner viewport... x1 x2 y1+offsetC y2+offsetC
	editor TextGrid 'proName$'
		Draw visible TextGrid... no no no no no
		Close
	endeditor

Blue
Dashed line
# Select inner viewport... 0.25 6.25 4.75 6
Select inner viewport... x1 x2 y1int+offsetC y2int+offsetC
	editor Sound 'rsName$'
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
# Select inner viewport... 0.25 6.25 5 6.25
Select inner viewport... x1 x2 y1wav+offsetC y2wav+offsetC
	editor Sound 'rsName$'
		Draw visible sound... no yes -0.5 0.5 no no no no
		Close
	endeditor

Red
Draw arrow... 0.662 -0.35 0.662 -0.15

Black
# Select inner viewport... 0.25 0.75 4.75 5.25
Select inner viewport... x1 x1+0.5 y1+offsetC y1+0.5+offsetC
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  c)

Select inner viewport... 0.25 6.25 0.25 6.75
Save as EPS file... 'figureFilename$'

select resynth
plus resynth2
plus silentBit
plus silentTG
plus seg
plus seg2
plus segTG
plus segTG2
plus pro
plus pro2
plus proTG
plus proTG2
if segDur2 < proDur2
	plus seg3
	plus segTG3
else
	plus pro3
	plus proTG3
endif
Remove