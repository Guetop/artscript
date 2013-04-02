#!/usr/bin/wish
# Script inspired by David Revoy (www.davidrevoy.com , info@davidrevoy.com )
# About format based on his Artscript comments.
#----------------:::: ArtscriptTk ::::----------------------
# IvanYossi colorathis.wordpress.com ghevan@gmail.com  GPL 3.0
#-----------------------------------------------------------
# Goal : Batch convert any image file supported by imagemagick and calligra.
# Dependencies (that I know of) : calligraconverter, >=imagemagick-6.7.5,tk 8.5
#
# __Customize:__
#   You can modify any variable between "#--=====" markers
#
#

#--====User variables, date preferences, watermarks, sizes, default values
set now [exec date +%F]
#Get a different number each run
set raninter [exec date +%N]
set autor "Your Name Here"
set watermarks [list \
  "Copyright (c) $autor" \
  "Copyright (c) $autor / $now" \
  "http://www.yourwebsite.com" \
  "Artwork: $autor" \
  "$now" \
]
set sizes [list \
  "1920x1920" \
  "1650x1650" \
  "1280x1280" \
  "1024x1024" \
  "800x800" \
  "150x150" \
  "100x100" \
  "50%" \
]
set suffixes [list \
  "net" \
  "archive" \
  "by-[string map -nocase {{ } -} $autor]" \
  "my-cool-suffix" \
]
set sizext "200x200"
set opacity 0.8
set wmsize 10
set rgb "#ffffff"
set ::wmswatch "black gray white"
#Image quality
set sliderval 92
#Extension & output
set ::outextension "jpg"
#Color:
set ::bgcolor "#ffffff"
set ::bgop 1
set ::bgswatch "black gray white"
set ::bordercol "#aaaaaa"
set ::brop .8
set ::brswatch "black gray white"
set ::tfill "#ffffff"
set ::tfop .8
set ::tswatch "black gray white"
#Montage:
# mborder Adds a grey border around each image. set 0 disable
# mspace Adds space between images. set 0 no gap
set ::mborder 5
set ::mspace 3
set ::mrange {}
# moutput Montage filename output
set ::mname "collage-$raninter"
#--=====

#Las message variable
set lstmsg ""
set suffix ""

#Validation Functions
#Finds program in path using which, return 0 if program missing
proc validate {program} {
  if { [catch {exec which $program}] } {
     return 0
  }
  return 1
}
#Inkscape path, if true converts using inkscape to /tmp/*.png
set hasinkscape [validate "inkscape"]
#calligraconvert path, if true converts using calligra to /tmp/*.png
set hascalligra [validate "calligraconverter"]

#Function to send message boxes
proc alert {type icon title msg} {
    tk_messageBox -type $type -icon $icon -title $title \
    -message $msg
}
#Check if we have files to work on, if not, finish program.
if {[catch $argv] == 0 } { 
  alert ok info "Operation Done" "No files selected Exiting"
  exit
}
# listValidate:
# Validates arguments input mimetypes, keeps images strip the rest
# Creates a separate list for .kra, .xcf, .psd and .ora to process separatedly
proc listValidate {} {
  global argv calligralist inkscapelist lfiles fc hasinkscape hascalligra
  set lfiles "Files to be processed\n"
  set fc 0
  set calligralist [list]
  set inkscapelist ""
  #We validate list elements
  foreach el $argv {
    #puts [exec file $el]
    #Append to new list if mime is from type.
    if { [ regexp {application/x-krita|image/openraster|GIMP XCF image data|Adobe Photoshop Image} [exec file $el] ] && $hascalligra } {
      lappend calligralist $el
      append lfiles "$fc Cal: $el\n"
      set argv [lsearch -all -inline -not -exact $argv $el]
      incr fc
      continue
    }
    #Append to inkscapelist
    if { [regexp {SVG Scalable Vector Graphics image} [exec file $el]] && $hasinkscape } {
      lappend inkscapelist $el
      append lfiles "$fc Ink: $el\n"
      set argv [lsearch -all -inline -not -exact $argv $el]
      incr fc
      continue
    }
    #Remove from list elements not supported by convert
    if { [catch { exec identify -quiet $el } msg] } {
      set argv [lsearch -all -inline -not -exact $argv $el]
    } else {
      append lfiles "$fc Img: $el\n"
      incr fc
    }
  }
  #Check if resulting lists have elements
  if {[llength $argv] + [llength $calligralist] + [llength $inkscapelist] == 0} {
    alert ok info "Operation Done" "No image files selected Exiting"
    exit
  }
}
#We run function to validate input mimetypes
listValidate

