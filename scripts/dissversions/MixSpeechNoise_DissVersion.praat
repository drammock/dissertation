form Mix speech with noise
	sentence InputFolder ~/Desktop/SoundFiles/
	sentence NoiseFile ~/Desktop/NoiseFiles/SpeechShapedNoise.wav
	sentence OutputFolder ~/Desktop/StimuliWithNoise/
	real DesiredSNR_(dB) 0
	optionmenu finalIntensity: 1
		option match final intensity to stimulus intensity
		option maximize (scale peaks to plus/minus 1)
		option just add noise to signal (do not scale result)
endform

# NOISE
noise = Read from file... 'noiseFile$'
noiseDur = Get total duration
noiseRMS = Get root-mean-square... 0 0

# STIMULI
Create Strings as file list... stimuli 'inputFolder$'*.wav
n = Get number of strings
echo 'n' WAV files in folder 'inputFolder$'

for i from 1 to n
	# READ IN EACH STIMULUS
	select Strings stimuli
	curFile$ = Get string... 'i'
	curSound = Read from file... 'inputFolder$''curFile$'
	curDur = Get total duration
	curRMS = Get root-mean-square... 0 0
	curInten = Get intensity (dB)

	# MAKE SURE NOISE IS LONG ENOUGH. IF NOT, DOUBLE LENGTH UNTIL IT IS.
  while curDur > noiseDur
		select noise
		temp = Concatenate
		plus noise
		noise = Concatenate
		select temp
		Remove
  endwhile

	# CALCULATE NOISE COEFFICIENT THAT YIELDS DESIRED SNR
	# SNR = 20*log10(SignalAmpl/NoiseAmpl)
	# NoiseAmpl = SignalAmpl/(10^(SNR/20))
	noiseAdjustCoef = (curRMS / (10 ^ (desiredSNR / 20))) / noiseRMS

	# MIX SIGNAL AND NOISE AT SPECIFIED SNR
	select curSound
	Formula...  self[col] + noiseAdjustCoef * object[noise,col]

  if finalIntensity = 1
		# SCALE TO MATCH STIMULUS
		Scale intensity... curInten
	else if finalIntensity = 2
		# SCALE TO +/- 1
		Scale peak... 0.99
  endif

	# WRITE OUT FINAL FILE
	select curSound
	Save as WAV file... 'outputFolder$''curFile$'
	Remove
endfor

# CLEAN UP
select noise
plus Strings stimuli
Remove
printline Done!