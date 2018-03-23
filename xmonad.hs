-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

import System.IO
import System.Exit
import XMonad
import XMonad.Actions.CopyWindow            -- like cylons, except x windows
import XMonad.Actions.DynamicProjects
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Accordion
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.EwmhDesktops
import qualified XMonad.Hooks.EwmhDesktops as F

import XMonad.Prompt
import XMonad.Prompt.Ssh

toggleCopyToAll = wsContainingCopies >>= \ws -> case ws of
                [] -> windows copyToAll
                _ -> killAllOtherCopies


------------------------------------------------------------------------
-- Terminal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "urxvt"

-- The command to lock the screen or show the screensaver.
myScreensaver = "~/.xmonad/lock.sh ~/.xmonad/lock.png"

-- The command to take a selective screenshot, where you select
-- what you'd like to capture on the screen.
mySelectScreenshot = "select-screenshot"

-- The command to take a fullscreen screenshot.
myScreenshot = "screenshot"

-- The command to use as a launcher, to launch commands that don't have
-- preset keybindings.
myLauncher = "rofi -show run -lines 6  -opacity '80' -bc blue"

startPomodoro = "echo 25 15 > ~/.pomodoro_session"
stopPomodoro = "rm -f ~/.pomodoro_session"

toggleDisplay = "bash /home/alex/configs/toggle_display.sh"

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
myWorkspaces = ["1:term","2:web","3:chat","4:mysql","5:code"] ++ map show [6..9]

