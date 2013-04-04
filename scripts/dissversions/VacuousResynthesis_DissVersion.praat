form Vacuous manipulation
	sentence InputFolder ~/Desktop/ManipulationFiles/
	sentence OutputFolder ~/Desktop/VacuouslyManipulatedSoundFiles/
endform

# STIMULI
Create Strings as file list... manipFiles 'inputFolder$'*.Manpulation
n = Get number of strings
echo 'n' Manipulation files in folder 'inputFolder$'

for i from 1 to n
	# READ IN EACH STIMULUS
	select Strings manipFiles
	curFile$ = Get string... 'i'
	curManip = Read from file... 'inputFolder$''curFile$'
	curPitch = Extract pitch tier
	meanPitch = Get mean (curve)... 0 0

	select curManip
	monoPitch = Extract pitch tier
	Formula... meanPitch
	plus curManip
	Replace pitch tier
	minus monoPitch
	monoSound = Get resynthesis (overlap-add)

	monoManip = To Manipulation... 0.01 50 300
	plus curPitch
	Replace pitch tier
	minus curPitch
	finalSound = Get resynthesis (overlap-add)

	Save as WAV file... 'outputFolder$' replace$ ("'curFile$'", ".Manipulation", ".wav", 0)

	select curManip
	plus curPitch
	plus monoPitch
	plus monoSound
	plus finalSound
	Remove
endfor

# CLEAN UP
select Strings manipFiles
Remove
printline Done!