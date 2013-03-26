form Ramp edges of sound files
	sentence Input_folder /home/dan/Documents/academics/research/dissertation/stimuli/stimuliWithNoise/zeroSNR/
	sentence Output_folder /home/dan/Documents/academics/research/dissertation/stimuli/stimuliWithNoise/rampedZeroSNR/
	real Ramp_duration 0.05
endform

Create Strings as file list... stimuli 'input_folder$'*.wav
n = Get number of strings
echo 'n' WAV files in directory 'input_folder$'

for i from 1 to n
	# READ IN EACH STIMULUS
	select Strings stimuli
	curFile$ = Get string... 'i'
	curSound = Read from file... 'input_folder$''curFile$'
	printline Processing file 'i' of 'n'
	curDur = Get total duration
	offset = curDur - ramp_duration

	# APPLY RAMPS
	Formula (part)... 0 ramp_duration 1 2 self*(1-(ramp_duration - x)/(ramp_duration))
	Formula (part)... offset curDur 1 2 self*(curDur - x)/(curDur - offset)

	# WRITE OUT FINAL FILE
	select curSound
	Save as WAV file... 'output_folder$''curFile$'
	Remove

endfor

select Strings stimuli
Remove
printline Done!
