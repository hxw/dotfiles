-- xmonad.hs

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Layout.Circle
import XMonad.Layout.Spiral
import XMonad.Actions.WindowGo
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Data.Ratio


myLayoutHook = avoidStruts (Full ||| tiled ||| Mirror tiled ||| spiral (1 % 1) ||| Circle)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio = 2/3

     -- Percent of screen to increment by when resizing panes
     delta = 3/100


main = do
    xmproc <- spawnPipe "xmobar"

    xmonad $ defaultConfig
       { manageHook = manageDocks <+> manageHook defaultConfig
       --, layoutHook = avoidStruts  $  layoutHook defaultConfig
       , layoutHook = myLayoutHook
       , handleEventHook    = handleEventHook defaultConfig <+> docksEventHook
       , logHook = dynamicLogWithPP xmobarPP
                   { ppOutput = hPutStrLn xmproc
                   , ppTitle = xmobarColor "green" "" . shorten 40
                   , ppHiddenNoWindows = xmobarColor "grey" ""
                   }
       , modMask = mod4Mask     -- Rebind Mod to the Windows key
       } `additionalKeys`
       [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
       , ((mod4Mask, xK_Pause), spawn "xscreensaver-command -lock; xset dpms force off")
       , ((mod4Mask, xK_b), sendMessage ToggleStruts)            -- toggle xmobar
       , ((mod4Mask, xK_Print), spawn "sleep 0.2; scrot -s")
       -- , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
       -- , ((0, xK_Print), spawn "scrot")
       , ((mod4Mask, xK_c), runOrRaise "conlecterm" (className =? "Conlecterm"))
       , ((mod4Mask, xK_e), runOrRaise "emacs" (className =? "Emacs"))
       , ((mod4Mask, xK_f), runOrRaise "firefox" (className =? "Firefox"))
       , ((mod4Mask, xK_h), runOrRaise "hexchat" (className =? "Hexchat"))
       , ((mod4Mask, xK_p), spawn "dmenu_run -p 'run>' -fn '-Fixed-Bold-R-Normal-*-16-*-*-*-*-*-*-*' -sb grey25 -sf hotpink -nb blue -nf white")
       , ((mod4Mask, xK_w), runOrRaise "claws-mail" (className =? "Claws-mail"))
       ]
