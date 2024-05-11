# **Attuning Fork**
## what is it?
Attuning Fork is a subtitling, captioning, lyricing, or otherwise text-to-track syncing program.
The program takes a track *[audio only: mp3, wav, aiff, au, & snd filetypes supported]*
and a transcript *[ideally txt, but technically any type works]* where each line/lyric/new text segment is separated by new lines.

User input syncs the transcript to the track by pressing a hotkey to advance lines in time to the playing track.

This program is built primarily for syncing transcripts in cases such as Closed/Open captioning, Subtitling, and Lyricing audio. As in-program video playing is not yet supported, transcripts synced for video purposes should be paired with extracted audio from the source video. The program **does** support standard caption output types such as vtt or sbv.

## installation
This program is built within Processing 4. There are two main ways to run it:
```
Run the .java file:
Use shell/cmd/terminal on your system to navigate to the folder you placed Attuning.java
  > (ex: 'cd c:\Users\username\Documents\']
If you want to ensure you're in the correct directory:
  > on windows run 'dir *.java'
  > on linux/mac, run 'ls *.java'
  > check that Attuning.java appears in the list
compile the file with: 'javac Attuning.java'
run the program with: 'java Attuning'
```
or
```
Download processing 4.3 (latest version) https://processing.org/
Run processing, then open the .pde files in processing
Run using the big play button!
Alternatively, go to file > build to application
Run from the .exe inside the folder it generates
```


## usage
**system control buttons [from right to left]**
- save
-- saves the modified transcript into the selected output directory with the selected output filetype. will not overwrite files of the same name. saved files are in the form [transcript source name]_sync.[output format]

- track source
-- select the track to sync the transcript to. must be mp3, wav, aiff, au, or snd

- transcript source
-- select the source transcript to sync. txt works best, as other filetypes may have formatting that gets interpreted as plaintext. if an output filetype is not already selected, the output filetype defaults to the selected filetype.

- output directory
-- select the output directory for the modified transcript.

- output filetype
-- open a popup menu to select the extention of the output filetype. this will alter the formatting of the modified transcript to be campatable with the selected filetype. click again to close the menu. Currently supported filetypes: lrc, sbv, smi/sami, srt, txt, & vtt.

**track controls [from right to left]**
- restart
--restarts the track from the beginning and de-syncs any previously synced timestamps. leaves toggles.

- rewind
-- rewinds an amount of time. hotkey mapped to [left arrow]

- play/pause
-- plays or pauses the song. hotkey mapped to [spacebar]

- fast forward
-- skips a short amount of time. hotkey mapped to [right arrow]

- eject/popout
-- pops out a display of the currently selected track (if applicable). closing the popup window will prevent syncing from occuring, as time data is stored in the object that creates the window at the moment.

- timeline
-- a horizontal slider beneath all track control buttons. click to jump to a location in the track. the far left is 0:00, and the right is the end of the track.

- volume
-- a vertical slider on the right side of the screen. the top of it is maximum volume, the bottom is just above muted.

**hotkeys** *[note: only functional if the main window is focused]*
- left arrow
-- rewind track

- right arrow
-- fast forward track

- spacebar
-- play/pause audio

- [t]
-- toggle on/off whether a line will be included in the output. does not impact txt, unrecognized, or no filetypes

- tab
-- insert blank line as the next line & advance the current line by one

- delete
-- remove a blank line

- backspace
-- move backwards one line and rewind transcript to that point

- enter
-- advance one line


### getting started
To start, ensure you have an audio track and a corresponding transcript that contains each part of text that you would like to have sepearated in time on different lines. Select these using the "track" and "transcript" system control buttons. Do not close the window that pops out to display track information.

Focus the larger window that contains the transcript, and play by either clicking the pause/play track control button or by tapping spacebar. To sync the next line, hit enter. To disable a line from appearing in the output transcript, tap 't' (for 'toggle'). Greyed out/low opacity lines are 'toggled' and will not be saved to most file formmats, unless the format is unknown, .txt, or not specified (in which case, the toggled status will be written at the start of each line).

To unsync the previous line, tap backspace.

To insert a blank line (i.e. a space of time where no text will display), tap [tab]. To remove a blank line, tap [delete].

To fast forward or rewind the track, use arrow keys.

To save the transcript, select the output directory with the 'directory' system control button, and ensure the filetype is set to your preference. The default is whatever filetype the input file used, which is often _not the desired output_. Be aware that some output filetypes will not work out-of-the-box, such as .lrc, as in the case of lrc files, the name of the file must match the name of the track it is synced to, and the file must share a directory with the corresponding track. As synced transcripts are saved with the additional "_sync" in the name, this means filename-based requirements are not automatically handled.


# fonts and unicode
This program is built to work with as many scripts as possible. It supports both left-to-right and right-to-left text, and uses the font stack of the user's system to display text. This does mean that on some systems, system text may not render correctly, as currently ui scaling is hardcoded. This is something that will be fixed in future releases.

This program works using Unicode. This means it inherits the problems of Unicode, but also its benefits. As fonts are limited in size, they encode far fewer glyphs than Unicode has pointers, and therefore one font cannot display all of Unicode. Instead of specifying a specific font, this program uses the font stack of the user's system, so that text that the system can display should render the same in-program. In most cases, this means what you see in your text editor will render properly in Attuning Fork as well.
This does still have problems: Unicode is not a perfect standard, as language and orthography is not easily standerdized. Due to computational limitations, the Unicode Consortium has elected to make concessions such as *han unification*, in which similar glyphs from different orthographies all share a single pointer, and their variety is specified at the font level (resulting in cases in which it is impossible to properly display two languages in the CJK [chinese, japanese, korean] block side by side with only one font, and preserve the distinction between glyphs)
For a basic rundown of what Han Unification is and how it works, see the Wikipedia page as of 5/11/24:
```
https://en.wikipedia.org/w/index.php?title=Han_unification&oldid=1222779186
```

For further reading on Han Unification, including discussion of its problems and possible alternatives (which this program does not implement), see:
```
 “The Secret Life of Unicode.” 2013. Web.archive.org. December 16, 2013.
 https://web.archive.org/web/20131216023226/http://www.ibm.com/developerworks/library/u-secret.html.
```

For information on the orthographies supported by Unicode (and therefore this program), see:
```
 “Supported Scripts.” n.d. www.unicode.org. Accessed March 17, 2024. https://www.unicode.org/standard/supported.html.
```

Unicode does not currently support vertical text, therefore Attuning Fork does not either.
