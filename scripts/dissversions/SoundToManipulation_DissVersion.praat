# COLLECT ALL THE USER INPUT
form Pitch settings tool: Select directories & starting parameters
#	comment See the script's header for explanation of the form variables.
	sentence Sound_directory ~/Desktop/SoundFiles/
	sentence Pitch_directory ~/Desktop/PitchObjects/
	sentence Manip_directory ~/Desktop/ManipObjects/
	sentence logFile ~/Desktop/SoundToManipulation.log
	optionmenu outputType: 3
		option only log pitch settings
		option save manipulation objects
		option edit manip. objs. before save
	integer startingFileNum 1
	real defaultZoomDuration 0
	integer viewMin 1
	integer viewMax 300
	integer defMinPitch 50 (=PSOLA minimum)
	integer defMaxPitch 300
	boolean advancedInterface 0
	boolean carryover 0
	optionmenu autoplay: 1
		option off
		option on first view
		option on each redraw
	real defTimeStep 0 (=auto)
	integer defMaxCand 15
	boolean defHighAcc 1
	real defSilThresh 0.03
	real defVoiThresh 0.45
	real defOctCost 0.01
	real defJumpCost 0.5
	real defVoiCost 0.14
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'sound_directory$'
soundDir$ = "'cleanPath.out$'"
call cleanPath 'pitch_directory$'
pitchDir$ = "'cleanPath.out$'"
call cleanPath 'manip_directory$'
manipDir$ = "'cleanPath.out$'"

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
Create Strings as file list... list 'soundDir$'*.wav
fileList = selected("Strings")
fileCount = Get number of strings

# INITIALIZE SOME VARIABLES
minPitch = defMinPitch
maxPitch = defMaxPitch
timeStep = defTimeStep
maxCand = defMaxCand
highAcc = defHighAcc
silThresh = defSilThresh
voiThresh = defVoiThresh
octCost = defOctCost
jumpCost = defJumpCost
voiCost = defVoiCost

