form Make resynth figure
	sentence segDonorWav NWM02_08-02.wav
	sentence segDonorTG NWM02_08-02.TextGrid
	sentence proDonorWav NWM07_08-02.wav
	sentence proDonorTG NWM07_08-02.TextGrid
	sentence resynthWav NWM57_08-02.wav
	sentence figureFilename intensity2.eps
	real segStart 0
	real segEnd 0
	real proStart 0
	real proEnd 0
endform

segSound = Read from file... 'segDonorWav$'
segTextGrid = Read from file... 'segDonorTG$'
proSound = Read from file... 'proDonorWav$'
proTextGrid = Read from file... 'proDonorTG$'
resynth = Read from file... 'resynthWav$'

seg_donor_tier = 1
pro_donor_tier = 1

# GET DURATION RATIO SO ALL WAVS DRAW TO SAME TIME SCALE
select proSound
proDur = Get total duration
select segSound
segDur = Get total duration
dratio = proDur/segDur

# MAKE SURE SAME NUMBER OF INTERVALS (FOR DYNAMIC TIME WARPING)
select segTextGrid
segInt = Get number of intervals... seg_donor_tier
select proTextGrid
proInt = Get number of intervals... pro_donor_tier
if segInt <> proInt
	exit The two TextGrids do not have the same number of intervals.
endif

# CREATE NECESSARY OBJECTS
select segSound
segIntensity = To Intensity... 60 0 yes
segIntensityMax = Get maximum... 0 0 Parabolic
Copy... segInverseIntensity
segInverseIntensity = Formula... segIntensityMax-self
segInverseIntensityTier = Down to IntensityTier
plus segSound
segInverseSound = Multiply... yes
# segFlatIntensity = To Intensity... 60 0 yes

select segIntensity
segIntensityTier = Down to IntensityTier
segIntensityTable = Down to TableOfReal
Insert column (index)... 3

select proSound
proIntensityRMS = Get intensity (dB)
proIntensity = To Intensity... 60 0 yes
proIntensityTier = Down to IntensityTier
proIntensityTable = Down to TableOfReal
Insert column (index)... 3

for intNum to segInt
	# GET DURATION RATIOS OF EACH INTERVAL
	select segTextGrid
	segIntStart = Get start point... seg_donor_tier intNum
	segIntEnd = Get end point... seg_donor_tier intNum
	segIntDur = segIntEnd - segIntStart
	select proTextGrid
	proIntStart = Get start point... pro_donor_tier intNum
	proIntEnd = Get end point... pro_donor_tier intNum
	proIntDur = proIntEnd - proIntStart
	proSegRatio = proIntDur / segIntDur
	segProRatio = segIntDur / proIntDur
	# WARP TIME DOMAIN OF INTENSITY VALUES AND STORE IN (PREVIOUSLY EMPTY) COLUMN 3 OF THE TABLES.
	select segIntensityTable
	Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] <= segIntEnd then proIntStart + (self[row,1] - segIntStart) * proSegRatio else self fi
	select proIntensityTable
	Formula... if col = 3 and self[row,1] > proIntStart and self[row,1] <= proIntEnd then segIntStart + (self[row,1] - proIntStart) * segProRatio else self fi
endfor

# CREATE INTENSITY TIER OF PRO VALUES WARPED TO SEG TIMESCALE
select segSound
warpedIntensityTier = Create IntensityTier... warpedIntensityTier 0 'segDur'
select proIntensityTable
proIntensityRows = Get number of rows
for r to proIntensityRows
	select proIntensityTable
	t = Get value... r 3
	v = Get value... r 2
	select warpedIntensityTier
	Add point... t v
endfor
noise = Create Sound from formula... noise 1 0 'segDur' 44100 randomGauss(0,0.1)
plus warpedIntensityTier
modulatedNoise = Multiply... yes
warpedIntensity = To Intensity... 60 0 yes

