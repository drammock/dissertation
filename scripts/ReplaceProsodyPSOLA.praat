# # # # # # # # # # # # # # # # # # # # # # # #
# PRAAT SCRIPT "REPLACE PROSODY WITH PSOLA"
# This script automates the replacement of prosody from one talker to another.  In particular, it takes as arguments two folders of manipulation objects (with embedded sound files) and folders of corresponding textgrid files, maps the prosody from the second set onto the first, and outputs a new manipulation object and sound file.  Works best for the same sentence read by different talkers, and at minimum requires that the textgrids have the same number of durational units (at least in the tier specified).  To work well, you will need ACCURATE, HAND-CORRECTED pitch information in the manipulation objects (both the pulses and pitch tiers).  This script borrows heavily from the script "cloneProsody" by YOON Kyuchul:
# Yoon, K. (2007). Imposing native speakers’ prosody on non-native speakers’ utterances: The technique of cloning prosody. 현대영미어문학회 [The Journal of Modern British & American Language & Literature], 25(4), 197–215.
#
# FORM INSTRUCTIONS
#
# VERSION 0.1 (2013 02 05)
#
# CHANGELOG
#
# AUTHOR: DANIEL MCCLOY: (drmccloy@uw.edu)
# LICENSED UNDER THE GNU GENERAL PUBLIC LICENSE v3.0: http://www.gnu.org/licenses/gpl.html
# DEVELOPMENT OF THIS SCRIPT WAS FUNDED BY THE NATIONAL INSTITUTES OF HEALTH, GRANT # R01DC006014 TO PAMELA SOUZA
# # # # # # # # # # # # # # # # # # # # # # # #

# COLLECT ALL THE USER INPUT
form Neutralize Prosody: Select directories & starting parameters
	sentence Segmental_donor ../stimuli/manipulationObjects/NWM02_01-07.Manipulation
	sentence Seg_donor_textgrid ../stimuli/textgrids_intensity_renamed/NWM02_01-07.TextGrid
	integer Seg_donor_tier 1
	sentence Prosodic_donor ../stimuli/manipulationObjects/NWM07_01-07.Manipulation
	sentence Pro_donor_textgrid ../stimuli/textgrids_intensity_renamed/NWM07_01-07.TextGrid
	integer Pro_donor_tier 1
	sentence output_directory ../stimuli/resynthesizedFiles/
#	sentence logFile ~/Desktop/ReplaceProsodyPSOLA.log
#	boolean Replace_pitch 1
#	boolean Replace_duration 1
#	boolean Replace_intensity 1
#	boolean swap 0
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'output_directory$'
outDir$ = "'cleanPath.out$'"

# INITIATE THE LOG FILE
# if fileReadable (logFile$)
# 	beginPause ("The log file already exists!")
# 		comment ("The log file already exists!")
# 		comment ("You can overwrite the existing file, or append new data to the end of it.")
# 	overwrite_setting = endPause ("Append", "Overwrite", 1)
# 	if overwrite_setting = 2
# 		filedelete 'logFile$'
# 		call initializeOutfile
# 	endif
# else
# 	# THERE IS NOTHING TO OVERWRITE, SO CREATE THE HEADER ROW FOR THE NEW OUTPUT FILE
# 	call initializeOutfile
# endif

# INITIALIZE SOME GLOBAL VALUES
offset = 0.00000000001 ; used in the duration tier to prevent points from coinciding


# SLICE OFF THE BASENAMES OF THE DONOR FILES
# (HACK - SPECIFIC TO MY FILE NAMING CONVENTION)
tmp$ = right$(segmental_donor$,24)
segDonorFilename$ = left$(tmp$,11)
tmp$ = right$(prosodic_donor$,24)
proDonorFilename$ = left$(tmp$,11)


# READ IN ALL THE FILES
segManip = Read from file... 'segmental_donor$'
segTextGrid = Read from file... 'Seg_donor_textgrid$'
proManip = Read from file... 'prosodic_donor$'
proTextGrid = Read from file... 'pro_donor_textgrid$'

# MAKE SURE THEY HAVE THE SAME NUMBER OF INTERVALS
select segTextGrid
segInt = Get number of intervals... seg_donor_tier
select proTextGrid
proInt = Get number of intervals... pro_donor_tier
if segInt <> proInt
	exit The two TextGrids do not have the same number of intervals.
endif

# EXTRACT PITCH TIERS AND SOME PITCH INFO TO BE USED LATER
select segManip
segPitch = Extract pitch tier
segPitchMean = Get mean (curve)... 0 0
segPitchPts = Get number of points
segPitchTable = Down to TableOfReal... Hertz
Insert column (index)... 3

select proManip
proPitch = Extract pitch tier
proPitchMean = Get mean (curve)... 0 0
proPitchPts = Get number of points
proPitchTable = Down to TableOfReal... Hertz
Insert column (index)... 3

pitchDiff = segPitchMean - proPitchMean


