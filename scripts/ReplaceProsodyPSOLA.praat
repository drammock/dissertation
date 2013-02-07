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
	sentence Segmental_donor /home/dan/Desktop/tmpManip1/
	sentence Seg_donor_textgrid /home/dan/Desktop/tmpTG/
	integer Seg_donor_tier 1
	sentence Prosodic_donor /home/dan/Desktop/tmpManip2/
	sentence Pros_donor_textgrid /home/dan/Desktop/tmpTG/
	integer Pros_donor_tier 1
# 	sentence Subset_list /home/dan/Desktop/dissertation/stimuli/CorrectedSentenceNumbers.txt
	sentence output_directory /home/dan/Desktop/tmpOutput
	sentence logFile /home/dan/Desktop/ReplaceProsody.log
# 	boolean swap 0
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'segmental_donor$'
segMan$ = "'cleanPath.out$'"
call cleanPath 'seg_donor_textgrid$'
segTG$ = "'cleanPath.out$'"
call cleanPath 'prosodic_donor$'
prosMan$ = "'cleanPath.out$'"
call cleanPath 'pros_donor_textgrid$'
prosTG$ = "'cleanPath.out$'"
call cleanPath 'output_directory$'
outDir$ = "'cleanPath.out$'"
# call cleanExtn 'sound_extension$'
# soundExt$ = "'cleanExtn.out$'"

# INITIATE THE OUTPUT FILE
if fileReadable (logFile$)
	beginPause ("The log file already exists!")
		comment ("The log file already exists!")
		comment ("You can overwrite the existing file, or append new data to the end of it.")
	overwrite_setting = endPause ("Append", "Overwrite", 1)
	if overwrite_setting = 2
		filedelete 'logFile$'
		call initializeOutfile
	endif
else
	# THERE IS NOTHING TO OVERWRITE, SO CREATE THE HEADER ROW FOR THE NEW OUTPUT FILE
	call initializeOutfile
endif

# MAKE A LIST OF SEGEMENTAL DONOR FILES AND PROSODIC DONOR FILES
Create Strings as file list... segFiles 'segMan$'*.Manipulation
segList = selected("Strings")
segCount = Get number of strings
Create Strings as file list... prosFiles 'prosMan$'*.Manipulation
prosList = selected("Strings")
# prosCount = Get number of strings

# READ IN THE LIST OF USABLE SENTENCES
# Read Table from tab-separated file... 'subset_list$'
# usableSents$ = selected$("Table", 1)

# LOOP THROUGH THE LIST OF FILES...
for curFileNum to segCount

	# MAKE SURE THE SENTENCE NUMBERS MATCH BETWEEN THE TWO MANIPULATION OBJECT FILE NAMES
	select Strings segFiles
	curSegFile$ = Get string... curFileNum
	curSegSent$ = mid$(curSegFile$,7,5)
	select Strings prosFiles
	curProsFile$ = Get string... curFileNum
	curProsSent$ = mid$(curProsFile$,7,5)
	# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
	# select Table 'usableSents$'
	# rowNum = Search column... sent 'curSent$'
	# if rowNum <> 0
	if curSegSent$ = curProsSent$

		# READ IN THE MANIPULATION OBJECTS
		Read from file... 'segMan$''curSegFile$'
		curSegFileObj$ = selected$ ("Manipulation", 1)
		Read from file... 'prosMan$''curProsFile$'
		curProsFileObj$ = selected$ ("Manipulation", 1)

		# READ IN THE TEXTGRIDS
		Read from file... 'segTG$''curSegFileObj'.TextGrid
		Read from file... 'segTG$''curProsFileObj'.TextGrid

		# MAKE SURE THEY HAVE THE SAME NUMBER OF INTERVALS
		select TextGrid 'curSegFileObj$'
		segInt = Get number of intervals... seg_donor_tier
		select TextGrid 'curProsFileObj$'
		prosInt = Get number of intervals... pros_donor_tier
		if segInt = prosInt

			# EXTRACT PITCH TIERS
			select Manipulation 'curSegFileObj$'
			Extract pitch tier
			segPitchPts = Get number of points
			Down to TableOfReal... Hertz
			Rename... segPitchTable
			select Manipulation 'curProsFileObj$'
			Extract pitch tier
			prosPitchPts = Get number of points
			Down to TableOfReal... Hertz
			Rename... prosPitchTable

			# EXTRACT INTENSITY TIERS
			select Manipulation 'curSegFileObj$'
			Extract original sound
			segRMS = Get intensity (dB)
			To Intensity... 60 0 yes
			Down to IntensityTier
