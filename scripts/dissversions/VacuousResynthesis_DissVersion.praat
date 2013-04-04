form Vacuous manipulation
	sentence InputFolder ~/Desktop/ManipulationFiles/
	sentence OutputFolder ~/Desktop/VacuouslyManipulatedSoundFiles/
endform

# STIMULI
Create Strings as file list... manipFiles 'inputFolder$'*.Manipulation
n = Get number of strings
echo 'n' Manipulation files in folder 'inputFolder$'

for i from 1 to n
	# READ IN EACH STIMULUS
	select Strings manipFiles
	curFile$ = Get string... 'i'
	curManip = Read from file... 'inputFolder$''curFile$'

	# EXTRACT ORIGINAL PITCH
	curPitch = Extract pitch tier
	meanPitch = Get mean (curve)... 0 0

	# CREATE FLATTENED PITCH
	select curManip
	monoPitch = Extract pitch tier
	Formula... meanPitch
	plus curManip
	Replace pitch tier
	minus monoPitch
	monoSound = Get resynthesis (overlap-add)

	# RECREATE ORIGINAL PITCH FROM MONOTONIZED SOUND
	monoManip = To Manipulation... 0.01 50 300
	plus curPitch
	Replace pitch tier
	minus curPitch
	finalSound = Get resynthesis (overlap-add)
	newFileName$ = replace$("'curFile$'", ".Manipulation", ".wav", 0)
	Save as WAV file... 'outputFolder$''newFileName$'

	# CLEAN UP
	select curManip
	plus curPitch
	plus monoPitch
	plus monoManip
	plus monoSound
	plus finalSound
	Remove
endfor

select Strings manipFiles
Remove
printline Done!