#For future theming
#tk_setPalette background black foreground white highlightbackground blue activebackground gray70 activeforeground black

#Gui construct. This needs to be improved a lot
#--- watermark options
labelframe .wm -bd 2 -padx 2m -pady 2m -font {-size 12 -weight bold} -text "Watermark options"  -relief ridge
pack .wm -side top -fill x

listbox .wm.listbox -selectmode single -height 6
foreach i $watermarks { .wm.listbox insert end $i }
bind .wm.listbox <<ListboxSelect>> { setSelectOnEntry [%W curselection] "wm" "watxt"}
entry .wm.entry -text "Custom" -textvariable watxt
bind .wm.entry <KeyRelease> { setSelectOnEntry false "wm" "watxt" }
label .wm.label -text "Selected:"

label .wm.lwmsize -text "Size:"
entry .wm.wmsizentry -textvariable wmsize -width 3 -validate key \
   -vcmd { regexp {^(\s?|[1-9]|[1-4][0-8])$} %P }
scale .wm.wmsize -orient vertical -from 48 -to 1 \
  -variable wmsize -showvalue 0



#label .wm.title -font {-size 10} -text "Color"
#button .wm.color -text "Choose Color" -command { set rgb [setWmColor $rgb .wm.viewcol "Watermark Color"] }
#canvas .wm.viewcol -bg $rgb -width 96 -height 32
#.wm.viewcol create text 30 16 -text "click me"
#canvas .wm.black -bg black -width 48 -height 16
#canvas .wm.white -bg white -width 48 -height 16

#label .wm.lopacity -text "Opacity:"
#scale .wm.opacity -orient horizontal -from .1 -to 1.0 -resolution 0.1 \
#  -variable opacity -showvalue 0 -command {writeVal .wm.lopacity "Opacity:" }

#bind .wm.viewcol <Button> { set rgb [setWmColor $rgb %W "Watermark Color"] }
#bind .wm.black <Button> { set rgb black; .wm.viewcol configure -bg $rgb }
#bind .wm.white <Button> { set rgb white; .wm.viewcol configure -bg $rgb }

grid .wm.listbox -row 1 -rowspan 2 -column 1 -sticky nesw
grid .wm.entry -row 3 -column 1 -sticky we
grid .wm.label -row 4 -column 1 -sticky w
grid .wm.lwmsize -row 1 -column 2 -sticky nw
grid .wm.wmsize -row 2 -rowspan 2 -column 2 -sticky ns
grid .wm.wmsizentry -row 4 -column 2 -sticky w 
#grid .wm.title -row 1 -column 3 -sticky nw
#grid .wm.viewcol -row 2 -column 3 -sticky nesw
#grid .wm.black -row 3 -column 3 -sticky nsew
#grid .wm.white -row 3 -column 4 -sticky nsew
#grid .wm.color -row 4 -column 3 -sticky ew
#grid .wm.lopacity -row 4 -column 3 -sticky wns
#grid .wm.opacity -row 5 -column 3 -sticky ew
#grid .wm.title .wm.viewcol .wm.lopacity .wm.opacity -columnspan 2
grid rowconfigure .wm 1 -weight 0
grid rowconfigure .wm {2 3 4} -weight 1
grid columnconfigure .wm 1 -weight 1
grid columnconfigure .wm {2} -weight 0