# LOOP THROUGH THE LIST OF FILES...
for curFile from startingFileNum to fileCount

	# READ IN THE SOUND...
	select Strings list
	soundname$ = Get string... curFile
	basename$ = mid$(soundname$,7,11)
	Read from file... 'soundDir$''soundname$'
	Rename... 'basename$'
	filename$ = selected$ ("Sound", 1)
	totalDur = Get total duration

	# SHOW THE EDITOR WINDOW
	zoomStart = 0
	if defaultZoomDuration > 0
		zoomEnd = defaultZoomDuration
	else
		zoomEnd = totalDur
	endif
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
			Pitch settings... defMinPitch defMaxPitch Hertz cross-correlation speckles
			Advanced pitch settings... viewMin viewMax defHighAcc defMaxCand defSilThresh defVoiThresh defOctCost defJumpCost defVoiCost
		else
			Pitch settings... minPitch maxPitch Hertz cross-correlation automatic
			Advanced pitch settings... viewMin viewMax highAcc maxCand silThresh voiThresh octCost jumpCost voiCost
		endif

		# DISPLAY NARROWBAND SPECTROGRAM AND PITCH (MAKING SURE "MAX ANALYSIS" IS LONG ENOUGH
		# SO THAT THE SPECTROGRAM ACTUALLY SHOWS UP)
		Show analyses... yes yes no no no zoomEnd-zoomStart+1
	endeditor

	# INITIALIZE SOME VARIABLES FOR THE PAUSE U.I.
	clicked = 1
	notes$ = ""
	if autoplay > 1
		firstview = 1
	else
		firstview = 0
	endif
	# THE maxPitch=0 CONDITION PREVENTS ERRORS WHEN carryover=1 AND THE PREV. FILE WAS SKIPPED
	if carryover = 0 or maxPitch = 0
		minPitch = defMinPitch
		maxPitch = defMaxPitch
		timeStep = defTimeStep
		maxCand = defMaxCand
		highAcc = defHighAcc
		silThresh = defSilThresh
		voiThresh = defVoiThresh
		octCost = defOctCost
		voiCost = defVoiCost
		jumpCost = defJumpCost
	endif

	# SHOW A U.I. WITH PITCH SETTINGS.  KEEP SHOWING IT UNTIL THE USER ACCEPTS OR CANCELS
	repeat
		beginPause ("Adjust pitch analysis settings")
			comment ("File 'filename$' (file number 'curFile' of 'fileCount')")
			comment ("You can change the pitch settings if the pitch track doesn't look right.")
			integer ("newMinPitch", minPitch)
			integer ("newMaxPitch", maxPitch)
			if advancedInterface = 1
				real ("newTimeStep", timeStep)
				integer ("newMaxCandidates", maxCand)
				boolean ("newHighAccuracy", highAcc)
				real ("newSilenceThreshold", silThresh)
				real ("newVoicingThreshold", voiThresh)
				real ("newOctaveCost", octCost)
				real ("newVoicingCost", voiCost)
				real ("newJumpCost", jumpCost)
			endif
			comment ("clicking RESET will reset parameters to the default values and redraw;")
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

		# STILL NEED TO PASS ALONG THE ADVANCED SETTINGS, EVEN IF USER DIDN'T CHANGE THEM
		if advancedInterface = 0
			newTimeStep = timeStep
			newMaxCandidates = maxCand
			newHighAccuracy = highAcc
			newSilenceThreshold = silThresh
			newVoicingThreshold = voiThresh
			newOctaveCost = octCost
			newVoicingCost = voiCost
			newJumpCost = jumpCost
		endif

		# IF THE USER CLICKS "PLAY"
		if clicked = 1
			editor Sound 'filename$'
				Play... 0 totalDur
			endeditor

		# IF THE USER CLICKS "RESET"
		elif clicked = 2
			minPitch = defMinPitch
			maxPitch = defMaxPitch
			timeStep = defTimeStep
			maxCand = defMaxCand
			highAcc = defHighAcc
			silThresh = defSilThresh
			voiThresh = defVoiThresh
			octCost = defOctCost
			voiCost = defVoiCost
			jumpCost = defJumpCost
			# REDRAW THE PITCH CONTOUR
			editor Sound 'filename$'
				Pitch settings... minPitch maxPitch Hertz cross-correlation speckles
				Advanced pitch settings... viewMin viewMax highAcc maxCand silThresh voiThresh octCost jumpCost voiCost
			endeditor

		# IF THE USER CLICKS "REDRAW"
		elif clicked = 3
			minPitch = newMinPitch
			maxPitch = newMaxPitch
			timeStep = newTimeStep
			maxCand = newMaxCandidates
			highAcc = newHighAccuracy
			silThresh = newSilenceThreshold
			voiThresh = newVoicingThreshold
			octCost = newOctaveCost
			voiCost = newVoicingCost
			jumpCost = newJumpCost
			# REDRAW THE PITCH CONTOUR
			editor Sound 'filename$'
				Pitch settings... minPitch maxPitch Hertz cross-correlation speckles
				Advanced pitch settings... viewMin viewMax highAcc maxCand silThresh voiThresh octCost jumpCost voiCost
			endeditor
		endif
	until clicked >3

	# IF THE USER SKIPS, WRITE OVERRIDE VALUES
	if clicked = 5
		minPitch = 0
		maxPitch = 0
		timeStep = 0
		maxCand = 0
		highAcc = 0
		silThresh = 0
		voiThresh = 0
		octCost = 0
		voiCost = 0
		jumpCost = 0
	endif

	select Sound 'filename$'
	# IF WE'RE DOING MORE THAN JUST WRITING SETTINGS LOG
	if outputType > 0
		To Pitch (cc)... timeStep minPitch 15 highAcc silThresh voiThresh octCost jumpCost voiCost maxPitch
		Save as text file... 'pitchDir$''filename$'.Pitch
		plus Sound 'filename$'
		To Manipulation
		# CREATE BACKUP OF PULSES FOR "RESET" BUTTON
		Extract pulses
		Rename... ppBackup
		select Manipulation 'filename$'

		# IF WE'RE EDITING THE MANIPULATION OBJECT BEFORE SAVING
		if outputType = 3
			editor Sound 'filename$'
			Close
			select Manipulation 'filename$'
			View & Edit
			# UI FOR PULSE CORRECTION (OR PITCH/DURATION TIER IF DESIRED...)
			repeat
				beginPause ("Correct pulses")
					comment ("File 'filename$' (file number 'curFile' of 'fileCount')")
				clicked = endPause ("Play","Reset", "Redraw", "Finished", 3)

				# IF THE USER CLICKS "PLAY"
				if clicked = 1
					select Sound 'filename$'
					Play

				# IF THE USER CLICKS "RESET"
				elif clicked=2
					# undo all the changes to the pulses and pitch tier
					select Manipulation 'filename$'
					plus PointProcess ppBackup
					Replace pulses
					minus Manipulation 'filename$'
					To pitch tier... 1/minPitch
					select Manipulation 'filename$'
					plus PitchTier ppBackup
					Replace pitch tier
					select PitchTier ppBackup
					Remove
					select Manipulation 'filename$'

				# IF THE USER CLICKS "REDRAW"
				elif clicked=3
					# redraw the PitchTier from the new PointProcess
					select Manipulation 'filename$'
					Extract pulses
					To PitchTier... 1/minPitch
					# previous line: 20ms is the longest gap allowed by PSOLA algorithm in treating
					# something as voiced, so the lowest pitch it will track is 50Hz. Might want to
					# hard-code the value of 0.02 instead of 1/minPitch.
					select Manipulation 'filename$'
					plus PitchTier 'filename$'
					Replace pitch tier
					select PointProcess 'filename$'
					plus PitchTier 'filename$'
					Remove
					select Manipulation 'filename$'
				endif

			until clicked>3
			select PointProcess ppBackup
			Remove
		endif

		# SAVE FILES
		select Manipulation 'filename$'
		Save as binary file... 'manipDir$''filename$'.Manipulation
		plus Pitch 'filename$'
		plus Sound 'filename$'
	endif
	Remove

	# WRITE TO LOG FILE
	resultline$ = "'curFile''tab$''filename$''tab$''totalDur''tab$''minPitch''tab$''maxPitch''tab$''timeStep''tab$''maxCand''tab$''highAcc''tab$''silThresh''tab$''voiThresh''tab$''octCost''tab$''jumpCost''tab$''voiCost''tab$''notes$''newline$'"
	fileappend "'logFile$'" 'resultline$'
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
	headerline$ = "Number'tab$'Filename'tab$'Duration'tab$'PitchFloor'tab$'PitchCeiling'tab$'TimeStep'tab$'MaxCandidates'tab$'HighAccuracy'tab$'SilenceThreshold'tab$'VoicingThreshold'tab$'OctaveCost'tab$'JumpCost'tab$'VoicingCost'tab$'Notes'newline$'"
	fileappend "'logFile$'" 'headerline$'
endproc
