
-- rObjectiveTracker: core
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, L = ...

L.addonName       = A
L.dragFrames      = {}
L.addonColor      = "00FF00AA"
L.addonShortcut   = "rot"

-----------------------------
-- Config
-----------------------------

local cfg = {
  scale = 1,
  point = { "RIGHT", -110, -100 },
  size = { 260, 500 },
  fader = {
    fadeInAlpha = 1,
    fadeInDuration = 0.3,
    fadeInSmooth = "OUT",
    fadeOutAlpha = 0,
    fadeOutDuration = 0.9,
    fadeOutSmooth = "OUT",
    fadeOutDelay = 0,
  },
  frameVisibility = "[combat] hide; show"
}

-----------------------------
-- Init
-----------------------------

--ObjectiveTrackerFrame
ObjectiveTrackerFrame:SetScale(cfg.scale)
ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint(unpack(cfg.point))
ObjectiveTrackerFrame:SetSize(unpack(cfg.size))

--drag frame
rLib:CreateDragResizeFrame(ObjectiveTrackerFrame, L.dragFrames, -2, true)

--frame visibility
ObjectiveTrackerFrame.frameVisibility = cfg.frameVisibility
ObjectiveTrackerFrame.frameVisibilityFunc = cfg.frameVisibilityFunc
RegisterStateDriver(ObjectiveTrackerFrame, cfg.frameVisibilityFunc or "visibility", cfg.frameVisibility)

--frame fader
rLib:CreateFrameFader(ObjectiveTrackerFrame, cfg.fader)

--create slash commands
rLib:CreateSlashCmd(L.addonName, L.addonShortcut, L.dragFrames, L.addonColor)