#--- Color options
proc colorSelector { frame suffix colorvar op title colors {row 0} } {
  global $colorvar
  #set ::frame $frame
  #set ::colorvar $colorvar
  #set ::suffix $suffix
  #set ::title $title

  label $frame.${suffix}title -font {size 12} -text $title

  canvas $frame.${suffix}viewcol -bg [set $colorvar] -width 60 -height 30
  $frame.${suffix}viewcol create text 30 16 -text "click me"

  #canvas $frame.${suffix}black -bg black -width 32 -height 16
  #canvas $frame.${suffix}gray -bg gray -width 32 -height 16
  #canvas $frame.${suffix}white -bg white -width 32 -height 16

  label $frame.${suffix}lopacity -text "Opacity:"
  scale $frame.${suffix}opacity -orient horizontal -from .1 -to 1.0 -resolution 0.1 -relief flat -bd 0  \
  -variable $op -showvalue 0 -width 8	 -command "writeVal $frame.${suffix}lopacity {Opacity:}"

  bind $frame.${suffix}viewcol <Button> [ list colorBind $frame.${suffix}viewcol $colorvar 0 $title ]
  foreach i $colors {
    canvas $frame.${suffix}$i -bg $i -width [expr 60/[llength $colors]] -height 16
    bind $frame.${suffix}$i <Button> [ list colorBind $frame.${suffix}viewcol $colorvar $i $title ]
  }
  #bind $frame.${suffix}black <Button> [ list colorBind $frame.${suffix}viewcol $colorvar black $title ]
  #bind $frame.${suffix}gray <Button> [ list colorBind $frame.${suffix}viewcol $colorvar gray $title ]
  #bind $frame.${suffix}white <Button> [ list colorBind $frame.${suffix}viewcol $colorvar white $title ]

  grid $frame.${suffix}title -row $row -column 1 -sticky nw
  incr row
  grid $frame.${suffix}viewcol -row $row -column 1 -sticky nesw
  incr row
  set cn 0
  foreach i $colors {
    grid $frame.${suffix}$i -row $row -column [incr cn] -sticky nsew
  }
  #grid $frame.${suffix}black -row $row -column 1 -sticky nsew
  #grid $frame.${suffix}gray -row $row -column 2 -sticky nsew
  #grid $frame.${suffix}white -row $row -column 3 -sticky nsew
  incr row
  grid $frame.${suffix}lopacity -row $row -column 1 -sticky wns
  incr row
  grid $frame.${suffix}opacity -row $row -column 1 -sticky ew
  grid $frame.${suffix}title $frame.${suffix}viewcol $frame.${suffix}lopacity $frame.${suffix}opacity -columnspan [llength $colors]
}

labelframe .color -bd 0 -padx 2m -pady 2m -font {-size 12 -weight bold} -text "Color settings"  -relief solid
pack .color -side left -fill y

colorSelector ".color" "wm" "rgb" "opacity" "Watermark" $wmswatch 0
colorSelector ".color" "bg" "bgcolor" "bgop" "Background Col" $bgswatch 10
colorSelector ".color" "br" "bordercol" "brop" "Border Col" $brswatch 15
colorSelector ".color" "fil" "tfill" "tfop" "Label Col" $tswatch 20

#--- Size options
labelframe .size -bd 2 -padx 2m -pady 2m -font {-size 12 -weight bold} -text "Size & Collage settings"  -relief ridge
pack .size -side top -fill x
#scrollbar binding function
proc showargs {args} {
  #puts $args;
  eval $args
}

listbox .size.listbox -selectmode single -relief flat -height 2
foreach i $sizes { .size.listbox insert end $i }
bind .size.listbox <<ListboxSelect>> { setSelectOnEntry [%W curselection] "size" "sizext"}
scrollbar .size.scroll -command {showargs .size.listbox yview} -orient vert
.size.listbox conf -yscrollcommand {showargs .size.scroll set}

message .size.exp -width 220 -justify center -text "\
 Size format can be expresed as: \nW x H or 40%, 50% \n\
 In Collage mode size refers to tile size\n\
 Size 200x200 + Layout 2x2 = w400xh400"

