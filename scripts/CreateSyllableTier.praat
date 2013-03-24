# COLLECT ALL THE USER INPUT
form Hand-correcting TextGrids: choose directories
	sentence Sound_directory /home/dan/Desktop/dissertation/stimuli/allSounds/
	sentence TextGrid_source_directory /home/dan/Desktop/dissertation/stimuli/allTextgrids/
	sentence TextGrid_output_directory /home/dan/Desktop/dissertation/stimuli/textgrids_syllable/
	sentence Subset_list /home/dan/Desktop/dissertation/stimuli/CorrectedSentenceNumbers.txt
	sentence Talker_list /home/dan/Desktop/dissertation/stimuli/talkers.txt
	sentence Sound_extension .wav
	integer textgrid_tier 1
	comment Set window length:
	real Zoom_duration 0
	comment You can pick up where you left off if you like:
	integer startingFileNum 1
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'sound_directory$'
snDir$ = "'cleanPath.out$'"
call cleanPath 'textGrid_source_directory$'
tgSrcDir$ = "'cleanPath.out$'"
call cleanPath 'textGrid_output_directory$'
tgOutDir$ = "'cleanPath.out$'"
call cleanExtn 'sound_extension$'
snExt$ = "'cleanExtn.out$'"
# call cleanExtn 'textGrid_extension$'
# tgExt$ = "'cleanExtn.out$'"


# MAKE A LIST OF ALL SOUND FILES IN THE DIRECTORY
Create Strings as file list... list 'snDir$'*'snExt$'
fileList = selected("Strings")
fileCount = Get number of strings

# READ IN THE LIST OF USABLE SENTENCES
#Read Table from tab-separated file... 'subset_list$'
#sentList$ = selected$("Table", 1)

# READ IN THE LIST OF USABLE TALKERS
Read Table from tab-separated file... 'talker_list$'
talkList$ = selected$("Table", 1)

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

	# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
	select Strings list
	soundfile$ = Get string... curFile
#	curSent$ = mid$(soundfile$,7,5)
#	select Table 'sentList$'
#	rowNum = Search column... sent 'curSent$'
#	if rowNum<>0
	curTalk$ = left$(soundfile$,5)
	select Table 'talkList$'
	rowNum = Search column... talker 'curTalk$'
	if rowNum<>0

		# READ IN THE SOUND, AND TEXTGRID
		Read from file... 'snDir$''soundfile$'
		curName$ = selected$ ("Sound", 1)
		Read from file... 'tgSrcDir$''curName$'.TextGrid
		echo 'curFile'

		# OPEN THE PAIR OF FILES IN THE EDITOR AND ZOOM IN
		select TextGrid 'curName$'
		Duplicate tier... 2 1 syll
		numIntervals = Get number of intervals... 1
		for curInterval from 1 to numIntervals
			Set interval text... 1 curInterval
		endfor
		plus Sound 'curName$'
		View & Edit
		editor TextGrid 'curName$'
			if zoom_duration = 0
				Show all
			else
				Zoom... 0 zoom_duration
			endif

			#SHOW A U.I. WITH A SAVE BUTTON FOR THE TEXT GRID
			beginPause ("Modify text grid")
				comment ("When modifications are complete, click save")
			clicked = endPause ("Save", 1)
			if clicked = 1
				Save TextGrid as text file... 'tgOutDir$''curName$'.TextGrid
			endif
		endeditor

		# REMOVE THE OBJECTS FOR THAT FILE AND GO ON TO THE NEXT ONE
		select Sound 'curName$'
		plus TextGrid 'curName$'
		Remove
		select Strings list
	endif
endfor

# REMOVE THE STRINGS LIST
select Strings list
plus Table 'talkList$'
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
