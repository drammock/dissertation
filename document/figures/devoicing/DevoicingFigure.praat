Erase all
select Sound m5_ext_long
plus TextGrid m5_ext_long
View & Edit

Grey
Select inner viewport... 0.25 6.25 0.25 2.25
	editor TextGrid m5_ext_long
		Draw visible TextGrid... no no no no no
	endeditor

Blue
Dashed line
Select inner viewport... 0.25 6.25 0.25 1.5
	editor TextGrid m5_ext_long
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
Select inner viewport... 0.25 6.25 0.5 2
	editor TextGrid m5_ext_long
		Draw visible sound... no yes -0.5 0.5 no no no no
		Close
	endeditor

Select inner viewport... 0.25 0.75 0.25 0.75
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  a)


select Sound m2_extract
plus TextGrid m2_extract
View & Edit

Grey
Solid line
Select inner viewport... 0.25 6.25 2.5 4.5
	editor TextGrid m2_extract
		Draw visible TextGrid... no no no no no
	endeditor

Blue
Dashed line
Select inner viewport... 0.25 6.25 2.5 3.75
	editor TextGrid m2_extract
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
Select inner viewport... 0.25 6.25 2.75 4
	editor TextGrid m2_extract
		Draw visible sound... no yes -0.5 0.5 no no no no
	endeditor

Select inner viewport... 0.25 0.75 2.5 3
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  b)


select Sound resynth
View & Edit

Grey
Solid line
Select inner viewport... 0.25 6.25 4.75 6.75
	editor TextGrid m2_extract
		Draw visible TextGrid... no no no no no
		Close
	endeditor

Blue
Dashed line
Select inner viewport... 0.25 6.25 4.75 6
	editor Sound resynth
		Draw visible intensity contour... no no no no no
	endeditor

Black
Solid line
Select inner viewport... 0.25 6.25 5 6.25
	editor Sound resynth
		Draw visible sound... no yes -0.5 0.5 no no no no
		Close
	endeditor

Select inner viewport... 0.25 0.75 4.75 5.25
# Text... 0 Centre 0 Half a)
Text special... 0 centre 0 half Times 18 0  c)

Select inner viewport... 0.25 6.25 0.25 6.75
Save as EPS file... devoicing.eps