# 			segIntensPts = Get number of points
			Down to TableOfReal
			Rename... segIntensTable

			select Manipulation 'curProsFileObj$'
			Extract original sound
# 			prosRMS = Get intensity (dB)
			To Intensity... 60 0 yes
# 			prosMax = Get maximum... 0 0 Parabolic
			Down to IntensityTier
# 			prosIntensPts = Get number of points
			Down to TableOfReal
			Rename... prosIntensTable

			# EXTRACT (EMPTY) DURATION TIERS
			select Manipulation 'curSegFileObj$'
			Extract duration tier
			select Manipulation 'curProsFileObj$'
			Extract duration tier

			# GET DURATION RATIO OF EACH INTERVAL AND ADD POINTS TO DURATION TIERS
			for intNum to segInt
				# GET DURATION OF TARGET INTERVAL
				select TextGrid 'curSegFileObj$'
				segIntStart = Get start point... seg_donor_tier intNum
				segIntEnd = Get end point... seg_donor_tier intNum
				segIntDur = segIntEnd - segIntStart
				segIntStartPt = segIntStartPt + 0.00000000001

				# GET DURATION OF PROSODIC DONOR INTERVAL
				select TextGrid 'curProsFileObj$'
				prosIntStart = Get start point... pros_donor_tier intNum
				prosIntEnd = Get end point... pros_donor_tier intNum
				prosIntDur = prosIntEnd - prosIntStart
				prosIntStartPt = prosIntStartPt + 0.00000000001

				# CALCULATE RATIOS
				prosSegRatio = prosIntDur / segIntDur
				segProsRatio = segIntDur / prosIntDur

				# CREATE DURATION TIER POINTS FOR CURRENT INTERVAL IN TARGET OBJECT
				select DurationTier 'curSegFileObj$'
				Add point... segIntStartPt prosSegRatio
				Add point... segIntEnd prosSegRatio

				# DO THE SAME FOR THE PROSODY DONOR MANIPULATION OBJECT...
				# ...IN CASE WE WANT A FULL SWAP, OR JUST REPLACE PITCH W/O DURATION, ETC
				select DurationTier 'curProsFileObj$'
				Add point... prosIntStartPt segProsRatio
				Add point... prosIntEnd segProsRatio

				# WARP TIME DOMAIN OF PITCH TIER VALUES
				select TableOfReal segPitchTable
				Insert column (index)... 3
				Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] < segIntEnd then self[row,1] * prosSegRatio else self fi
				select TableOfReal prosPitchTable
				Insert column (index)... 3
				Formula... if col = 3 and self[row,1] > prosIntStart and self[row,1] < prosIntEnd then self[row,1] * segProsRatio else self fi

				# WARP TIME DOMAIN OF INTENSITY TIER VALUES
				select TableOfReal segIntensTable
				Insert column (index)... 3
				Formula... if col = 3 and self[row,1] > segIntStart and self[row,1] < segIntEnd then self[row,1] * prosSegRatio else self fi
				select TableOfReal prosIntensTable
				Insert column (index)... 3
				Formula... if col = 3 and self[row,1] > prosIntStart and self[row,1] < prosIntEnd then self[row,1] * segProsRatio else self fi
			endfor

			# CREATE NEW PITCH AND INTENSITY TIERS WITH WARPED TIME DOMAINS
			select Sound 'curSegFileObj$'
			segDur = Get total duration
			Create pitch tier... prosPitchWarped 0 segDur
			Create intensity tier... prosIntensWarped 0 segDur
			select TableOfReal prosPitchTable
			prosPitchRows = Get number of rows
			for row in prosPitchRows
				select TableOfReal prosPitchTable
				t = Get value... row 3
				v = Get value... row 2
				select PitchTier prosPitchWarped
				Add point... t v
			endfor
			select TableOfReal prosIntensTable
			prosIntensRows = Get number of rows
			for row in prosIntensRows
				select TableOfReal prosIntensTable
				t = Get value... row 3
				v = Get value... row 2
				select IntensityTier prosIntensWarped
				Add point... t v
			endfor
