--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--
import           Data.Monoid
import           System.Exit
import           XMonad

import qualified Data.Map                         as M

-- Layout
import qualified XMonad.Layout.Fullscreen         as FS
import           XMonad.Layout.Gaps
import           XMonad.Layout.Spacing
import XMonad.Layout.Roledex
import XMonad.Layout.Spiral
import qualified XMonad.StackSet                  as W

-- Actions
import           XMonad.Actions.CycleWS
import           XMonad.Actions.DynamicWorkspaces
import           XMonad.Actions.FloatKeys
import qualified XMonad.Actions.Search            as S

import           XMonad.Util.EZConfig             (additionalKeysP)
import           XMonad.Util.NamedScratchpad

-- Utils
import           XMonad.Util.SpawnOnce
import           XMonad.Util.WorkspaceCompare     (getSortByIndex)

-- Hooks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.Place
import           XMonad.Hooks.SetWMName

-- dbus
import qualified Codec.Binary.UTF8.String         as UTF8
import qualified DBus                             as D
import qualified DBus.Client                      as D

-- config
import           XMonad.Config.Desktop

import           Control.Monad
import           Data.List
import qualified Data.Map                         as M
import           Graphics.X11.ExtraTypes.XF86
import           System.IO
import           XMonad.Actions.CycleWS
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageHelpers
import qualified XMonad.Layout.Fullscreen         as FS
import           XMonad.Layout.NoBorders
import qualified XMonad.StackSet                  as W
import           XMonad.Util.Run                  (spawnPipe)

import           XMonad.Config.Desktop
import           XMonad.Hooks.EwmhDesktops        (ewmh, fullscreenEventHook)
import           XMonad.Hooks.ManageDocks
import           XMonad.Util.SpawnOnce

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#dddddd"

myFocusedBorderColor = "#ff0000"

-- Helper functions
getSink = "pactl list sinks | grep RUNNING -a1 | head -n 1 | cut -d '#' -f 2"

-- cratchpads
myScratchPads =
  [ NS "term" spawnTerm findTerm manageScratch
  , NS "bt" spawnBT findBT manageScratch
  , NS "audio" spawnPavu findPavu manageScratch
  , NS "record" spawnScreenRecorder findScreenRecorder manageScratch
  ]
  where
    -- Terminal (st)
    spawnTerm = "kitty --title scratchpad"
    findTerm = title =? "scratchpad"
    -- Music player (ncmpcpp)
    spawnBT = "blueman-manager"
    findBT = className =? "Blueman-manager"
    -- Audio mixer (pulseaudio)
    spawnPavu = "pavucontrol"
    findPavu = className =? "Pavucontrol"
    -- Simple Screen Recorder
    spawnScreenRecorder = "simplescreenrecorder"
    findScreenRecorder = className =? "SimpleScreenRecorder"
    manageScratch =
      customFloating $ W.RationalRect (1 / 6) (1 / 6) (2/3) (2 / 3) -- where center w h = W.RationalRect ((1 - w) / 2) ((1 - h) / 2) w h

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
-- Using Xmonad.Util.EZConfig module which allows keybindings
-- to be written in simpler, emacs-like format.
getSortByIndexNoSP = fmap (. namedScratchpadFilterOutWorkspace) getSortByIndex

-- Function to move to next non-empty WS skipping NSP.
nextNonEmptyWS =
  findWorkspace getSortByIndexNoSP Next HiddenNonEmptyWS 1 >>= \t ->
    windows . W.view $ t

-- Function to move to previous non-empty WS skipping NSP.
prevNonEmptyWS =
  findWorkspace getSortByIndexNoSP Prev HiddenNonEmptyWS 1 >>= \t ->
    windows . W.view $ t

-- Function to move focused  window to next empty WS skipping NSP and move to that WS.
shiftToNextEmptyWS =
  findWorkspace getSortByIndexNoSP Next EmptyWS 1 >>= \t ->
    (windows . W.shift $ t) >> (windows . W.greedyView $ t)

