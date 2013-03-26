# This Praat script takes the average LTAS of a set of audio files
# (the set of audio files is listed in file `names.txt`) and shapes
# a 5 sec portion of white noise according to this average LTAS.
#
# 2009 Theo Veenker, Lisette van Delft, Hugo Quene
#
# See Quené & Van Delft (2010). Speech Commun, 52, 911-918.
# doi:10.1016/j.specom.2010.03.005

datadir$ = "/home/dan/Documents/academics/research/dissertation/stimuli/dissTalkers/"

Create Strings as file list... names 'datadir$'*.wav
# Read Strings from raw text file... 'datadir$'/names.txt

n = Get number of strings
intensityRunningTotal = 0

# Create LTAS for each sound file.
for i from 1 to n
    select Strings names
    name$ = Get string... 'i'
    tmpSound = Read from file... 'datadir$''name$'
    To Ltas... 100
    ltas'i' = selected("Ltas");
    select tmpSound
    intens = Get intensity (dB)
    intensityRunningTotal = intensityRunningTotal + intens
    Remove
endfor
select Strings names
Remove

# Create average LTAS
select ltas1
for i from 2 to 'n'
    plus ltas'i'
endfor
Average

# Remove each sound file's LTAS
for i from 1 to 'n'
    select ltas'i'
    Remove
endfor

# Create 5 seconds of white noise and convert to a spectrum
Create Sound from formula... noise Mono 0 5 44100  randomGauss(0,0.1)
To Spectrum... no
select Sound noise
Remove

# Apply LTAS envelope to white noise spectrum and convert back to sound
select Spectrum noise
Formula... self * 10 ^ (Ltas_averaged(x)/20)
To Sound

# SCALE TO AVERAGE INTENSITY OF INPUT FILES
meanIntensity = intensityRunningTotal / n
Scale intensity... meanIntensity

# Cleanup
select Ltas averaged
plus Spectrum noise
Remove
