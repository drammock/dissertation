# # # # # # # # # # # # # # # # # # # # # # # #
# PRAAT SCRIPT "REPLACE PROSODY WITH PSOLA"
# This script semi-automates preparations for the replacement of prosody from one talker to another.  In particular, it opens all the sounds in a given folder (possibly matching against a textfile specifying a subset) and opens them as manipulation objects

, by finding the average duration of each word (based on TextGrid annotations) and the average pitch and loudness, and resynthesizes each sound file to have the same prosody.  Works best when the same sentence is read by the different talkers, and at minimum requires that the sentences have the same number of durational units (words, syllables, etc... i.e., the same number of intervals in the specified TextGrid tier).  This script borrows heavily from the script "cloneProsody" by YOON Kyuchul: 
# Yoon, K. (2007). Imposing native speakers’ prosody on non-native speakers’ utterances: The technique of cloning prosody. 현대영미어문학회 (The Journal of Modern British & American Language & Literature), 25(4), 197–215.
#
# To work well, you will need ACCURATE, HAND-CORRECTED pitch information about each file (PointProcess and PitchTier files)
#
# FORM INSTRUCTIONS
# 
# VERSION 0.1 (2012 08 16)
#
# CHANGELOG
#
# AUTHOR: DANIEL MCCLOY: (drmccloy@uw.edu)
# LICENSED UNDER THE GNU GENERAL PUBLIC LICENSE v3.0: http://www.gnu.org/licenses/gpl.html
# DEVELOPMENT OF THIS SCRIPT WAS FUNDED BY THE NATIONAL INSTITUTES OF HEALTH, GRANT # R01DC006014 TO PAMELA SOUZA
# # # # # # # # # # # # # # # # # # # # # # # #

# COLLECT ALL THE USER INPUT
form Neutralize Prosody: Select directories & starting parameters
	sentence Sound_directory /home/dan/Desktop/dissertation/stimuli/sounds/
	sentence TextGrid_directory /home/dan/Desktop/dissertation/stimuli/textgrids/
	sentence PointProcess_directory /home/dan/Desktop/dissertation/stimuli/pulse/ 
	sentence PitchTier_directory /home/dan/Desktop/dissertation/stimuli/pitch/
	sentence Subset_list /home/dan/Desktop/dissertation/stimuli/CorrectedSentenceNumbers.txt
	sentence logFile /home/dan/Desktop/dissertation/stimuli/NeutralizeProsody.log
	sentence Sound_extension .wav
	integer textgrid_tier 1
	integer startingFileNum 1
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'sound_directory$'
snDir$ = "'cleanPath.out$'"
call cleanPath 'textGrid_directory$'
tgDir$ = "'cleanPath.out$'"
call cleanPath 'pointProcess_directory$'
ppDir$ = "'cleanPath.out$'"
call cleanPath 'pitchTier_directory$'
ptDir$ = "'cleanPath.out$'"
call cleanExtn 'sound_extension$'
soundExt$ = "'cleanExtn.out$'"

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

# MAKE A LIST OF ALL SOUND FILES IN THE FOLDER
Create Strings as file list... list 'snDir$'*'soundExt$'
fileList = selected("Strings")
fileCount = Get number of strings

# READ IN THE LIST OF USABLE SENTENCES
Read Table from tab-separated file... 'subset_list$'
usableSents$ = selected$("Table", 1)

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

	# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
	select Strings list
	soundfile$ = Get string... curFile
	curSent$ = mid$(soundfile$,7,5)
	select Table 'usableSents$'
	rowNum = Search column... sent 'curSent$'
	if rowNum<>0

		# READ IN THE SOUND, POINTPROCESS, AND PITCHTIER
		Read from file... 'snDir$''soundfile$'
		curName$ = selected$ ("Sound", 1)
		Read from file... 'ppDir$''curName$'.PointProcess
		Read from file... 'ptDir$''curName$'.PitchTier
		
		# CREATE MANIPULATION OBJECT WITH DEFAULT SETTINGS
		select Sound 'curName$'
		To Manipulation... 0.01 75 600
		
		# SWAP IN THE HAND-CORRECTED POINTPROCESS AND PITCHTIER DATA
		select PointProcess 'curName$'
		plus Manipulation 'curName$'
		Replace pulses
		select PitchTier 'curName$'
		plus Manipulation 'curName$'
		Replace pitch tier
		
		select Sound 'curName$'
		totalDur = Get total duration
		select TextGrid 'curName$'
		numInt = Get number of intervals... textgrid_tier

# # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # #
# SCRIPT UNFINISHED, PROGRESS MARKER #
		select Manipulation 'curName$'
# # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # #


		# SHOW THE EDITOR WINDOW
		zoomStart = 0
		zoomEnd = totalDur
		select Sound 'filename$'
		View & Edit
		editor Sound 'filename$'
	
			# HIDE THE SPECTROGRAM & ANALYSES TO PREVENT ANNOYING FLICKERING
			Show analyses... no no no no no 10
			Zoom... zoomStart zoomEnd

			# SET ALL THE RELEVANT SETTINGS
			Spectrogram settings... 0 2500 0.025 50
			Advanced spectrogram settings... 1000 250 Fourier Gaussian yes 100 6 0
			if carryover = 0
				Pitch settings... defaultMinPitch defaultMaxPitch Hertz autocorrelation automatic
			else
				Pitch settings... minPitch maxPitch Hertz autocorrelation automatic
			endif
			Advanced pitch settings... viewRangeMin viewRangeMax no 15 0.03 0.45 0.01 jumpCost 0.14
		
			# DISPLAY NARROWBAND SPECTROGRAM AND PITCH (MAKING SURE "MAX ANALYSIS" IS LONG ENOUGH SO THE SPECTROGRAM ACTUALLY SHOWS UP)
			Show analyses... yes yes no no no totalDur+1
		endeditor

		# INITIALIZE SOME VARIABLES FOR THE PAUSE U.I.
		clicked = 1
		notes$ = ""
		if autoplay > 1
			firstview = 1
		else
			firstview = 0
		endif
		if carryover = 0 or maxPitch = 0  ;  THE maxPitch=0 CONDITION PREVENTS ERRORS WHEN carryover=1 AND THE PREV. FILE WAS SKIPPED
			minPitch = defaultMinPitch
			maxPitch = defaultMaxPitch
			jumpCost = defaultJumpCost
		endif

		# SHOW A U.I. WITH PITCH SETTINGS.  KEEP SHOWING IT UNTIL THE USER ACCEPTS OR CANCELS
		repeat
			beginPause ("Adjust pitch analysis settings")
				comment ("File 'filename$' (file number 'curFile' of 'fileCount')")
				comment ("You can change the pitch settings if the pitch track doesn't look right.")
				integer ("newMinPitch", minPitch)
				integer ("newMaxPitch", maxPitch)
				real ("newJumpCost", jumpCost)
				comment ("clicking RESET will reset minPitch and maxPitch to the default values and redraw;")
				comment ("Clicking REDRAW will redraw the pitch contour with the settings above;")
				comment ("clicking SKIP will write zeros to the log file and go to next file.")
				sentence ("Notes", notes$)
				# AUTOPLAY
				if autoplay = 3 or firstview = 1
					editor Sound 'filename$'
						Play... 0 totalDur
					endeditor
				endif
				firstview = 0
			clicked = endPause ("Play","Reset", "Redraw", "Accept", "Skip", 3)

			# IF THE USER CLICKS "PLAY"
			if clicked = 1
				editor Sound 'filename$'
					Play... 0 totalDur
				endeditor

			# IF THE USER CLICKS "RESET"
			elif clicked = 2
				minPitch = defaultMinPitch
				maxPitch = defaultMaxPitch
				jumpCost = defaultJumpCost

				# REDRAW THE PITCH CONTOUR
				editor Sound 'filename$'
					Pitch settings... minPitch maxPitch Hertz autocorrelation automatic
					Advanced pitch settings... viewRangeMin viewRangeMax no 15 0.03 0.45 0.01 jumpCost 0.14
				endeditor

			# IF THE USER CLICKS "REDRAW"
			elif clicked = 3
				minPitch = newMinPitch
				maxPitch = newMaxPitch
				jumpCost = newJumpCost

				# REDRAW THE PITCH CONTOUR
				editor Sound 'filename$'
					Pitch settings... minPitch maxPitch Hertz autocorrelation automatic
					Advanced pitch settings... viewRangeMin viewRangeMax no 15 0.03 0.45 0.01 jumpCost 0.14
				endeditor
			endif
		until clicked >3

		# IF THE USER SKIPS, WRITE OVERRIDE VALUES
		if clicked = 5
			minPitch = 0
			maxPitch = 0
			jumpCost = 0
		endif

		# CLEAN UP
		select Sound 'filename$'
		Remove

		# WRITE TO FILE
		resultline$ = "'curFile''tab$''filename$''tab$''totalDur''tab$''minPitch''tab$''maxPitch''tab$''jumpCost''tab$''notes$''newline$'"
		fileappend "'logFile$'" 'resultline$'
	endif
endfor

# REMOVE THE STRINGS LIST AND GIVE A SUCCESS MESSAGE
select Strings list
Remove
clearinfo
files_read = fileCount - startingFileNum + 1
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
	headerline$ = "number'tab$'filename'tab$'totalDuration'tab$'wordDurations'newline$'"
	fileappend "'logFile$'" 'headerline$'
endproc
