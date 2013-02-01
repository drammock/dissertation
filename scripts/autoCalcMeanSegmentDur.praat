# # # # # # # # # # # # # # # # # # # # # # # #
# PRAAT SCRIPT "AUTO EXTRACT SEGMENT DURATIONS"
# This script automatically extracts segment durations from TextGrids (intended for use with TextGrids of the same sentence said by multiple talkers)
#
# VERSION 0.1 (2012 08 16)
#
# CHANGELOG
#
# AUTHOR: DANIEL MCCLOY: (drmccloy@uw.edu)
# LICENSED UNDER THE GNU GENERAL PUBLIC LICENSE v3.0: http://www.gnu.org/licenses/gpl.html
# DEVELOPMENT OF THIS SCRIPT WAS FUNDED BY THE NATIONAL INSTITUTES OF HEALTH, GRANT # R01DC006014 TO PAMELA SOUZA
# # # # # # # # # # # # # # # # # # # # # # # #

# COLLECT ALL THE USER INPUT
form Calculate mean segment duration
#	sentence TextGrid_directory /Users/grant/Documents/NIHSouzaWright/PROJECTS/Dialect3/Dialect3 Stimuli/postRMS stims - wav files/TextGrids/
#	sentence Output_directory /Users/grant/Desktop/dan/
#	sentence Subset_list /Users/grant/Desktop/dan/usableSentNumbers.txt
	sentence TextGrid_directory /media/DATA/Documents/academics/research/perception/dialect3/stimuli/textgrids/
	sentence Output_directory /media/DATA/Desktop/duration results/
	sentence Subset_list /media/DATA/Documents/academics/research/perception/dialect3/desktop/pitch cleaning/bestEightSents.tab
	integer segment_tier 1
endform

# BE FORGIVING IF THE USER FORGOT TRAILING PATH SLASHES OR LEADING FILE EXTENSION DOTS
call cleanPath 'textGrid_directory$'
tgDir$ = "'cleanPath.out$'"
call cleanPath 'output_directory$'
outDir$ = "'cleanPath.out$'"

# IN CASE THERE ARE IPA GLYPHS
Text writing preferences... UTF-8

# MAKE A LIST OF ALL SOUND FILES IN THE FOLDER
Create Strings as file list... list 'tgDir$'*.TextGrid
fileList = selected("Strings")
fileCount = Get number of strings

# READ IN THE LIST OF USABLE SENTENCES
Read Table from tab-separated file... 'subset_list$'
usableSents$ = selected$("Table", 1)
numSents = Get number of rows

# PROCESS FILES SENTENCE-BY-SENTENCE
for curSentNum to numSents
	select Table 'usableSents$'
	curSent$ = Get value... curSentNum sent

	# BOOLEAN
	firstFile = 1

	# LOOP THROUGH THE LIST OF FILES...
	for curFile to fileCount

		# SEE IF IT'S A SENTENCE WE'RE INTERESTED IN
		select Strings list
		tgfile$ = Get string... curFile
		sent$ = mid$(tgfile$,7,5)
		talk$ = left$(tgfile$,5)
		if sent$ = curSent$
			# READ IN THE TEXTGRID & EXTRACT DURATIONS OF EACH INTERVAL
			Read from file... 'tgDir$''tgfile$'
			curName$ = selected$ ("TextGrid", 1)
			Extract one tier... segment_tier
			Rename... curTG
			Down to Table... no 8 no yes
			Append difference column... tmax tmin 'talk$'_dur
			Remove column... tmin
			Remove column... tmax
			Set column label (index)... 1 'talk$'_seg
		
			if firstFile=1
				# CREATE THE MASTER RESULTS TABLE ("COPY" INSTEAD OF "RENAME" SO THAT THE CLEANUP SCRIPT DOESN'T CHOKE WHEN REMOVING THE ORIGINAL)
				Copy... 'curSent$'
				firstFile = 0
			else
				numRows = Get number of rows
				select Table 'curSent$'
				Append column... 'talk$'_seg
				Append column... 'talk$'_dur
			
				# TRANSFER ALL THE DURATIONS TO THE MASTER RESULTS TABLE 
				for row to numRows
					select Table curTG
					seg$ = Get value... row 'talk$'_seg
					dur = Get value... row 'talk$'_dur
					select Table 'curSent$'
					destRows = Get number of rows
					if row > destRows
						Append row
					endif
					Set string value... row 'talk$'_seg 'seg$'
					Set numeric value... row 'talk$'_dur dur
				endfor 
			endif
		
			# CLEAN UP
			select TextGrid 'curName$'
			plus TextGrid curTG
			plus Table curTG
			Remove
		endif
	endfor

	select Table 'curSent$'
	Save as tab-separated file... 'outDir$''curSent$'.tab
	Remove
endfor

select Table 'usableSents$'
plus Strings list
Remove

# FUNCTIONS (A.K.A. PROCEDURES) THAT WERE CALLED EARLIER
procedure cleanPath .in$
	if not right$(.in$, 1) = "/"
		.out$ = "'.in$'" + "/"
	else
		.out$ = "'.in$'"
	endif
endproc
