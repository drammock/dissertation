form Make resynth figure
	sentence segDonorWav NWM02_08-02.wav
	sentence segDonorTG NWM02_08-02.TextGrid
	sentence proDonorWav NWM07_08-02.wav
	sentence proDonorTG NWM07_08-02.TextGrid
	sentence resynthWav NWM57_08-02.wav
	sentence figureFilename intensity.eps
	real segStart 0
	real segEnd 0
	real proStart 0
	real proEnd 0
endform

segOrig = Read from file... 'segDonorWav$'
segTextGrid = Read from file... 'segDonorTG$'
proOrig = Read from file... 'proDonorWav$'
proTextGrid = Read from file... 'proDonorTG$'
resynthOrig = Read from file... 'resynthWav$'

seg_donor_tier = 1
pro_donor_tier = 1

offset = 0.00000000001 ; used in the duration tier to prevent points from coinciding
# offset to avoid preceding textgrid interval from printing
#segStart = segStart + 0.000001
#proStart = proStart + 0.000001

# EQUALIZE DURATIONS FOR DISPLAY BY ADDING SILENCE TO SHORTER SOUND
select proOrig
proStart = Get start time
proEnd = Get end time
proDur = Get total duration
select segOrig
segStart = Get start time
segEnd = Get end time
segDur = Get total duration
diff = segDur - proDur
silentBit = Create Sound from formula... foo 1 0 abs(diff) 44100 0

if segDur < proDur
	select segOrig
	plus silentBit
	segSound = Concatenate
	proSound = proOrig
	resynth = resynthOrig
else
	select proOrig
	plus silentBit
	proSound = Concatenate
	select resynthOrig
	plus silentBit
	resynth = Concatenate
	segSound = segOrig
endif


x1 = 0
x2 = 6.5
y1 = 0
y2 = 2.25
y1int = 0
y2int = 1.5
y1wav = 0.1
y2wav = 2.1
y1inv = 0.5
y2inv = 2

offsetB = 1.5
offsetC = 3
offsetD = 4.5
offsetE = 6

Erase all

# SUBFIGURE LETTER
Select outer viewport... x1 x2 y1 y2
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.5 left y2 top Times 16 0  a)

Select outer viewport... x1 x2 y1+offsetB y2+offsetB
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.5 left y2 top Times 16 0  b)

Select outer viewport... x1 x2 y1+offsetC y2+offsetC
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.5 left y2 top Times 16 0  c)

Select outer viewport... x1 x2 y1+offsetD y2+offsetD
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.5 left y2 top Times 16 0  d)

Select outer viewport... x1 x2 y1+offsetE y2+offsetE
	Black
	Solid line
	Axes... x1 x2 y1 y2
	Text special... -0.5 left y2 top Times 16 0  e)


## TEXTGRID
#Select outer viewport... x1 x2 y1+0.5 y2
#	Grey
#	Solid line
#	select segTextGrid
#	Draw... 0 0 no no no


# WAVEFORM
Select outer viewport... x1 x2 y1wav y2wav
	Black
	Solid line
	select segSound
	Draw... 0 0 -0.6 0.6 no Curve

# UPPER INTENSITY
Select outer viewport... x1 x2 y1int y2int
	Blue
	Solid line
	select segSound
	segIntensity = To Intensity... 60 0 yes
	Draw... 0 0 20 80 no
#	Marks right... 2 yes yes no
#	Text right... yes Intensity (dB)

# WAVEFORM B
Select outer viewport... x1 x2 y1wav+offsetB y2wav+offsetB
	Black
	Solid line
	select segIntensity
	segIntensityMax = Get maximum... 0 0 Parabolic
	segInverseIntensity = Formula... segIntensityMax-self
	segInverseIntensityTier = Down to IntensityTier
	plus segSound
	segInverseSound = Multiply... yes
	Draw... 0 0 -0.6 0.6 no Curve

# LOWER INTENSITY
#Select outer viewport... x1 x2 y1inv y2inv
#	Red
#	Dotted line
#	select segInverse
#	Draw... segStart segEnd 0 60 no

# UPPER INTENSITY B
Select outer viewport... x1 x2 y1int+offsetB y2int+offsetB
	Blue
	Dashed line
	select segInverseSound
	segFlatIntensity = To Intensity... 60 0 yes
	Draw... 0 0 20 80 no
#	Marks right... 2 yes yes no
#	Text right... yes Intensity (dB)



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
		select segInverseSound
		plus segProIntensityWarped
		segSoundProIntensity = Multiply... yes
		Scale intensity... proIntensityRMS

# # # # # # # #
# END WARPING #
# # # # # # # #

# WAVEFORM C
Select outer viewport... x1 x2 y1wav+offsetC y2wav+offsetC
	Black
	Solid line
	select segSoundProIntensity
	Draw... 0 0 -0.6 0.6 no Curve

# UPPER INT C
Select outer viewport... x1 x2 y1int+offsetC y2int+offsetC
	Purple
	Dashed line
	select segSoundProIntensity
	finalIntensity = To Intensity... 60 0 yes
	Draw... 0 0 20 80 no

# WAVEFORM C
Select outer viewport... x1 x2 y1wav+offsetD y2wav+offsetD
	Black
	Solid line
	select resynth
	Draw... 0 0 -0.6 0.6 no Curve

# UPPER INT D
Select outer viewport... x1 x2 y1int+offsetD y2int+offsetD
	Purple
	Solid line
	select resynth
	resynthIntensity = To Intensity... 60 0 yes
	Draw... 0 0 20 80 no

# WAVEFORM E
Select outer viewport... x1 x2 y1wav+offsetE y2wav+offsetE
	Black
	Solid line
	select proSound
	Draw... 0 0 -0.6 0.6 no Curve

# UPPER INT E
Select outer viewport... x1 x2 y1int+offsetE y2int+offsetE
	Red
	Solid line
	select proIntensity
	Draw... 0 0 20 80 no
#	Marks right... 2 yes yes no
#	Text right... yes Intensity (dB)





Select outer viewport... x1 x2 y1 y2+offsetE
Save as EPS file... 'figureFilename$'

select resynthOrig
plus segOrig
plus proOrig
plus resynth
plus segSound
plus proSound
plus silentBit
plus segTextGrid
plus proTextGrid

plus segIntensity
plus segInverseIntensity
plus segInverseIntensityTier
plus segInverseSound
plus segFlatIntensity
plus segIntensityTier
plus segIntensityTable

plus proIntensity
plus proIntensityTier
plus proIntensityTable

plus segProIntensityWarped
plus segSoundProIntensity
plus finalIntensity
plus resynthIntensity
Remove
