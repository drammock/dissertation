# COLLECT ALL THE USER INPUT
form Create syllable tier using intensity
	sentence Sound_directory /home/dan/Desktop/dissertation/stimuli/dissTalkers/
	sentence TextGrid_output_directory /home/dan/Desktop/dissertation/stimuli/textgrids_intensity/
#	sentence Subset_list /home/dan/Desktop/dissertation/stimuli/CorrectedSentenceNumbers.txt
#	sentence Talker_list /home/dan/Desktop/dissertation/stimuli/talkers.txt
	sentence Sound_extension .wav
	integer textgrid_tier 1
	comment Set window length:
	real Zoom_duration 0
	comment You can pick up where you left off if you like:
	integer startingFileNum 61
	boolean prepopulateMinima 1
	boolean prepopulateMaxima 0
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'sound_directory$'
snDir$ = "'cleanPath.out$'"
# call cleanPath 'textGrid_source_directory$'
# tgSrcDir$ = "'cleanPath.out$'"
call cleanPath 'textGrid_output_directory$'
tgOutDir$ = "'cleanPath.out$'"
call cleanExtn 'sound_extension$'
snExt$ = "'cleanExtn.out$'"
# call cleanExtn 'textGrid_extension$'
# tgExt$ = "'cleanExtn.out$'"


# MAKE A LIST OF ALL SOUND FILES IN THE DIRECTORY
Create Strings as file list... soundFiles 'snDir$'*'snExt$'
fileList = selected("Strings")
fileCount = Get number of strings

# # READ IN THE LIST OF USABLE SENTENCES
# Read Table from tab-separated file... 'subset_list$'
# sentList$ = selected$("Table", 1)

# # READ IN THE LIST OF USABLE TALKERS
# Read Table from tab-separated file... 'talker_list$'
# talkList$ = selected$("Table", 1)

# BOOLEAN FOR SETTING SETTINGS
firstFile = 1

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

# 	# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
	select Strings soundFiles
	soundfile$ = Get string... curFile
# # 	curSent$ = mid$(soundfile$,7,5)
# # 	select Table 'sentList$'
# # 	rowNum = Search column... sent 'curSent$'
# # 	if rowNum<>0
# 	curTalk$ = left$(soundfile$,5)
# 	select Table 'talkList$'
# 	rowNum = Search column... talker 'curTalk$'
# 	if rowNum<>0

		# READ IN THE SOUND, CREATE TEXTGRID
		Read from file... 'snDir$''soundfile$'
		totalDur = Get total duration
		curName$ = selected$ ("Sound", 1)
		To Intensity... 80 0 yes
		timeStep = Get time step
		numFrames = Get number of frames
		select Sound 'curName$'
		To TextGrid... intensyl
		Insert boundary... 1 0.05
		Insert boundary... 1 totalDur-0.05

		# PREPOPULATE TEXTGRID WITH INTENSITY MINIMA / MAXIMA
		if prepopulateMinima = 1 or prepopulateMaxima = 1
			for fr from 2 to numFrames-1
				select Intensity 'curName$'
				a = Get value in frame... fr-1
				b = Get value in frame... fr
				c = Get value in frame... fr+1
				localExtremum = -1
				if prepopulateMaxima = 1 and b > a and b > c
					localExtremum = Get time from frame number... fr
				elif prepopulateMinima = 1 and b < a and b < c
					localExtremum = Get time from frame number... fr
				endif
				if localExtremum > 0
					select Sound 'curName$'
					localZero = Get nearest zero crossing... 1 'localExtremum'
					if abs(localExtremum - localZero) < 0.01
						localExtremum = localZero
					endif
					select TextGrid 'curName$'
					Insert boundary... 1 'localExtremum'
				endif
			endfor
		endif

		#OPEN THE PAIR OF FILES IN THE EDITOR AND ZOOM IN
		echo 'curFile'
		select Sound 'curName$'
		plus TextGrid 'curName$'
		View & Edit
		editor TextGrid 'curName$'
			if firstFile = 1
				# SHOW ONLY SOUND FILE AND INTENSITY (spectro formant intens pitch pulse longestAnalysis)
				Show analyses... no no yes no no 5
				firstFile = 0
			endif
			if zoom_duration = 0
				Show all
			else
				Zoom... 0 zoom_duration
			endif

			# START US OFF IN INTERVAL #2 (THE FIRST ONE AFTER THE INITIAL 50ms SILENCE PADDING)
			Move cursor to... 0.04
			Select next interval

			# SHOW A U.I. FOR FINDING LOCAL INTENSITY MAXIMA AND MINIMA
			repeat
				beginPause ("Correct boundaries")
					comment ("Delete boundaries as necessary.")
					comment ("Put cursor near peak/trough before using FindMin/FindMax buttons.")
					comment ("When modifications are complete, click Save.")
				clicked = endPause ("FindMin", "FindMax", "Save", 1)
				pt = Get cursor
				if clicked < 3
					endeditor
					select Intensity 'curName$'
					if clicked = 1
						localExtremum = Get time of minimum... 'pt'-0.05 'pt'+0.05 Parabolic
					elif clicked = 2
						localExtremum = Get time of maximum... 'pt'-0.05 'pt'+0.05 Parabolic
					endif
					editor TextGrid 'curName$'
						Move cursor to... 'localExtremum'
						Move cursor to nearest zero crossing
						localZero = Get cursor
						if abs(localExtremum-localZero) < 0.01
							localExtremum = localZero
						endif
					endeditor
					select TextGrid 'curName$'
					Insert boundary... 1 'localExtremum'
					editor TextGrid 'curName$'
				endif
			until clicked = 3

			if clicked = 3
				Save TextGrid as text file... 'tgOutDir$''curName$'.TextGrid
			endif
		endeditor

		# REMOVE THE OBJECTS FOR THAT FILE AND GO ON TO THE NEXT ONE
		select Sound 'curName$'
		plus TextGrid 'curName$'
		plus Intensity 'curName$'
		Remove
		select Strings soundFiles
# 	endif
endfor

# REMOVE THE STRINGS LIST
select Strings soundFiles
# plus Table 'talkList$'
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