# EXTRACT INTENSITY TIERS AND SOME INTENSITY INFO TO BE USED LATER
select segManip
segSound = Extract original sound
segIntensityRMS = Get intensity (dB)
segIntensity = To Intensity... 60 0 yes
segIntensityMax = Get maximum... 0 0 Parabolic
segIntensityTier = Down to IntensityTier
segIntensityTable = Down to TableOfReal
Insert column (index)... 3

select proManip
proSound = Extract original sound
proIntensityRMS = Get intensity (dB)
proIntensity = To Intensity... 60 0 yes
proIntensityMax = Get maximum... 0 0 Parabolic
proIntensityTier = Down to IntensityTier
proIntensityTable = Down to TableOfReal
Insert column (index)... 3


# EXTRACT (EMPTY) DURATION TIERS
select segManip
segDurationTier = Extract duration tier
select proManip
proDurationTier = Extract duration tier


# STEP THROUGH EACH INTERVAL IN THE TEXTGRIDS
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
	select segDurationTier
	Add point... segIntStart+offset proSegRatio
	Add point... segIntEnd proSegRatio

	# DO THE SAME FOR THE PROSODY DONOR IN CASE SWAP=TRUE, OR IF REPLACING PITCH W/O DURATION, ETC
	select proDurationTier
	Add point... proIntStart+offset segProRatio
	Add point... proIntEnd segProRatio


	# WARP TIME DOMAIN OF PITCH AND INTENSITY VALUES AND STORE IN (PREVIOUSLY EMPTY) COLUMN 3 OF THE TABLES.
	select segPitchTable
	Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] <= segIntEnd then proIntStart + (self[row,1] - segIntStart) * proSegRatio else self fi
	select proPitchTable
	Formula... if col = 3 and self[row,1] > proIntStart and self[row,1] <= proIntEnd then segIntStart + (self[row,1] - proIntStart) * segProRatio else self fi
	select segIntensityTable
	Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] <= segIntEnd then proIntStart + (self[row,1] - segIntStart) * proSegRatio else self fi
	select proIntensityTable
	Formula... if col = 3 and self[row,1] > proIntStart and self[row,1] <= proIntEnd then segIntStart + (self[row,1] - proIntStart) * segProRatio else self fi

# DONE STEPPING THROUGH EACH INTERVAL OF THE TEXTGRIDS
endfor


# CREATE NEW PITCH AND INTENSITY TIERS WITH WARPED TIME DOMAINS
select segSound
segDur = Get total duration
segProPitchWarped = Create PitchTier... proPitchWarped 0 'segDur'
segProIntensityWarped = Create IntensityTier... proIntensityWarped 0 'segDur'

select proPitchTable
proPitchRows = Get number of rows
for r to proPitchRows
	select proPitchTable
	t = Get value... r 3
	v = Get value... r 2
	select segProPitchWarped
	Add point... t v
endfor
Shift frequencies... 0 'segDur' 'pitchDiff' Hertz

select proIntensityTable
proIntensityRows = Get number of rows
for r to proIntensityRows
	select proIntensityTable
	t = Get value... r 3
	v = Get value... r 2
	select segProIntensityWarped
	Add point... t v
endfor


# MULTIPLY TARGET SOUND BY ITS INTENSITY INVERSE, THEN BY THE TARGET INTENSITY
select segIntensity
Formula... 'segIntensityMax' - self
segIntensityInverse = Down to IntensityTier

select segSound
plus segIntensityInverse
segSoundInverse = Multiply... yes

select segSoundInverse
plus segProIntensityWarped
segSoundProIntensity = Multiply... yes
Scale intensity... proIntensityRMS


# ASSEMBLE FINAL MANIPULATION OBJECT
select segManip
plus segSoundProIntensity
Replace original sound

select segManip
plus segProPitchWarped
Replace pitch tier

select segManip
plus segDurationTier
Replace duration tier

select segManip
Save as binary file... 'outDir$''segDonorFilename$'_'proDonorFilename$'.Manipulation
segProResynth = Get resynthesis (overlap-add)
Save as WAV file... 'outDir$''segDonorFilename$'_'proDonorFilename$'.wav


# CLEAN UP
select segManip
plus segTextGrid
plus segPitch
plus segPitchTable
plus segSound
plus segIntensity
plus segIntensityTier
plus segIntensityTable
plus segDurationTier
plus segProPitchWarped
plus segProIntensityWarped
plus segIntensityInverse
plus segSoundInverse
plus segSoundProIntensity
plus segProResynth
Remove

select proManip
plus proTextGrid
plus proPitch
plus proPitchTable
plus proSound
plus proIntensity
plus proIntensityTier
plus proIntensityTable
plus proDurationTier
# plus proSegPitchWarped
# plus proSegIntensityWarped
# plus proIntensityInverse
# plus proSoundInverse
# plus proSoundProIntensity
# plus proSegResynth
Remove


# FUNCTIONS (A.K.A. PROCEDURES) THAT WERE CALLED EARLIER
procedure cleanPath .in$
  if not right$(.in$, 1) = "/"
    .out$ = "'.in$'" + "/"
  else
    .out$ = "'.in$'"
  endif
endproc