#size and tile entry boxes and validation
entry .size.entry -textvariable sizext -validate key \
   -vcmd { regexp {^(\s*|[0-9])+(\s?|x|%%)(\s?|[0-9])+$} %P }
bind .size.entry <KeyRelease> { setSelectOnEntry false "size" "sizext" }
entry .size.tile -textvariable tileval -width 6  -validate key \
   -vcmd { regexp {^(\s*|[0-9])+(\s?|x|%%)(\s?|[0-9])+$} %P }
bind .size.tile <KeyRelease> { checkstate $tileval .opt.tile }
entry .size.range -textvariable mrange -width 4 -validate key \
   -vcmd { regexp {^(\s*|[0-9])+$} %P }
bind .size.range <KeyRelease> { checkstate $mrange .opt.tile }

label .size.label -text "Size:"
label .size.txtile -text "Layout:"
label .size.lblrange -text "Range:"

grid .size.listbox -row 1 -column 1 -sticky nwse
grid .size.scroll -row 1 -column 1 -sticky ens
grid .size.entry -row 2 -column 1 -sticky ews
grid .size.label -row 3 -column 1 -sticky wns
grid .size.exp -row 1 -column 2 -columnspan 4 -sticky nsew
grid .size.txtile -row 2 -column 2 -sticky e
grid .size.tile -row 2 -column 3  -sticky ws
grid .size.range -row 2 -column 5 -sticky ws
grid .size.lblrange -row 2 -column 4 -sticky e
grid rowconfigure .size 1 -weight 3
grid rowconfigure .size 2 -weight 1
grid columnconfigure .size 1 -weight 1
grid columnconfigure .size {2 3 4} -weight 0

#--- Format options
labelframe .ex -bd 2 -padx 2m -pady 2m -font {-size 12 -weight bold} -text "Output Format"  -relief ridge
pack .ex -side top -fill x
radiobutton .ex.jpg -value "jpg" -text "JPG" -variable outextension
radiobutton .ex.png -value "png" -text "PNG" -variable outextension
radiobutton .ex.gif -value "gif" -text "GIF" -variable outextension
radiobutton .ex.ora -value "ora" -text "ORA(No post)" -variable outextension
.ex.jpg select
label .ex.lbl -text "Other"
entry .ex.sel -text "custom" -textvariable outextension -width 4
text .ex.txt -height 3 -width 4
.ex.txt insert end $lfiles

#-- Select only rename no output transform
checkbutton .ex.rname -text "Only rename" \
    -onvalue true -offvalue false -variable renamesel
#-- Ignore output, use input extension as output.
checkbutton .ex.keep -text "Keep extension" \
    -onvalue true -offvalue false -variable keep
#--- Image quality options

scale .ex.scl -orient horizontal -from 10 -to 100 -tickinterval 25 -width 12 \
    -label "" -length 150 -variable sliderval -showvalue 1
#    -highlightbackground "#666" -highlightcolor "#333" -troughcolor "#888" -fg "#aaa" -bg "#333" -relief flat
label .ex.qlbl -text "Quality:"
button .ex.good -pady 1 -padx 8 -text "Good" -command resetSlider; #-relief flat -bg "#888"
button .ex.best -pady 1 -padx 8 -text "Best" -command {set sliderval 100}
button .ex.poor -pady 1 -padx 8 -text "Poor" -command {set sliderval 30}

grid .ex.jpg .ex.png .ex.gif .ex.ora .ex.rname .ex.keep -column 1 -columnspan 2 -sticky w
grid .ex.jpg -row 1
grid .ex.png -row 2
grid .ex.gif -row 3
grid .ex.ora -row 4
grid .ex.sel -row 5 -column 2
grid .ex.lbl -row 5 -column 1
grid .ex.keep -row 6
grid .ex.rname -row 7	
grid .ex.txt -column 3 -row 1 -columnspan 5 -rowspan 4 -sticky nesw
grid .ex.qlbl .ex.poor .ex.good .ex.scl .ex.best -row 6 -rowspan 2 -sticky we
grid .ex.qlbl -column 3
grid .ex.poor -column 4
grid .ex.good -column 5
grid .ex.scl  -column 6
grid .ex.best -column 7
grid columnconfigure .ex {1} -weight 0
grid columnconfigure .ex {6} -weight 1