# MULTIPLY FLATTENED SEG SOUND BY THE PRO INTENSITY
select segInverseSound
# segReplacedSound = Copy... segReplacedSound
plus warpedIntensityTier
segReplacedSound = Multiply... yes
Scale intensity... proIntensityRMS


# SET SOME GLOBAL DRAWING VARIABLES
outerL = 0.3
outerR = 6.4
outerT = 0.1
outerB = 6.5
colwidth = 2.3
wavheight = 1.2
intheight = 0.8
gap = 0.8
wavmin = -0.6
wavmax = 0.6

# INITIAL DRAWING SETTINGS
Erase all
Palatino
Font size... 10
Solid line

# BIG ARROWS
Select inner viewport... outerL outerR outerT outerB
	Silver
	Line width... 4
	Axes... outerL outerR outerT outerB
#	Draw arc... -1.7 3.75 4.8 342 22
#	Draw arrow... -1.7+4.8*cos(pi/10) 3.75-4.8*sin(pi/10) -1.7+4.8*cos(pi/10)-0.05 3.75-4.8*sin(pi/10)-0.05/tan(pi/10)
	Draw arc... -2.4 3.2 5.5 0 27
	Draw arc... 1.9 3.2 1.2 300 0
	Draw arrow... 1.9+1.2*cos(pi/3) 3.2-1.2*sin(pi/3) 1.9+1.2*cos(pi/3)-0.5 3.2-1.2*sin(pi/3)-0.5/tan(pi/3)

	Draw arc... 4.7 -0.5 2.7 90 135
	Draw arc... 4.7 1.9 0.3 0 90
	Draw arrow... 5 1.9 5 1.65
	Line width... 1

# LEFT COLUMN

# SEG WAVEFORM
Select inner viewport... outerL outerL+colwidth outerT outerT+wavheight
	Colour... {0,0,0.5}
	Solid line
	select segSound
	Draw... 0 0 wavmin wavmax no Curve

#	Axes... 0 colwidth 0 wavheight
#	Text special... 0-outerL left wavheight top Palatino 16 0 b)

# ARROW
Select inner viewport... outerL outerL+colwidth outerT+wavheight-0.5 outerT+wavheight+gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 0
	Line width... 1
	Black
	Text special... -0.1 left 0.5 half Palatino 12 0 ##a) extract target intensity contour#

# SEG INTENSITY
Select inner viewport... outerL outerL+colwidth outerT+wavheight+gap-0.5 outerT+wavheight+intheight+gap-0.5
	Colour... {0,0,0.5}
	Solid line
	select segIntensity
	Draw... 0 0 20 80 no

	Marks left... 2 yes no no
	Text left... no dB
	Black
	Solid line
	Draw line... 0 20 0 80
	Draw line... 0 20 segDur 20

#	Axes... 0 colwidth 0 wavheight
#	Text special... 0-outerL left wavheight top Palatino 16 0 b)

# ARROW
Select inner viewport... outerL outerL+colwidth outerT+wavheight+intheight+gap-0.5 outerT+wavheight+intheight+2*gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 0
	Line width... 1
	Black
	Text special... -0.1 left 0.5 half Palatino 12 0 ##b) subtract from max. intensity (invert)#


# SEG INTENSITY INVERTED
Select inner viewport... outerL outerL+colwidth outerT+wavheight+intheight+2*gap-0.5 outerT+wavheight+2*intheight+2*gap-0.5
	Colour... {0,0,0.5}
	Dashed line
	select segInverseIntensity
	Draw... 0 0 0 60 no

	Marks left... 2 yes no no
	Text left... no dB
	Black
	Solid line
	Draw line... 0 0 0 60
	Draw line... 0 0 segDur 0

#	Axes... 0 colwidth 0 wavheight
#	Text special... 0-outerL left wavheight top Palatino 16 0 c)

