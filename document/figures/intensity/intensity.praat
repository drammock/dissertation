form Make resynth figure
	sentence segDonorWav NWM05_33-05.wav
	sentence segDonorTG NWM05_33-05.TextGrid
	sentence proDonorWav NWM02_33-05.wav
	sentence proDonorTG NWM02_33-05.TextGrid
	sentence resynthWav NWM52_33-05.wav
	sentence figureFilename intensity.eps
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

offset = 0.00000000001 ; used in the duration tier to prevent points from coinciding
# offset to avoid preceding textgrid interval from printing
#segStart = segStart + 0.000001
#proStart = proStart + 0.000001

x1 = 0.25
x2 = 6.25
y1 = 0.25
y2 = 2.25
y1wav = 0.25
y2wav = 1.75
y1int = 0.25
y2int = 0.75
y1int2 = 1.25
y2int2 = 1.75

offsetB = 2.25
offsetC = 4.5

Erase all

# PANEL 1
Select inner viewport... x1 x2 y1 y2
	Grey
	Solid line
	select segTextGrid
	Draw... 0 0 no no no

Select inner viewport... x1 x2 y1wav y2wav
	Black
	Solid line
	select segSound
	Draw... 0 0 -0.5 0.5 no Curve

Select inner viewport... x1 x2 y1int y2int
	Blue
	Solid line
	select segSound
	segIntensity = To Intensity... 60 0 yes
	Draw... 0 0 40 80 no

	Grey
	Dotted line
	select segIntensity
	segIntensityMax = Get maximum... 0 0 Parabolic
	select segSound
	tMin = Get start time
	tMax = Get end time
	Draw line... tMin segIntensityMax tMax segIntensityMax

Select inner viewport... x1 x1+0.5 y1 y1+0.5
	Black
	Solid line
	Axes... 0 1 0 1
	Text special... 0 centre 0.5 half Times 18 0  a)


Select inner viewport... x1 x2 y1int2 y2int2
	Red
	Dotted line
	select segIntensity
	segInverse = Formula... segIntensityMax-self
	Draw... 0 0 0 40 no


# PANEL 2
Select inner viewport... x1 x2 y1wav+offsetB+0.25 y2wav+offsetB+0.25
	Black
	Solid line
	segIntensityInverse = Down to IntensityTier
	plus segSound
	segSoundInverse = Multiply... yes
	Draw... 0 0 -0.5 0.5 no Curve

Select inner viewport... x1 x2 y1int+offsetB y2int+offsetB
	Purple
	Solid line
	select segSoundInverse
	segIntensityFlat = To Intensity... 60 0 yes
	Draw... 0 0 40 80 no

Select inner viewport... x1 x1+0.5 y1+offsetB y1+0.5+offsetB
	Black
	Axes... 0 1 0 1
	Text special... 0 centre 0.5 half Times 18 0  b)

# # # # # # # # # # # # # #
# do the dynamic warping  #
# # # # # # # # # # # # # #

		# MAKE SURE THEY HAVE THE SAME NUMBER OF INTERVALS
		select segTextGrid
		segInt = Get number of intervals... seg_donor_tier
		select proTextGrid
		proInt = Get number of intervals... pro_donor_tier
		if segInt <> proInt
			exit The two TextGrids do not have the same number of intervals.
		endif

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
			# GET DURATION OF INTERVALS
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

			# CREATE DURATION TIER POINTS FOR CURRENT INTERVAL IN TARGET OBJECT
		#	select segDurationTier
		#	Add point... segIntStart+offset proSegRatio
		#	Add point... segIntEnd proSegRatio

			# DO THE SAME FOR THE PROSODY DONOR IN CASE SWAP=TRUE, OR IF REPLACING PITCH W/O DURATION, ETC
		#	select proDurationTier
		#	Add point... proIntStart+offset segProRatio
		#	Add point... proIntEnd segProRatio

			# WARP TIME DOMAIN OF PITCH AND INTENSITY VALUES AND STORE IN (PREVIOUSLY EMPTY) COLUMN 3 OF THE TABLES.
			select segIntensityTable
			Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] <= segIntEnd then proIntStart + (self[row,1] - segIntStart) * proSegRatio else self fi
			select proIntensityTable
			Formula... if col = 3 and self[row,1] > proIntStart and self[row,1] <= proIntEnd then segIntStart + (self[row,1] - proIntStart) * segProRatio else self fi
		endfor

		select segSound
		segDur = Get total duration
		segProIntensityWarped = Create IntensityTier... proIntensityWarped 0 'segDur'

		select proIntensityTable
		proIntensityRows = Get number of rows
		for r to proIntensityRows
			select proIntensityTable
			t = Get value... r 3
			v = Get value... r 2
			select segProIntensityWarped
			Add point... t v
		endfor

		# MULTIPLY FLATTENED TARGET SOUND BY THE TARGET INTENSITY
		select segSoundInverse
		plus segProIntensityWarped
		segSoundProIntensity = Multiply... yes
		Scale intensity... proIntensityRMS

# END WARPING

# PANEL 3
Select inner viewport... x1 x2 y1wav+offsetC y2wav+offsetC
	Black
	Solid line
	select segSoundProIntensity
	Draw... 0 0 -0.5 0.5 no Curve

Select inner viewport... x1 x2 y1int+offsetC y2int+offsetC
	Blue
	Solid line
	select segSoundProIntensity
	finalIntensity = To Intensity... 60 0 yes
	Draw... 0 0 40 80 no


Select inner viewport... x1 x1+0.5 y1+offsetC y1+0.5+offsetC
	Black
	Axes... 0 1 0 1
	Text special... 0 centre 0.5 half Times 18 0  c)



Select inner viewport... x1 x2 y1 y2+offsetC
Save as EPS file... 'figureFilename$'

#select seg
#plus segTG
#plus pro
#plus proTG
#Remove