#--- Suffix options
labelframe .suffix -padx 2m -pady 2m -font {-size 12 -weight bold} -text "Suffix"  -relief ridge
pack .suffix -side top -fill x

listbox .suffix.listbox -selectmode single -height 4
foreach i $suffixes { .suffix.listbox insert end $i }
bind .suffix.listbox <<ListboxSelect>> { setSelectOnEntry [%W curselection] "suffix" "suffix"}
label .suffix.label -text "Selected:"

entry .suffix.entry -textvariable suffix -validate key \
   -vcmd { string is graph %P }
bind .suffix.entry <KeyRelease> { setSelectOnEntry false "suffix" "suffix" }
checkbutton .suffix.date -text "Add Date Suffix" \
    -onvalue true -offvalue false -variable datesel -command setdateCmd
checkbutton .suffix.prefix -text "Prefix" \
    -onvalue true -offvalue false -variable prefixsel -command { setSelectOnEntry false "suffix" "suffix" }

grid .suffix.listbox -column 1 -rowspan 4 -sticky nsew
grid .suffix.label -row 1 -column 2 -columnspan 3 -sticky nsew
grid .suffix.entry -row 2 -column 2 -columnspan 3 -sticky ew
grid .suffix.date -row 3 -column 2 -sticky w
grid .suffix.prefix -row 3 -column 4 -sticky w
grid columnconfigure .suffix {1} -weight 0
grid columnconfigure .suffix {2} -weight 1

#pack .suffix.entry -side left -fill x -expand 1
#pack .suffix.rname .suffix.prefix .suffix.date -side right

#--- On off values for watermark, size, date suffix and tiling options
frame .opt -borderwidth 2
pack .opt
checkbutton .opt.watxt -text "Watermark" \
    -onvalue true -offvalue false -variable watsel
checkbutton .opt.sizext -text "Resize" \
    -onvalue true -offvalue false -variable sizesel
checkbutton .opt.tile -text "Make Collage" \
    -onvalue true -offvalue false -variable tilesel

pack .opt.watxt .opt.sizext .opt.tile -side left

#--- Submit button
frame .act -borderwidth 6
pack .act -side right
button .act.submit -text "Convert" -font {-weight bold} -command convert
pack .act.submit -side right -padx 0 -pady 0


#--- Window options
wm title . "Artscript -- $fc Files selected"

#General Functions

#Controls watermark text events.
#proc setWatermark { indx } {
#  global watxt
#  #Check if variable comes from list, if not then get value from entry text
#  if {$indx} { 
#    set val [.wcol.listbox get $indx]
#  } else {
#    set val [.wcol.custom get]
#  }
#  .wcol.label configure -text "Selected: $val"
#  #If anything is selected we set Watermark option on automatically
#  .opt.wm select
#  set watxt $val
#}
proc checkstate { val cb } {
  if {$val != {} } {
    $cb select
  } else {
    $cb deselect
  }
}

#Converts hex color value and returns rgb value with opacity setting to alpha channel
proc setRGBColor { rgb {opacity 1.0} } {
  #Transform hex value to rgb 16bit
  set rgbval [ winfo rgb . $rgb ]
  set rgbn "rgba("
  foreach i $rgbval {
    #For each value we divide by 256 to get 8big rgb value (0 to 255)
    #I set it to 257 to get integer values, need to check this further.
    append rgbn "[expr $i / 257],"
  }
  append rgbn "$opacity)"
  return $rgbn
}

#Sets text label to $val This function needs to generalize a lot more.
proc writeVal { l text val } {
  $l configure -text "$text $val"
}

proc setWmColor { rgb window { title "Choose color"} } {
  #Call color chooser and store value to set canvas color and get rgb values
  set choosercolor [tk_chooseColor -title $title -initialcolor $rgb -parent .]
  if { [expr {$choosercolor ne "" ? 1 : 0}] } {
    set rgb $choosercolor
    $window configure -bg $rgb
  }
  return $rgb
}