# ARROW
Select inner viewport... outerL outerL+colwidth outerT+wavheight+2*intheight+2*gap-0.5 outerT+wavheight+2*intheight+3*gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 0
	Line width... 1
	Black
	Text special... -0.1 left 0.5 half Palatino 12 0 ##c) apply inverted intensity contour (flatten)#


# SEG SOUND INVERTED
Select inner viewport... outerL outerL+colwidth outerT+wavheight+2*intheight+3*gap-0.5 outerT+2*wavheight+2*intheight+3*gap-0.5
	Colour... {0,0,0.5}
	Solid line
	select segInverseSound
	Draw... 0 0 wavmin wavmax no Curve



# RIGHT COLUMN

# PRO WAVEFORM
Select inner viewport... outerR-colwidth outerR-colwidth*(1-dratio) outerT outerT+wavheight
	Colour... {0.5,0,0}
	Solid line
	select proSound
	Draw... 0 0 wavmin wavmax no Curve

# ARROW
Select inner viewport... outerR-colwidth outerR outerT+wavheight-0.5 outerT+wavheight+gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 0
	Line width... 1
	Black
	Text special... -0.1 left 0.5 half Palatino 12 0 ##d) extract donor intensity contour#


# PRO INTENSITY
Select inner viewport... outerR-colwidth outerR-colwidth*(1-dratio) outerT+wavheight+gap-0.5 outerT+wavheight+intheight+gap-0.5
	Colour... {0.5,0,0}
	Solid line
	select proIntensity
	Draw... 0 0 20 80 no

	Marks left... 2 yes no no
	Text left... no dB
	Black
	Solid line
	Draw line... 0 20 0 80
	Draw line... 0 20 proDur 20

# ARROW
Select inner viewport... outerR-colwidth outerR outerT+wavheight+intheight+gap-0.5 outerT+wavheight+intheight+2*gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 0
	Line width... 1
	Black
	Text special... -0.1 left 0.5 half Palatino 12 0 ##e) time-scale donor intensity (\s{DTW})#


# PRO INTENSITY WARPED
Select inner viewport... outerR-colwidth outerR outerT+wavheight+intheight+2*gap-0.5 outerT+wavheight+2*intheight+2*gap-0.5
	Colour... {0.5,0,0}
	Dashed line
	select warpedIntensity
	Draw... 0 0 20 80 no

	Marks left... 2 yes no no
	Text left... no dB
	Black
	Solid line
	Draw line... 0 20 0 80
	Draw line... 0 20 segDur 20

# ARROW
Select inner viewport... outerR-colwidth outerR outerT+wavheight+2*intheight+2*gap-0.5 outerT+wavheight+2*intheight+3*gap-0.5
	Silver
	Line width... 4
	Axes... 0 1 0 1
	Draw arrow... 0.5 0.8 0.5 -0.2
	Line width... 1
	Black
	Text special... -0.1 left 0.25 half Palatino 12 0 ##f) apply warped intensity contour#


# SEG SOUND PRO INTENSITY
Select inner viewport... outerR-colwidth outerR outerT+wavheight+2*intheight+3*gap-0.5 outerT+2*wavheight+2*intheight+3*gap-0.5
	Colour... {0.25,0,0.25}
	Solid line
	select segReplacedSound
	Draw... 0 0 wavmin wavmax no Curve


#Select inner viewport... outerL outerR-0.25 outerT+0.25 outerB-0.75
Select outer viewport... 0 6.5 0 6
Save as EPS file... 'figureFilename$'

# CLEAN UP
select resynth
plus segSound
plus proSound
plus segTextGrid
plus proTextGrid

plus segIntensity
plus segInverseIntensity
plus segInverseIntensityTier
plus segInverseSound
plus segIntensityTier
plus segIntensityTable

plus proIntensity
plus proIntensityTier
plus proIntensityTable

plus warpedIntensityTier
plus warpedIntensity
plus noise
plus modulatedNoise
plus segReplacedSound
Remove
