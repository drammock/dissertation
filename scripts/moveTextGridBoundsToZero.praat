form Neutralize Prosody: Select directories & starting parameters
	sentence Sound_folder /home/dan/Desktop/tmpSounds/
	sentence TextGrid_folder /home/dan/Desktop/tmpTG/
	sentence Output_folder /home/dan/Desktop/newTG/
	integer TextGrid_tier 1
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'sound_folder$'
snDir$ = "'cleanPath.out$'"
call cleanPath 'textGrid_folder$'
tgDir$ = "'cleanPath.out$'"
call cleanPath 'output_folder$'
outDir$ = "'cleanPath.out$'"

# MAKE A LIST OF SEGEMENTAL DONOR FILES AND PROSODIC DONOR FILES
Create Strings as file list... snFiles 'snDir$'*.wav
snList$ = selected$ ("Strings", 1)
snCount = Get number of strings

for f to snCount
	select Strings 'snList$'
	curSnFile$ = Get string... f
	Read from file... 'snDir$''curSnFile$'
	curName$ = selected$ ("Sound",1)
	Read from file... 'tgDir$''curName$'.TextGrid
	numInt = Get number of intervals... 1
	numTier = Get number of tiers
	select Sound 'curName$'
	plus TextGrid 'curName$'
	Scale times
	View & Edit
	editor TextGrid 'curName$'
		Move cursor to... 0
		Select next interval
		Select next interval
		for i from 3 to numInt-1
			bound = Get starting point of interval
			Move to nearest zero crossing
			for j from 2 to numTier
				Move cursor to... bound
				Select next tier
				bound2 = Get starting point of interval
				if bound2 = bound
					Move to nearest zero crossing
				endif
			endfor
			Select next interval
			Select next tier
		endfor
	endeditor
	select TextGrid 'curName$'
	Save as text file... 'outDir$''curName$'.TextGrid
	plus Sound 'curName$'
	Remove
endfor

select Strings 'snList$'
Remove
echo done!


# FUNCTIONS (A.K.A. PROCEDURES) THAT WERE CALLED EARLIER
procedure cleanPath .in$
  if not right$(.in$, 1) = "/"
    .out$ = "'.in$'" + "/"
  else
    .out$ = "'.in$'"
  endif
endproc