proc colorBind { w var {color false} title } {
  global $var
  if {![string is boolean $color]} {
    set $var $color
    $w configure -bg $color
  } else {
    set $var [setWmColor [set $var] $w $title]
  }
}

#Recieves an indexvalue a rootname and a global variable to call
#Syncs listbox values with other label values and entry values
proc setSelectOnEntry { indx r g } {
  global $g
  #Check if variable comes from list, if not then get value from entry text
  if { [string is integer $indx] } { 
    set val [.$r.listbox get $indx]
  } else {
    set val [.$r.entry get]
  }
  set $g $val
  #Dirty hack to add suffix listbox but no select option
  if {$g != "suffix"} {
    .$r.label configure -text "Selected: $val"
  #If anything is selected we set Size option on automatically
    .opt.$g select
  #Else $g is "suffix" 
  } else {
    .$r.label configure -text "Output: [getOutputName]"
  }
}


#Set slider value to 75
#The second funciton i made, probably its a good idea to strip it
proc resetSlider {} {
  global sliderval
  set sliderval 92
}

#Function that controls suffix date construction
proc setdateCmd {} {
  global datesel now suffix
  #We add the date string if checkbox On
  if {$datesel} {
    uplevel append suffix $now
    .suffix.label configure -text "Output: [getOutputName]"
  } else {
  #If user checkbox to off
  #We erase it when suffix is same as date
    if { $suffix == "$now" } {
      uplevel set suffix "{}"
    } else {
  #Search date string to erase from suffix
      uplevel set suffix [string map -nocase "$now { }" $suffix ]
    }
  }
}
proc keepExtension { i } {
  global outextension
  uplevel set outextension [ string trimleft [file extension $i] "."]
}
#Preproces functions
#watermark
proc watermark {} {
  global watxt watsel wmsize rgb opacity

  set rgbout [setRGBColor $rgb $opacity]
  set wmpos "SouthEast"
  #Watermarks, we check if checkbox selected to add characters to string
  if {$watsel} {
    set watval "-pointsize $wmsize -fill $rgbout -gravity $wmpos -draw \"text 10,10 \'$watxt\'\""
#png32:- | convert - -pointsize 10 -fill  -gravity SouthEast -annotate +3+3 "
  } else {
    set watval ""
  }
  return $watval
}
#Image magick processes
#Collage mode
proc collage { olist path } {
  global tileval mborder mspace mname mrange sizext
  #colors
  global bgcolor bgop bordercol brop tfill tfop
  set sizeval [string trim $sizext]
  set clist ""

  proc range { ilist range } {
    set rangelists ""
    set listsize [llength $ilist]
    set times [expr [expr $listsize/$range]+[expr bool($listsize % $range) ] ]

    for {set i 0} { $i < $times } { incr i } {
      set val1 [expr $range * $i]
      set val2 [expr $range * [expr $i+1] - 1 ]
      lappend rangelists [lrange $ilist $val1 $val2]
    }
    return $rangelists
  }

  if { [string length $mrange] > 0 } {
    set clist [range $olist $mrange]
  } else {
    lappend clist $olist
  }

  #Check if user set something in tile entry field
  if {![string is boolean $tileval]} {
    set tileval "-tile $tileval"
  }
  #We have to substract the margin from the tile value, in this way the user gets
  # the results is expecting (200px tile 2x2 = 400px)
  if {![string match -nocase {*[0-9]\%} $sizeval]} {
    set mgap [expr [expr $mborder + $mspace ] *2 ]
    set xpos [string last "x" $sizeval]
    set sizelast [expr [string range $sizeval $xpos+1 end]-$mgap]
    set sizeval [expr [string range $sizeval 0 $xpos-1]-$mgap]
    set sizeval "$sizeval\x$sizelast\\>"
  }
  #color transforms
  set rgbout [setRGBColor $bgcolor $bgop]
  lappend rgbout [setRGBColor $bordercol $brop]
  lappend rgbout [setRGBColor $tfill $tfop]
  #Run montage
  set count 0
  foreach i $clist {
    set tmpvar ""
    set name [ append tmpvar "/tmp/" $count "_" $mname ".artscript_temppng" ]
    eval exec montage -quiet $i -geometry "$sizeval+$mspace+$mspace" -border $mborder -background [lindex $rgbout 0] -bordercolor [lindex $rgbout 1] $tileval -fill [lindex $rgbout 2]  "png:$name"
    dict set paths $name $path
    incr count
  }
  lappend rlist [dict keys $paths] $paths
  return $rlist
}