scratchpads = [
    NS "htop" "urxvt -e htop" (title =? "htop") defaultFloating ,

    NS "ncmpcpp" "urxvt -name ncmpcpp -e ncmpcpp" (resource =? "ncmpcpp")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

    NS "stardict" "stardict" (className =? "Stardict")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

    NS "popUpPythonShell" "urxvt -name popUpPythonShell -e python" (resource =? "popUpPythonShell")
        (customFloating $ W.RationalRect l t w h),

    NS "trello" "google-chrome-stable --app='https://trello.com/b/IA1QlXA3/daily-todo'"
        (resource =? "trello.com__b_IA1QlXA3_daily-todo")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

    NS "google-music" "google-chrome-stable --app='https://play.google.com/music/listen'"
        (resource =? "play.google.com__music_listen")
        (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,

    NS "keep" "google-chrome-stable --app='https://keep.google.com'"
        (resource =? "keep.google.com")
        (customFloating $ W.RationalRect (2/6) (2/6) (1/3) (2/3))
    ] where role = stringProperty "WM_WINDOW_ROLE"
            h = 0.3     -- terminal height, 30%
            w = 1       -- terminal width, 100%
            t = 1 - h   -- distance from top edge, 70%
            l = 1 - w   -- distance from left edge, 0%

------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook' = composeAll
    [ resource =? "Google-chrome"  --> doShift "2:web"
    , resource  =? "google-chrome"  --> doShift "2:web"
    , className =? "Firefox"  --> doShift "2:web"
    , className =? "TelegramDesktop"  --> doShift "3:chat"
    , className =? "Mattermost"  --> doShift "3:chat"
    , className =? "Mysql-workbench-bin"  --> doShift "4:mysql"
    , className =? "jetbrains-idea-ce"  --> doShift "5:code"
    , resource  =? "desktop_window" --> doIgnore

    , className =? "Steam"          --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "Xchat"          --> doShift "3:chat"
    , className =? "stalonetray"    --> doIgnore
    ,isFullscreen                   --> doFullFloat]

myNamedScratchpadManageHook = namedScratchpadManageHook scratchpads
myManageHook = myManageHook' <+> myNamedScratchpadManageHook

-- Projects
projects :: [Project]
projects =
    [ Project   { projectName       = "htop"
                , projectDirectory  = "~/"
                , projectStartHook  = Just $ do spawn "urxvt"
                                                spawn "urxvt -e htop"
                }
    ]

------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = spacing 2 $ avoidStruts $
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    noBorders(fullscreenFull Full)


------------------------------------------------------------------------
-- Colors and borders
-- Currently based on the ir_black theme.
--
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#3333ff"

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 2


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  [ ((modMask .|. shiftMask, xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using command specified by myScreensaver.
  , ((modMask .|. controlMask, xK_l),
     spawn myScreensaver)

  , ((modMask, xK_s),
     sshPrompt def)

  -- Spawn the launcher using command specified by myLauncher.
  -- Use this to launch programs without a key binding.
  , ((modMask, xK_p),
     spawn myLauncher)

  {--- Take a selective screenshot using the command specified by mySelectScreenshot.-}
  {-, ((modMask .|. shiftMask, xK_p),-}
     {-spawn mySelectScreenshot)-}

  -- Take a full screenshot using the command specified by myScreenshot.
  , ((modMask .|. controlMask .|. shiftMask, xK_s),
     spawn "scrot -s")

  -- Mute volume.
  , ((0, xF86XK_AudioMute),
     spawn "pamixer -t")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),
     spawn "pamixer -d 10")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume),
     spawn "pamixer -i 10")

  -- Audio previous.
  , ((0, 0x1008FF16),
     spawn "mpc prev")

  -- Play/pause.
  , ((0, 0x1008FF14),
     spawn "mpc toggle")

  -- Audio next.
  , ((0, 0x1008FF17),
     spawn "mpc next")

  -- Eject CD tray.
  , ((0, 0x1008FF2C),
     spawn "eject -T")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c),
     kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space),
     sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space),
     setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask .|. shiftMask , xK_r),
     refresh)

  -- Move focus to the next window.
  , ((modMask, xK_Tab),
     windows W.focusDown)

  -- Move focus to the next window.
  , ((modMask, xK_j),
     windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_k),
     windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m),
     windows W.focusMaster  )

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return),
     windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_j),
     windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_k),
     windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h),
     sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l),
     sendMessage Expand)

  -- Push window back into tiling.
  , ((modMask, xK_t),
     withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma),
     sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period),
     sendMessage (IncMasterN (-1)))

  , ((modMask .|. shiftMask, xK_g),
     switchProjectPrompt def)

  -- Toggle the status bar gap.
  -- TODO: update this binding with avoidStruts, ((modMask, xK_b),

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_q),
     io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask, xK_q),
     restart "xmonad" True)

  -- Start a pomodoro
  , ((modMask .|. shiftMask, xK_p),
     spawn startPomodoro)

  -- Stop a pomodoro
  , ((modMask .|. controlMask .|. shiftMask, xK_p),
     spawn stopPomodoro)

  -- scratchpad
  , ((modMask .|. shiftMask, xK_n),
     namedScratchpadAction scratchpads "popUpPythonShell")

  , ((modMask, xK_a),
     namedScratchpadAction scratchpads "ncmpcpp")

  , ((modMask .|. shiftMask , xK_t),
     namedScratchpadAction scratchpads "trello")

  , ((modMask, xK_g),
     namedScratchpadAction scratchpads "google-music")

  , ((modMask, xK_n),
     namedScratchpadAction scratchpads "keep")

  , ((modMask .|. controlMask .|. shiftMask, xK_t), namedScratchpadAction scratchpads "htop")
  , ((modMask .|. controlMask .|. shiftMask, xK_s), namedScratchpadAction scratchpads "stardict")
  , ((modMask .|. controlMask .|. shiftMask, xK_n), namedScratchpadAction scratchpads "notes")

  -- Toggle display in thinkpad
  , ((modMask .|. shiftMask, xK_d),
     spawn toggleDisplay)

  -- Toggle display in thinkpad
  , ((modMask , xK_c),
     toggleCopyToAll)

  ]
  ++

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_w, xK_e, xK_r] [1, 0, 2]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses   = False

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmonad $ dynamicProjects projects $ defaults {
      logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 50
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppLayout = (\str -> "")
          , ppSep = "  |  "
      }
      , manageHook = manageDocks <+> myManageHook
      , startupHook = setWMName "LG3D"
  }


------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    clickJustFocuses   = myClickJustFocuses,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = smartBorders $ myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook,
    handleEventHook    = docksEventHook <+> F.fullscreenEventHook
}
