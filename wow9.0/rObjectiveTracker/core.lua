
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
  point = { "TOPLEFT", 25, -25 },
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
  frameVisibility = "custom [group:raid] hide; [combat] hide; show"
}

-----------------------------
-- Init
-----------------------------

local frame = CreateFrame("Frame", A.."Parent", UIParent)
frame:SetScale(cfg.scale)
frame:SetPoint(unpack(cfg.point))
frame:SetSize(unpack(cfg.size))

--ObjectiveTrackerFrame
ObjectiveTrackerFrame:SetParent(frame)
ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint("CENTER")
ObjectiveTrackerFrame:SetSize(unpack(cfg.size))
ObjectiveTrackerFrame.ignoreFramePositionManager = true

hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
	if parent ~= frame then
		ObjectiveTrackerFrame:ClearAllPoints()
		ObjectiveTrackerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -25)
	end
end)

--drag frame
-- rLib:CreateDragResizeFrame(ObjectiveTrackerFrame, L.dragFrames, -2, true)

--frame visibility
ObjectiveTrackerFrame.frameVisibility = cfg.frameVisibility
ObjectiveTrackerFrame.frameVisibilityFunc = cfg.frameVisibilityFunc
RegisterStateDriver(ObjectiveTrackerFrame, cfg.frameVisibilityFunc or "visibility", cfg.frameVisibility)

--frame fader
rLib:CreateFrameFader(ObjectiveTrackerFrame, cfg.fader)

--create slash commands
rLib:CreateSlashCmd(L.addonName, L.addonShortcut, L.dragFrames, L.addonColor)