# 			select Sound 'curProsFileObj$'
# 			prosDur = Get total duration
# 			Create pitch tier... segPitchWarped 0 prosDur
# 			Create intensity tier... segIntensWarped 0 prosDur
# 			select TableOfReal segPitchTable
# 			segPitchRows = Get number of rows
# 			for row in segPitchRows
# 				select TableOfReal segPitchTable
# 				t = Get value... row 3
# 				v = Get value... row 2
# 				select PitchTier segPitchWarped
# 				Add point... t v
# 			endfor
# 			select TableOfReal segIntensTable
# 			segIntensRows = Get number of rows
# 			for row in segIntensRows
# 				select TableOfReal segIntensTable
# 				t = Get value... row 3
# 				v = Get value... row 2
# 				select IntensityTier segIntensWarped
# 				Add point... t v
# 			endfor

			# MULTIPLY TARGET SOUND BY ITS INTENSITY INVERSE, THEN BY THE TARGET INTENSITY
			select Intensity 'curSegFileObj$'
			segMax = Get maximum... 0 0 Parabolic
			Formula... 'segMax' - self
			Down to IntensityTier
			Rename... segIntensityInverse
			select Sound 'curSegFileObj$'
			plus IntensityTier segIntensityInverse
			Multiply... no
			Rename... segSoundInverse
			plus IntensityTier prosIntensWarped
			Multiply... no
			Rename... segSoundProsIntens
# 			select Intensity 'curProsFileObj$'
# 			prosMax = Get maximum... 0 0 Parabolic
# 			Formula... 'prosMax' - self
# 			Down to IntensityTier
# 			Rename... prosIntensityInverse
# 			select Sound 'curProsFileObj$'
# 			plus IntensityTier prosIntensityInverse
# 			Multiply... no
# 			Rename... prosSoundInverse
# 			plus IntensityTier segIntensWarped
# 			Multiply... no
# 			Rename... prosSoundSegIntens

			# ASSEMBLE FINAL MANIPULATION OBJECTS
			select Manipulation 'curSegFileObj$'
			plus Sound segSoundProsIntens
			Replace original sound

			select Manipulation 'curSegFileObj$'
			plus PitchTier prosPitchWarped
			Replace pitch tier

			select Manipulation 'curSegFileObj$'
			plus DurationTier 'curSegFileObj$'
			Replace duration tier

			select Manipulation 'curSegFileObj$'
			Get resynthesis (overlap-add)
# 			Rename... "'curSegFileObj$'_'curProsFileObj$'"
			Save as WAV file... 'outDir$''curSegFileObj$'_'curProsFileObj$'.wav

			# CLEAN UP
			Remove
			select Manipulation 'curSegFileObj$'
			plus TableOfReal prosPitchTable





# # # # #
# # # # #
# PROGRESS MARKER
# # # # #
# # # # #



    else
      exit ERROR: The number of intervals in the specified TextGrid tiers are not the same.
    endif

    # WRITE TO LOG FILE
#    resultline$ = "'jumpCost''tab$''notes$''newline$'"
#    fileappend "'logFile$'" 'resultline$'

  else; curSegSent$ <> curProsSent$
    # write to the log file the fact that the sentence numbers mismatch? or just fail?
  endif
endfor

# REMOVE THE STRINGS LIST AND GIVE A SUCCESS MESSAGE
select Strings segFiles
plus Strings prosFiles
Remove
clearinfo
files_read = segCount
printline Done! 'files_read' files read.'newline$'

# FUNCTIONS (A.K.A. PROCEDURES) THAT WERE CALLED EARLIER
procedure cleanPath .in$
  if not right$(.in$, 1) = "/"
    .out$ = "'.in$'" + "/"
  else
    .out$ = "'.in$'"
  endif
endproc

procedure cleanExtn .in$
  if not left$(.in$, 1) = "."
    .out$ = "." + "'.in$'"
  else
    .out$ = "'.in$'"
  endif
endproc

procedure initializeOutfile
  headerline$ = "totalDuration'tab$'wordDurations'newline$'"
  fileappend "'logFile$'" 'headerline$'
endproc