-- Function to move focused window to previous empty WS skipping NSP and move to that WS.
shiftToPrevEmptyWS =
  findWorkspace getSortByIndexNoSP Prev EmptyWS 1 >>= \t ->
    (windows . W.shift $ t) >> (windows . W.greedyView $ t)

myKeys :: [(String, X ())]
myKeys
    -- launch a terminal
 =
  [ ("M-<Return>", spawn myTerminal)
  , ( "M-d"
    , spawn
        "rofi -combi-modi window,drun,run -show combi -fuzzy -hide-scrollbar")
    -- close focused window
  , ("M-q", kill)
     -- Rotate through the available layout algorithms
  , ("M-<Space>", sendMessage NextLayout)
    -- --  Reset the layouts on the current workspace to default
    -- , ("M-S-<Space>", setLayout myLayout)
    -- Resize viewed windows to the correct size
  , ("M-n", refresh)
    -- Move focus to the next window
  , ("M-j", windows W.focusDown)
    -- Move focus to the previous window
  , ("M-k", windows W.focusUp)
    -- Move focus to the master window
  , ("M-m", windows W.focusMaster)
    -- Swap the focused window and the master window
  , ("M-S-<Return>", windows W.swapMaster)
    -- Swap the focused window with the next window
  , ("M-S-j", windows W.swapDown)
    -- Swap the focused window with the previous window
  , ("M-S-k", windows W.swapUp)
    -- Shrink the master area
  , ("M-h", sendMessage Shrink)
    -- Expand the master area
  , ("M-l", sendMessage Expand)
    -- Push window back into tiling
  , ("M-t", withFocused $ windows . W.sink)
    -- -- Increment the number of windows in the master area
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- -- Deincrement the number of windows in the master area
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.f
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)
    -- Quit xmonad
  , ("M-S-q", io exitSuccess)
    -- Restart xmonad
  , ("M-S-c", spawn "xmonad --recompile; xmonad --restart")
    -- , ("M-S-/", spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
  , ( "<XF86AudioRaiseVolume>"
    , spawn
        "pactl set-sink-volume `eval pactl list sinks | grep RUNNING -a1 | head -n 1 | cut -d '#' -f 2` +2%")
  , ( "<XF86AudioLowerVolume>"
    , spawn
        "pactl set-sink-volume `eval pactl list sinks | grep RUNNING -a1 | head -n 1 | cut -d '#' -f 2` -2%")
  , ("<XF86AudioNext>", spawn "playerctl next")
  , ("<XF86AudioPrev>", spawn "playerctl previous")
  , ("<XF86AudioPlay>", spawn "playerctl play-pause")
  , ("<Print>", spawn "sleep 0.5 && scrot -s ~/foo.png && xclip -selection c -t image/png ~/foo.png && /bin/rm ~/foo.png")
  , ("M-<Print>", spawn "sleep 0.5 && scrot 'FULL_%s_%d-%m-%Y_$wx$h.png' -e 'mv $f ~/Pictures/Screenshots/'")
  , ("M-o", namedScratchpadAction myScratchPads "term")
  , ("M-S-a", namedScratchpadAction myScratchPads "audio")
  , ("M-S-r", namedScratchpadAction myScratchPads "record")
  , ("M-<Tab>", toggleWS' ["NSP"]) -- Toggle to the previous WS excluding NSP
  , ("M-.", nextNonEmptyWS) -- Move to next non-empty WS skipping NSP
  , ("M-,", prevNonEmptyWS) -- Move to previous non-empty WS skipping NSP
  , ("M-S-.", shiftToNextEmptyWS) -- Shift focused window to next empty WS skipping NSP and move to that WS
  , ("M-S-,", shiftToPrevEmptyWS) -- Shift focused window to previous empty WS skipping NSP and move to that WS
  , ("M-S-l", spawn "betterlockscreen -l && sleep 1")
  , ("M-e", spawn "nautilus")
  ]
    -- ++
    -- --
    -- -- mod-[1..9], Switch to workspace N
    -- -- mod-shift-[1..9], Move client to workspace N
    -- --
    -- [((m .|. modm, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    -- ++
    -- --
    -- -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    -- --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings XConfig {XMonad.modMask = modm} =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1)
      , \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ( (modm, button3)
      , \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (tiled ||| (smartSpacing 5 $ spiral (3/4)) ||| Full ||| Roledex)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = smartSpacing 5 $ Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:
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
myManageHook = composeAll
    [ className =? "Gimp"           --> doFloat
    , className =? "transmission-gtk" --> doFloat
    , className =? "mpv" --> doFloat
    , fmap (isInfixOf "Pinentry") className --> doFloat
    , fmap (isInfixOf "MATLAB") className <&&> fmap (not . isInfixOf "MATLAB") (stringProperty "WM_NAME") --> doFloat
    , fmap (isInfixOf "show.py") (stringProperty "WM_NAME") --> doFullFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "kupfer.py"      --> doIgnore
    , className =? "foobar"      --> doShift "sfx"
    , className =? "scratchpad"      --> doIgnore
    , title =? "foobar"      --> doShift "sfx"
    , fmap (isInfixOf "display") appCommand --> doFloat
    , fmap (isInfixOf "feh") appCommand --> doFloat
    --, (className =? "" <&&> title =? "") --> doShift "sfx" -- Spotify: https://bbs.archlinux.org/viewtopic.php?id=204636
    , (stringProperty "WM_WINDOW_ROLE" =? "GtkFileChooserDialog") --> doFullFloat
    , isFullscreen                  --> doFullFloat
    , FS.fullscreenManageHook
    ]
    where
    appCommand = stringProperty "WM_COMMAND"

------------------------------------------------------------------------
-- Event handling
-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
-- myLogHook :: D.Client -> PP
myLogHook dbus =
  def
    { ppOutput = dbusOutput dbus
    -- , ppCurrent = wrap ("%{B" ++ bg2 ++ "} ") " %{B-}"
    -- , ppVisible = wrap ("%{B" ++ bg1 ++ "} ") " %{B-}"
    -- , ppUrgent = wrap ("%{F" ++ red ++ "} ") " %{F-}"
    -- , ppHidden = wrap " " " "
    , ppWsSep = ""
    , ppSep = " : "
    , ppTitle = shorten 40
    }

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
  let signal =
        (D.signal objectPath interfaceName memberName)
          {D.signalBody = [D.toVariant $ UTF8.decodeString str]}
  D.emit dbus signal
  where
    objectPath = D.objectPath_ "/org/xmonad/Log"
    interfaceName = D.interfaceName_ "org.xmonad.Log"
    memberName = D.memberName_ "Update"

------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = do
  spawnOnce "feh --bg-fill ~/dotfiles/wallpaper.png"
  spawnOnce "picom --experimental-backend"
  spawnOnce "udiskie -a"
  spawnOnce "emacs --daemon"
  setWMName "xmonad"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  dbus <- D.connectSession
  -- Request access to the DBus name
  D.requestName
    dbus
    (D.busName_ "org.xmonad.log")
    [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  xmonad $ docks $ ewmh
    desktopConfig
      { terminal = myTerminal
      , focusFollowsMouse = myFocusFollowsMouse
      , clickJustFocuses = myClickJustFocuses
      , borderWidth = myBorderWidth
      , modMask = myModMask
      , workspaces = myWorkspaces
      , normalBorderColor = myNormalBorderColor
      , focusedBorderColor = myFocusedBorderColor
      , mouseBindings = myMouseBindings
      -- hooks, s
      , layoutHook = desktopLayoutModifiers $ noBorders $ myLayout
      , manageHook =
          placeHook (smart (0.5, 0.5)) <+>
          manageDocks <+> myManageHook <+> manageHook def
      , handleEventHook = myEventHook <+> fullscreenEventHook
      , logHook = dynamicLogWithPP (myLogHook dbus)
      , startupHook = myStartupHook
      } `additionalKeysP`
    myKeys
