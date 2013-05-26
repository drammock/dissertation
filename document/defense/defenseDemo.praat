unmodDir$ = "/home/dan/Documents/academics/research/dissertation/stimuli/manipulationObjects/"
resynthDir$ = "/home/dan/Documents/academics/research/dissertation/stimuli/resynthesizedManip/"
for i to 3
	letters$[i] = mid$("ABC",i)
endfor

talkerAA = Read from file... 'unmodDir$'NWM02_02-01.Manipulation
Rename... talkerAA
talkerBB = Read from file... 'unmodDir$'NWM05_02-01.Manipulation
Rename... talkerBB
talkerCC = Read from file... 'unmodDir$'NWM07_02-01.Manipulation
Rename... talkerCC

talkerAB = Read from file... 'resynthDir$'NWM25_02-01.Manipulation
Rename... talkerAB
talkerAC = Read from file... 'resynthDir$'NWM27_02-01.Manipulation
Rename... talkerAC
talkerBA = Read from file... 'resynthDir$'NWM52_02-01.Manipulation
Rename... talkerBA
talkerBC = Read from file... 'resynthDir$'NWM57_02-01.Manipulation
Rename... talkerBC
talkerCA = Read from file... 'resynthDir$'NWM72_02-01.Manipulation
Rename... talkerCA
talkerCB = Read from file... 'resynthDir$'NWM75_02-01.Manipulation
Rename... talkerCB

segmental_donor = 0
prosodic_donor = 0

repeat
	beginPause ("")
		choice ("Segmental donor", segmental_donor)
			option ("A")
			option ("B")
			option ("C")

		choice ("Prosodic donor", prosodic_donor)
			option ("A")
			option ("B")
			option ("C")

#		choice ("Noise", noise)
#			option ("None")
#			option ("3 dB SNR")
#			option ("0 dB SNR")

	clicked = endPause ("Quit", "Play", "Show", 2, 1)

	if clicked > 1
		segDonor$ = letters$['segmental_donor']
		proDonor$ = letters$['prosodic_donor']
		chosenTalker$ = "talker'segDonor$''proDonor$'"

		if clicked = 3
			select Manipulation 'chosenTalker$'
			View & Edit
		endif

		if clicked = 2
			select Manipulation 'chosenTalker$'
			Play (overlap-add)
		endif

	endif

until clicked = 1

select talkerAA
plus talkerBB
plus talkerCC
plus talkerAB
plus talkerAC
plus talkerBA
plus talkerBC
plus talkerCA
plus talkerCB
Remove
exit