#Run Converter
proc convert {} {
  global outextension sliderval sizesel sizext tilesel now argv calligralist inkscapelist
  global renamesel prefixsel tileval keep mborder mspace mname bgcolor
  set sizeval $sizext
  # For extension with no alpha channel we have to add this lines so the user gets the results
  # he is expecting
  if { $outextension == "jpg" } {
    set alpha "-background $bgcolor -alpha remove"
  } else {
    set alpha ""
  }
  #Before checking all see if user only wants to rename
  if {$renamesel} {
    if [llength $calligralist] {
      foreach i $calligralist {
        keepExtension $i
        set io [setOutputName $i $outextension $prefixsel $renamesel]
        file rename $i $io
      }
    }
    if [llength $argv] {
      foreach i $argv {
        keepExtension $i
        set io [setOutputName $i $outextension $prefixsel $renamesel]
        file rename $i $io
      }
    }
    exit
  }
  #Run watermark preprocess
  set watval [watermark]
  #Size, checbox = True set size command
  #We have to trim spaces?
  set sizeval [string trim $sizeval]
  #We check if user wants resize and $sizeval not empty
  if {!$sizesel || [string is boolean $sizeval] || $sizeval == "x" } {
    set sizeval ""
    set resizeval ""
  } else {
    set resizeval "-resize $sizeval\\>"
  }
  #Declare a empty list to fill with tmp files for deletion
  set tmplist ""
  #Declare empty dict to fill original path location
  set paths [dict create]
  if [llength $calligralist] {
    foreach i $calligralist {
      #Make png to feed convert, we feed errors to dev/null to stop calligra killing
      # the process over warnings, and exec inside a try/catch event as the program send
      # a lot of errors on some of my files breaking the loop
      #Sends file input for processing, stripping input directory
      set io [setOutputName $i "artscript_temppng" 0 0 1]
      set outname [lindex $io 0]
      set origin [lindex $io 1]
      catch [ exec calligraconverter --batch $i -mimetype image/png /tmp/$outname 2> /dev/null ]
      #Add png to argv file list on /tmp dir and originalpath to dict
      dict set paths /tmp/$outname $origin
      lappend argv /tmp/$outname
      lappend tmplist /tmp/$outname
    }
  }
  if [llength $inkscapelist] {
    foreach i $inkscapelist {
      set inksize ""
      if {$sizesel || $tilesel } {
        if {![string match -nocase {*[0-9]\%} $sizeval]} {
          set mgap [expr [expr $mborder + $mspace ] *2 ]
          set inksize [string range $sizeval 0 [string last "x" $sizeval]-1]
          set inksize "-w $inksize"
        } else {
          set inksize [expr 90 * [ expr 50 / 100.0 ] ]
          set inksize "-d $inksize"
        }
      }
      #Make png to feed convert, we try catch, inkscape cant be quiet
      #Sends file input for processing, stripping input directory
      set io [setOutputName $i "artscript_temppng" 0 0 1]
      set outname [lindex $io 0]
      set origin [lindex $io 1]
      catch [ exec inkscape $i -z -C $inksize -e /tmp/$outname 2> /dev/null ]
      #Add png to argv file list on /tmp dir and originalpath to dict
      dict set paths /tmp/$outname $origin
      lappend argv /tmp/$outname
      lappend tmplist /tmp/$outname
    }
  }
  if [llength $argv] {
    if {$tilesel} {

      #If paths comes empty we get last file path as output directory
      # else we use the last processed tmp file original path
      if {[string is false $paths]} {
        set path [file dirname [lindex $argv end] ]
      } else {
        set path [dict get $paths /tmp/$outname]
      }

      #Run command return list with file paths
      set clist [collage $argv $path]
      set ckeys [lindex $clist 0]

      set paths [dict merge $paths [lindex $clist 1]]
      #Overwrite image list with tiled image to add watermarks or change format
      set argv $ckeys
      set tmplist [concat $tmplist $ckeys]
      #Add mesage to lastmessage
      append lstmsg "Collage done \n"
      #Set size to empty to avoid resizing
      set resizeval ""
    }
    foreach i $argv {
      incr m
      #Get outputname with suffix and extension
      if { $keep } { keepExtension $i }
      set io [setOutputName $i $outextension $prefixsel]
      set outname [lindex $io 0]
      if {[dict exists $paths $i]} {
        set origin [dict get $paths $i]
      } else {
        set origin [lindex $io 1]
      }
      set outputfile [append origin "/" $outname]
      puts "outputs $outputfile"
      #If output is ora we have to use calligraconverter
      if { [regexp {ora|kra|xcf} $outextension] } {
        if {!$keep } {
          eval exec calligraconverter --batch $i $outputfile 2> /dev/null
        }
      } else {
    #Get color space to avoid color shift
    set colorspace [lindex [split [ exec identify -quiet -format %r $i ] ] 1 ]
    #Run command
        eval exec convert -quiet {$i} $alpha -colorspace $colorspace $resizeval $watval -quality $sliderval {$outputfile}
        #Add messages to lastmessage
        #append lstmsg "$i converted to $io\n"
      }
    }
    #cleaning tmp files
    foreach tmpf $tmplist {  file delete $tmpf }
    append lstmsg "$m files converted"
 }
  alert ok info "Operation Done" $lstmsg
  exit
}
#Prepares output name adding Suffix or Prefix
#Checks if destination file exists and adds a standard suffix
proc setOutputName { fname fext { opreffix false } { orename false } {tmpdir false} } {
  global suffix
  set tmpsuffix $suffix
  set ext [file extension $fname]
  set finalname ""
  #Checks if path is defined as absolute path, like when we create a file in /tmp directory
  #Strips directory leaving file in current directory
  #if { [file pathtype $fname] == "absolute" } {
    #get filepath origin path
    set origpath [file dirname $fname]
    set fname [lindex [file split $fname] end]
  #}
  #Append suffix if user wrote something in entryfield
  if { [catch $tmpsuffix] && !$tmpdir} {
    if {$opreffix && $orename} {
    #Makes preffix instead of suffix
      set fname [append tmpsuffix _$fname]
    } elseif {$orename} {
    #Makes suffix but rename
      set fname [string map -nocase "$ext _$tmpsuffix$ext" $fname ]
    } elseif {$opreffix} {
      set newnam [string map -nocase "$ext .$fext" $fname ]
      set fname [append tmpsuffix _$newnam]
    } else { 
    append finalname _$tmpsuffix
    }
  }
  if {$orename} { return $fname }
  #If file exists we add string to avoid overwrites
  if { [file exists [string map -nocase "$ext $finalname.$fext" $fname ] ] } {
    append finalname "_artkFile_"
  }
  append finalname ".$fext"

  #If no extension we add the extension
  if { $ext == "" } {
    set fname [append fname $finalname]
  } else {
    #we search for the extension string and replace it with (suffix and/or date) and extension
    set fname [string map -nocase "$ext $finalname" $fname ]
  }
  #If file is called from tmpdir we return a tupple with the original file location
  set olist ""
  return [lappend olist $fname $origpath]
}
proc getOutputName { {indx 0} } {
  global outextension prefixsel argv calligralist inkscapelist
  #Concatenate both lists to always have an output example name
  set i [lindex [concat $argv $calligralist $inkscapelist] $indx]
  return [lindex [setOutputName $i $outextension $prefixsel] 0]
}

