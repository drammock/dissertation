form Calculate LTAS of corpus
	sentence InputFolder ~/Desktop/SoundFiles/
	sentence OutputFolder ~/Desktop/NoiseFiles/
	positive ltasBandwidth_(Hz) 100
	positive noisePadding_(seconds) 0.05
	optionmenu method: 2
		option by file
		option by chunk
	positive Chunk_duration_(seconds) 30
	comment Chunk duration is ignored if method is "by file".
endform

Create Strings as file list... stimuli 'inputFolder$'*.wav
n = Get number of strings
intensityRunningTotal = 0
longestFileDuration = 0
echo 'n' WAV files in directory 'inputFolder$'

# OPEN ALL SOUND FILES
for i from 1 to n
	select Strings stimuli
	curFile$ = Get string... 'i'
	tempSound = Read from file... 'inputFolder$''curFile$'
	# KEEP TRACK OF INTENSITIES SO WE CAN SCALE NOISE APPROPRIATELY
	intens = Get intensity (dB)
	intensityRunningTotal = intensityRunningTotal + intens
	# KEEP TRACK OF DURATIONS SO THE NOISE IS LONG ENOUGH FOR THE LONGEST STIMULUS
	tempDur = Get total duration
	if longestFileDuration < tempDur
		longestFileDuration = tempDur
	endif
	if method = 1
		if i = 1
			printline Creating LTAS objects...
		endif
		# CREATE LTAS FOR EACH FILE AS IT'S OPENED, AND IMMEDIATELY CLOSE SOUND FILE
		ltas_'i' = To Ltas... ltasBandwidth
		select tempSound
		Remove
	else
		# RE-OPEN EACH FILE AS LONGSOUND, TO BE CONCATENATED AND CHUNKED LATER
		Remove
		snd_'i' = Open long sound file... 'inputFolder$''curFile$'
	endif
endfor

if method = 1
	# SELECT FILEWISE LTAS OBJECTS AND AVERAGE
	printline Averaging LTAS objects...
	select ltas_1
	for i from 2 to n
		plus ltas_'i'
	endfor
	finalLTAS = Average
	Save as binary file... 'outputFolder$'CorpusFilewise.Ltas
	select ltas_1
	for i from 2 to n
		plus ltas_'i'
	endfor
	Remove
else
	# Calculate LTAS in equal-length chunks instead of by file (otherwise it would effectively weight the shorter files and deweight the longer files). Note that this is a bad idea if your files don't begin and end in silence, and is unnecessary (and slower) if all your files are the same duration.
	# CONCATENATE
	printline Concatenating corpus...
	select snd_1
	for i from 2 to n
		plus snd_'i'
	endfor
	Save as WAV file... 'outputFolder$'ConcatenatedCorpus.wav
	Remove
	# SPLIT INTO EQUAL-LENGTH CHUNKS
	printline Chunking corpus...
	corpus = Open long sound file... 'outputFolder$'ConcatenatedCorpus.wav
	corpusDur = Get total duration
	chunkCount = ceiling(corpusDur/chunk_duration)
	# CREATE LTAS FOR EACH CHUNK
	printline Creating LTAS objects...
	for i from 1 to chunkCount
		select corpus
		tempSound = Extract part... chunk_duration*(i-1) chunk_duration*i no
		ltas_'i' = To Ltas... ltasBandwidth
		select tempSound
		Remove
	endfor
	# CREATE FINAL LTAS
	printline Averaging LTAS objects...
	select ltas_1
	for i from 2 to chunkCount
		plus ltas_'i'
	endfor
	finalLTAS = Average
	Save as binary file... 'outputFolder$'CorpusChunkwise.Ltas
	# CLEAN UP INTERIM FILES
	select corpus
	for i from 1 to chunkCount
		plus ltas_'i'
	endfor
	Remove
	filedelete 'outputFolder$'ConcatenatedCorpus.wav
endif

# CREATE WHITE NOISE SPECTRUM
printline Creating speech-shaped noise...
whiteNoise = Create Sound from formula... noise 1 0 longestFileDuration+2*noisePadding 44100 randomGauss(0,0.1)
noiseSpect = To Spectrum... no
Formula... self*10^(Ltas_averaged(x)/20)
ltasNoise = To Sound
# SCALE TO AVERAGE INTENSITY OF INPUT FILES
meanIntensity = intensityRunningTotal / n
Scale intensity... meanIntensity
Save as WAV file... 'outputFolder$'SpeechShapedNoise.wav
# CLEAN UP
select whiteNoise
plus noiseSpect
plus Strings stimuli
plus finalLTAS
plus ltasNoise
Remove

printline Done!
