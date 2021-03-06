# COLLECT ALL THE USER INPUT
form Create syllable tier using intensity
	sentence Sound_directory ~/Desktop/SoundFiles/
	sentence Textgrid_output_directory ~/Desktop/SyllableTextgrids/
	sentence Sound_extension .wav
	sentence logFile ~/Desktop/CreateSyllableTierFromIntensity.log
	integer textgrid_tier 1
	comment Set window length:
	real Zoom_duration 0
	boolean prepopulateMinima 1
	boolean prepopulateMaxima 0
	comment You can pick up where you left off if you like:
	integer startingFileNum 1
endform

# INITIATE THE OUTPUT FILE
if fileReadable (logFile$)
	beginPause ("The log file already exists!")
		comment ("The log file already exists!")
		comment ("You can overwrite the existing file, or append new data to the end of it.")
	overwrite_setting = endPause ("Append", "Overwrite", 1)
	if overwrite_setting = 2
		filedelete 'logFile$'
		headerline$ = "number'tab$'filename'tab$'notes'newline$'"
		fileappend "'logFile$'" 'headerline$'
	endif
else
	# THERE IS NOTHING TO OVERWRITE, SO CREATE THE HEADER ROW FOR THE NEW OUTPUT FILE
	headerline$ = "number'tab$'filename'tab$'notes'newline$'"
	fileappend "'logFile$'" 'headerline$'
endif

# MAKE A LIST OF ALL SOUND FILES IN THE DIRECTORY
Create Strings as file list... soundFiles 'sound_directory$'*'sound_extension$'
fileList = selected("Strings")
fileCount = Get number of strings

# THE NEXT LINE IS A BOOLEAN FOR HANDLING EDITOR WINDOW SETTINGS
firstFile = 1
curSent$ = ""
curName$ = ""
persistentName$ = ""

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

	# GET THE NEXT FILE
	notes$ = ""
	select Strings soundFiles
	soundfile$ = Get string... curFile
	prvSent$ = curSent$
	curSent$ = left$(soundfile$,5)

	# IF WE'VE STARTED A NEW SENTENCE, CLEAR OLD ONE
	if prvSent$ <> curSent$ and prvSent$ <> ""
		select Sound 'persistentName$'
		plus TextGrid 'persistentName$'
		plus Intensity 'persistentName$'
		Remove
	endif

	# READ IN THE SOUND
	Read from file... 'sound_directory$''soundfile$'
	totalDur = Get total duration
	prvName$ = curName$
	curName$ = selected$ ("Sound", 1)

	# CLEAR INTERMEDIATE FILES (KEEPING CURRENT & PERSISTENT ONLY)
	if prvSent$ <> curSent$
		persistentName$ = curName$
	endif
	if prvName$ <> persistentName$ and prvName$ <> ""
		select Sound 'prvName$'
		plus TextGrid 'prvName$'
		plus Intensity 'prvName$'
		Remove
	endif

	# CREATE TEXTGRID
	select Sound 'curName$'
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

	# OPEN THE FILES IN THE EDITOR AND ZOOM IN
	echo 'curFile'
	select Sound 'curName$'
	plus TextGrid 'curName$'
	View & Edit
	editor TextGrid 'curName$'
		if firstFile = 1
			# SHOW ONLY SOUND FILE AND INTENSITY
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
				comment ("Add/del boundaries. Put cursor near extremum before")
				comment ("using FindMin/FindMax. When done, click Save.")
				sentence ("Notes", notes$)
			clicked = endPause ("FindMin", "FindMax", "Save", 3)
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
			Save TextGrid as text file... 'textgrid_output_directory$''curName$'.TextGrid
		endif
	endeditor

	# WRITE TO FILE
	resultline$ = "'curFile''tab$''soundfile$''tab$''notes$''newline$'"
	fileappend "'logFile$'" 'resultline$'

	# GO ON TO NEXT FILE...
	select Strings soundFiles

endfor

# REMOVE THE STRINGS LIST
select Strings soundFiles
# plus Table 'talkList$'
Remove
clearinfo
files_read = fileCount - startingFileNum + 1
printline Done! 'files_read' files read.'newline$'