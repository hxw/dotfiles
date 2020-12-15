! .Xdefaults

! rxvt-unicode scheme

URxvt*geometry: 100x30

URxvt*saveLines: 2000

URxvt*transparent: False
URxvt*shading: 100

URxvt*borderColor: DarkBlue
URxvt*background: DarkBlue
URxvt*foreground: White

URxvt*cursorUnderline: True
URxvt*cursorBlink: True
URxvt*cursorColor: White
URxvt*cursorColor2: DarkBlue

URxvt*scrollstyle: rxvt
URxvt*scrollColor: White
URxvt*troughColor: Red
URxvt*scrollBar: True
URxvt*scrollBar_right: True
URxvt*scrollBar_floating: False
URxvt*thickness: 13

URxvt.iso14755: true
URxvt.iso14755_52: false


! key definitions
! ===============

! "menu" from old config: "ESC [ 2 7 ~"
! before change to XF86MenuKB
URxvt.keysym.XF86MenuKB: string:\033[27~


! colours
! =======

! black
URxvt.color0  : Black
URxvt.color8  : Grey41
! red
URxvt.color1  : Red
URxvt.color9  : Pink
! green
URxvt.color2  : ForestGreen
URxvt.color10 : SpringGreen2
! yellow
URxvt.color3  : Orange
URxvt.color11 : Yellow
! blue
URxvt.color4  : SkyBlue
URxvt.color12 : LightSkyBlue
! magenta
URxvt.color5  : Purple
URxvt.color13 : Magenta
! cyan
URxvt.color6  : DarkCyan
URxvt.color14 : Cyan
! white
URxvt.color7  : Grey60
URxvt.color15 : White


!! choose one pair of fonts
!! ========================

!! pkg install dejavu
!URxvt*font: xft:DejaVu Sans Mono:pixelsize=18
!URxvt*boldFont: xft:DejaVu Sans Mono:style=Bold:pixelsize=18

!! pkg install plex-ttf
!URxvt*font: xft:IBM Plex Mono:pixelsize=18
!URxvt*boldFont: xft:IBM Plex Mono:style=Bold:pixelsize=18

!! pkg install jetbrains-mono
!URxvt*font: xft:Jet Brains Mono:pixelsize=18
!URxvt*boldFont: xft:Jet Brains Mono:style=Bold:pixelsize=18

!! pkg install hack-font
!URxvt*font: xft:Hack:pixelsize=18
!URxvt*boldFont: xft:Hack:style=Bold:pixelsize=18

!! combination get better Unicode coverage
URxvt*font: xft:Jet Brains Mono:pixelsize=18,xft:DejaVu Sans Mono:pixelsize=18
URxvt*boldFont: xft:Jet Brains Mono:style=Bold:pixelsize=18,xft:DejaVu Sans Mono:style=Bold:pixelsize=18


! miscellaneous
! =============

!! amount to adjust the computed character width
!! negative to move characters closer together
!URxvt*letterSpace: -1

!URxvt.perl-ext-common: default,tabbed,matcher
URxvt.perl-ext-common : default,matcher

URxvt.urlLauncher     : firefox
URxvt.matcher.button  : 2

!URxvt.matcher.pattern.1:  \\bwww\\.[\\w-]+\\.[\\w./?&@#-]*[\\w/-]
!URxvt.matcher.pattern.2:  \\B(/\\S+?):(\\d+)(?=:|$)
!URxvt.matcher.launcher.2: gvim +$2 $1

URxvt.tabbed.tabbar-fg: 11
URxvt.tabbed.tabbar-bg: 7
URxvt.tabbed.tab-fg: 15
URxvt.tabbed.tab-bg: 4
