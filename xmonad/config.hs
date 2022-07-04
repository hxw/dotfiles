-- xmonad.hs

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Layout.Circle
import XMonad.Layout.Spiral
import XMonad.Actions.WindowGo
import qualified XMonad.StackSet as W
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

myManageHook :: ManageHook
myManageHook = composeAll
    [ (    role =? "gimp-toolbox"
       <||> (roleN 9) =? "gimp-dock"
       <||> role =? "gimp-image-window"
       <||> role =? "gimp-toolbox-color-dialog"
       <||> role =? "gimp-message-dialog"
      ) --> doFloat -- ) --> (ask >>= doF . W.sink)
    , (    (nameN 14) =? "Delete message"
       <||> (nameN 14) =? "Upcoming event"
       <||> (nameN 11) =? "New meeting"
       <||> (nameN  9) =? "Overwrite"
       <||> (nameN 19) =? "Rebuild folder tree"
      ) --> doFloat
    ]
  where role = stringProperty "WM_WINDOW_ROLE"
        roleN n = do
          p <- stringProperty "WM_WINDOW_ROLE"
          return $ take n p
        name = stringProperty "WM_NAME"
        nameN n = do
          p <- stringProperty "WM_NAME"
          return $ take n p


main = do
    xmproc <- spawnPipe "xmobar"

    xmonad $ def
       { manageHook = myManageHook <+> manageDocks <+> manageHook def
       --, layoutHook = avoidStruts $ layoutHook def
       , layoutHook = myLayoutHook
       --, handleEventHook = handleEventHook def <+> docksEventHook
       , logHook = dynamicLogWithPP xmobarPP
                   { ppOutput = hPutStrLn xmproc
                   , ppTitle = xmobarColor "green" "" . shorten 40
                   , ppHiddenNoWindows = xmobarColor "grey" ""
                   }
       , modMask = mod4Mask     -- Rebind Mod to the Windows key
       } `additionalKeys`
       [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
       , ((mod4Mask, xK_Pause), spawn "xscreensaver-command -lock; xset dpms force off")
       , ((mod4Mask, xK_Print), spawn "cd ; scrot -s -e 'mv $f ./Screenshots/'")
       -- , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
       -- , ((0, xK_Print), spawn "scrot")
       , ((mod4Mask, xK_a), runOrRaise "audacity" (className =? "Audacity"))
       , ((mod4Mask, xK_b), sendMessage ToggleStruts)            -- toggle xmobar
       , ((mod4Mask, xK_c), runOrRaise "conlecterm" (className =? "Conlecterm"))
       , ((mod4Mask, xK_e), runOrRaise "emacs" (className =? "Emacs"))
       , ((mod4Mask, xK_f), runOrRaise "firefox" (className =? "firefox"))
       , ((mod4Mask, xK_h), runOrRaise "hexchat" (className =? "Hexchat"))
       , ((mod4Mask, xK_p), spawn "dmenu_run -p 'run>' -fn '-Fixed-Bold-R-Normal-*-16-*-*-*-*-*-*-*' -sb grey25 -sf hotpink -nb blue -nf white")
       , ((mod4Mask, xK_u), runOrRaise "urxvt" (className =? "URxvt"))
       , ((mod4Mask, xK_v), raise (className =? "Ssvnc"))
       , ((mod4Mask, xK_w), runOrRaise "claws-mail" (className =? "Claws-mail"))
       , ((mod4Mask, xK_x), runOrRaise "xterm" (className =? "XTerm"))
       ]
