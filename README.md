artscriptk
==========

Artscript is a TK GUI wrapper for convert and calligraconverter

#About
*Script inspired by David Revoy (www.davidrevoy.com , info@davidrevoy.com )*
About format based on his Artscript comments.

#### Goal
- Batch convert most image formats supported by imagemagick and calligraconvert.
- Dependencies (that I know of) : imagemagick, tk 8.5
- Optional dependencies: calligraconverter, inkscape
- Tested in: Xfce 4.10, thunar 1.4.0, dolphin and nautilus

###License
GPL 3.0
### Disclamer

I'm not a developer, I learn programming on my spare time.  
I made it for my personal use and I tested it as much as I could to avoid corrupted files and overwrittes
 

### Dependencies

- **Tk:** For Gui.  
- **ImageMagick (6.7.5 and up):** Library for manipulating image formats.
- **calligraconverter (optional):** Handles converts from XCF, ORA and KRA files.
- **inkscape (optional):** If inkscape is present it will be usen to convert svg, otherwise imagemagick will process them.  


### What it does
Artscript is a GUI wrapper for convert and calligraconvert.
It will accept a list of images and make a series of operations such as resize, add watermark, add a suffix or preffx to the output filename and change file format. All or some at the same time.

It will output all files to the current directory.  

It's perfect for preparing images before publishing (web for ex), create thumbnails or collage of images in directory, for example.

# How to run it

- Place script somewhere in your hard drive ( I choose /home/User/.scripts )
- Make script executable if it isn't
```  $sh: chmod u+x artscripttk.tcl ```
- Run the script feeing files as arguments  
```	$sh: /path/to/script/artscripttk.tcl file1.jpg file2.png file3.ora```
- You can add a bash alias in ~/.bashrc file  
```      alias artscript='~/path/to/script/artscript'```
- And you can feed arguments using "xargs" feed pipe like  
```	find . -name '*.png' -print0 | xargs -0 ~/path/to/script/artscript.tcl```
- Or if you use an alias  
```	find . -name '*.png' -print0 | xargs -0 bash -cil 'artscript "$@"' arg0```
	
## Use in Context Menus

### XFCE

1. Open thunar>Edit>Configure Custom Actions...  
2. Add New action (+)  
3. Select a Name, Description and Icon.  
4. Add the next line to Command  
     --> ```wish path/to/script/artscript.tcl %N```  
5 In Apperance Conditions Tab, set '*' as file pattern and select  
     Image files and Other files
6. Other files is needed to make the dialog appear with .ora and .kra files  
*The script filters input file by mimetype so its safe to set the Appearance Conditions to all kind of files.*
7. A new submenu appears on right-click of Image Files
8. Select files, right-click , select the item on the menu, use GUI.


### Gnome / Nautilus

You will need "nautilus-actions" package installed.
```sudo apt-get install nautilus-actions```
```emerge nautilus-actions```
etc...

Tested on liveCD Mint 13

1. Open nautilus-actions (terminal 'nautilus-actions-config-tool')
2. Click on the plus (+) symbol to add a new action. (or go to "file > add new action")
3. On the action Tab set "Context Label" with "Artscript TCL"
4. In the Command tab set "Path:" as "/path/to/script.tcl" (absolute path)
5. In the same tab set "Parameters" as "%B"
6. On mimetype set Mimetype filter as "*/*" and "must match one of "selected"
7. Hit save.
8. Restart nautilus (On the liveCD I had to)
8. A new submenu appears "Nautilus-actions actions", click it, your action should be there.
9. Select files, right-click , select the item on the menu, use GUI.
10. To get "Artscriopt TCL" on root context menu, open "nautilus-actions-config-tool", in preferences "runtime preferences" uncheck "Create a root 'Nautilus actions' menu"

(references
http://techthrob.com/2009/03/02/howto-add-items-to-the-right-click-menu-in-nautilus/
http://www.howtogeek.com/116807/how-to-easily-add-custom-right-click-options-to-ubuntus-file-manager/
)


### KDE
Inside the KDE folder there is a file "arscript.desktop" tailored to use in Dolphin

1. Verify that ServiceMenus folder exists in ~/.kde/share/kde4/services/ServiceMenus (it can also be inside ~/.kde4/ or some variants) 
2. If ServiceMenus does not exist, create it.  
3. Copy "artscript.desktop" and "artscript.tcl" into ~/.kde/share/kde4/services/ServiceMenus. 
4. Open "artscript.desktop" with a text editor and check that the line "Exec=" points to the correct folder. (on my computer there is no .kde/ folder, it is called .kde4/ )
5. Go to Dolphin and right click an image. "Artscript TCL" menu should be available.
6. If it hasn't appear, check that file paths are correct and that "artscript.tcl" is executable
7. If you have the menu you are ready to use
8. Select files, right-click , select the item on the menu, use GUI.

As an alternative place for installation, you could place the "arscript.desktop" file inside "~/.local/share/applications" and place the script anywhere in your file system. Edit desktoip file to point to actual place in filesystem. I recommend using the ServiceMenus directory to keep everything organized.


# Usage GUI
**Watermark** 
- Select any preset or add custom in empty field at the bottom.
- Select color pressing upper white color box and set opacity value using the slider. *By default the color si white, pressing the black rectangle will change the color to black.*

**Size**  
*By default resize is off:*
- Select from list or set a new value in the box below the list.
- Tile is not used unless you want to make an image Collage.
- Size in Collage refers to the tile size of each individual image composing the collage
- A Tile of 2x2 with Size 200x200 will produce an image close to 400x400.

**Output**  
- Select extension from radioboxes or set a custom extension.
- Only rename will ignore the extension setting since no convert will be done.
-  Leave ext unchanged. Supose you select 10 files, 5 jpg, 4 png and 1 gif. The program will convert, add watermarks and suffix, making the copies the same file format as the originals.
  
*Suffix is off by default*
Add any text to activate.  
The string will have an underscore before any text you input, or after If you check the box called "Prefix"  
Add Date suffix, adds the current date un the format YY-MM-DD  

Press Convert to Run options

## Collage
To make a Collage from input files set "Make Collage Please" to on
Make Collage Please checkbutton will generate a Tiled image containing all selected images. It will add a watermark if you set it so and a suffix.


# Customize:  
Lists contain User predefined values.  
You can modify any variable between "#--=====" markers to get the options you use the most.  

