# COLLECT ALL THE USER INPUT
form Hand-correcting TextGrids: choose directories
	sentence Sound_directory /home/dan/Desktop/dissertation/stimuli/allSounds/
	sentence TextGrid_source_directory /home/dan/Desktop/dissertation/stimuli/textgrids_syllable/
	sentence TextGrid_output_directory /home/dan/Desktop/dissertation/stimuli/textgrids_syllableCorrected/
#	sentence Subset_list /home/dan/Desktop/dissertation/stimuli/CorrectedSentenceNumbers.txt
#	sentence Talker_list /home/dan/Desktop/dissertation/stimuli/talkers.txt
	sentence Sound_extension .wav
	integer textgrid_tier 1
	comment Set window length:
	real Zoom_duration 0
	comment You can pick up where you left off if you like:
	integer startingFileNum 208
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
Create Strings as file list... list 'tgSrcDir$'*.TextGrid
fileList = selected("Strings")
fileCount = Get number of strings

# READ IN THE LIST OF USABLE SENTENCES
#Read Table from tab-separated file... 'subset_list$'
#sentList$ = selected$("Table", 1)

# READ IN THE LIST OF USABLE TALKERS
#Read Table from tab-separated file... 'talker_list$'
#talkList$ = selected$("Table", 1)

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

	# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
	select Strings list
	tgfile$ = Get string... curFile
#	soundfile$ = Get string... curFile
#	curSent$ = mid$(soundfile$,7,5)
#	select Table 'sentList$'
#	rowNum = Search column... sent 'curSent$'
#	if rowNum<>0
#	curTalk$ = left$(soundfile$,5)
#	select Table 'talkList$'
#	rowNum = Search column... talker 'curTalk$'
#	if rowNum<>0

		# READ IN THE SOUND, AND TEXTGRID
		Read from file... 'tgSrcDir$''tgfile$'
		curTgName$ = selected$ ("TextGrid", 1)
		curSnName$ = right$(curTgName$, 11)
		Read from file... 'snDir$''curSnName$''snExt$'
		echo 'curFile'

		# ADJUST FIRST BOUNDARY TO 0.05
		select TextGrid 'curTgName$'
		numTier = Get number of tiers
		for t from 1 to numTier
			lab$ = Get label of interval... t 1
			startBound = Get start point... t 1
			firstBound = Get end point... t 1
#			if firstBound-startBound <> 0.05
			if firstBound <> 0.05
				if lab$ = "sp"
					lab2$ = Get label of interval... t 2
#					Insert boundary... t startBound+0.05
					Insert boundary... t 0.05
					if t > 1
#						if firstBound-startBound < 0.05
						if firstBound < 0.05
							Set interval text... t 3 'lab2$'
							Set interval text... t 2
						endif 
					endif
					Remove boundary at time... t firstBound
				else ; NO SP AT BEGINNING
					lab2$ = Get label of interval... t 2
#					Insert boundary... t startBound+0.05
					Insert boundary... t 0.05
					if t > 1
						if firstBound-startBound < 0.05
							secondBound = Get end point... t 3
#							Insert boundary... t (startBound+0.05+secondBound)/2
							Insert boundary... t (0.05+secondBound)/2
							Set interval text... t 4 'lab2$'
							Set interval text... t 3 'lab$'
							Remove boundary at time... t firstBound
						else
							Set interval text... t 2 'lab$'
						endif 
						Set interval text... t 1 sp
					endif
				endif
				if t = 1
					Remove boundary at time... t firstBound
				endif
			endif
		endfor

		# ADJUST LAST BOUNDARY TO -0.05
		for t from 1 to numTier
			numInt = Get number of intervals... t
			lab$ = Get label of interval... t numInt
			lastBound = Get start point... t numInt
			endBound = Get end point... t numInt
			if lastBound <> endBound-0.05
				if lab$ = "sp"
					Insert boundary... t endBound-0.05
					if lastBound < endBound-0.05 and t > 1
						Set interval text... t numInt 
						Set interval text... t numInt+1 sp
					endif 
					Remove boundary at time... t lastBound
				else ; NO SP AT END YET
					lab2$ = Get label of interval... t numInt
					Insert boundary... t endBound-0.05
					if t > 1
						if lastBound > endBound-0.05
							Set interval text... t numInt 'lab2$'
						endif 
						Set interval text... t numInt+1 sp
					endif
				endif
				if t = 1
					Remove boundary at time... t lastBound
				endif
			endif
		endfor
		
		#OPEN THE PAIR OF FILES IN THE EDITOR AND ZOOM IN
		# (textgrid is already selected)
		plus Sound 'curSnName$'
		View & Edit
		editor TextGrid 'curTgName$'
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
				Save TextGrid as text file... 'tgOutDir$''curSnName$'.TextGrid
			endif
		endeditor

		# REMOVE THE OBJECTS FOR THAT FILE AND GO ON TO THE NEXT ONE
		select Sound 'curSnName$'
		plus TextGrid 'curTgName$'
		Remove
		select Strings list
#	endif
endfor

# REMOVE THE STRINGS LIST
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
