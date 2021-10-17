
-- rMinimap: core
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, L = ...

L.addonName       = A
L.dragFrames      = {}
L.addonColor      = "00FFAA00"
L.addonShortcut   = "rmm"

local GameTooltip, C_AzeriteItem = GameTooltip, C_AzeriteItem

-----------------------------
-- Config
-----------------------------

local cfg = {
  scale = 1,
  point = { "TOPRIGHT", 0, 0},
}

-----------------------------
-- Init
-----------------------------

--MinimapCluster
MinimapCluster:SetScale(cfg.scale)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint(unpack(cfg.point))

--Minimap
local mediapath = "interface\\addons\\"..A.."\\media\\"
Minimap:SetMaskTexture(mediapath.."mask2")
Minimap:ClearAllPoints()
Minimap:SetPoint("CENTER")
Minimap:SetSize(190,190) --correct the cluster offset

--hide regions
MinimapBackdrop:Hide()
MinimapBorder:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapBorderTop:Hide()
MiniMapWorldMapButton:Hide()

--zone text
MinimapZoneText:SetPoint("TOP",0,-5)
MinimapZoneText:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")

--dungeon info
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMRIGHT",0,-37)
MiniMapInstanceDifficulty:SetScale(0.8)
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMRIGHT",0,-37)
GuildInstanceDifficulty:SetScale(0.7)
MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetPoint("BOTTOMRIGHT",Minimap,"BOTTOMRIGHT",0,-42)
MiniMapChallengeMode:SetScale(0.6)
MiniMapChallengeMode:SetAlpha(0.8)
MiniMapInstanceDifficulty:SetAlpha(0.8)
GuildInstanceDifficulty:SetAlpha(0.8)

--QueueStatusMinimapButton (lfi)
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:SetScale(1)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMLEFT",Minimap,0,0)
QueueStatusMinimapButtonBorder:Hide()
QueueStatusMinimapButton:SetHighlightTexture (nil)
QueueStatusMinimapButton:SetPushedTexture(nil)

--mail
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT",Minimap,-0,0)
MiniMapMailIcon:SetTexture(mediapath.."mail")
MiniMapMailBorder:SetTexture("Interface\\Calendar\\EventNotificationGlow")
MiniMapMailBorder:SetBlendMode("ADD")
MiniMapMailBorder:ClearAllPoints()
MiniMapMailBorder:SetPoint("CENTER",MiniMapMailFrame,0.5,1.5)
MiniMapMailBorder:SetSize(27,27)
MiniMapMailBorder:SetAlpha(0.5)

--MiniMapTracking
MiniMapTracking:SetParent(Minimap)
MiniMapTracking:SetScale(1)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPLEFT",Minimap,5,-5)
MiniMapTrackingButton:SetHighlightTexture (nil)
MiniMapTrackingButton:SetPushedTexture(nil)
MiniMapTrackingBackground:Hide()
MiniMapTrackingButtonBorder:Hide()

--MiniMapNorthTag
MinimapNorthTag:ClearAllPoints()
MinimapNorthTag:SetPoint("TOP",Minimap,0,-20)

--Blizzard_TimeManager
LoadAddOn("Blizzard_TimeManager")
TimeManagerClockButton:GetRegions():Hide()
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM",0,5)
TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
TimeManagerClockTicker:SetTextColor(0.8,0.8,0.6,1)

--GameTimeFrame
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:SetScale(0.6)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("TOPRIGHT",Minimap,-18,-18)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:GetNormalTexture():SetTexCoord(0,1,0,1)
GameTimeFrame:SetNormalTexture(mediapath.."calendar")
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture (nil)
local fs = GameTimeFrame:GetFontString()
fs:ClearAllPoints()
fs:SetPoint("CENTER",0,-5)
fs:SetFont(STANDARD_TEXT_FONT,20)
fs:SetTextColor(0.2,0.2,0.1,0.9)

--zoom
Minimap:EnableMouseWheel()
local function Zoom(self, direction)
  if(direction > 0) then Minimap_ZoomIn()
  else Minimap_ZoomOut() end
end
Minimap:SetScript("OnMouseWheel", Zoom)

--onenter/show
local function Show()
  GameTimeFrame:SetAlpha(0.9)
  MiniMapTracking:SetAlpha(0.9)
end
Minimap:SetScript("OnEnter", Show)

--onleave/hide
local lasttime = 0
local function Hide()
  if Minimap:IsMouseOver() then return end
  if time() == lasttime then return end
  GameTimeFrame:SetAlpha(0)
  MiniMapTracking:SetAlpha(0)
end
local function SetTimer()
  lasttime = time()
  C_Timer.After(1.5, Hide)
end
Minimap:SetScript("OnLeave", SetTimer)
rLib:RegisterCallback("PLAYER_ENTERING_WORLD", Hide)
Hide(Minimap)

--fps, latency, and coords string with experience mouseover
local f1 = CreateFrame("Frame", "rInfoStrings", Minimap)
f1:ClearAllPoints()
f1:SetPoint("BOTTOM", Minimap, 0, -5)

local t = f1:CreateFontString(nil, "BACKGROUND")
t:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
t:SetPoint("CENTER", f1)

f1.text = t;

local function rFPS()
  return floor(GetFramerate()).."fps"
end

local function rLatency()
  return select(3, GetNetStats()).."ms"
end

local function rZoneCoords()
  local coords
  if C_Map then
    local mapID = C_Map.GetBestMapForUnit("player")
    local mapPos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    local x, y = 0, 0

    if mapPos then
      x, y = mapPos:GetXY()
    end

    x = (mapPos and x) or 0
    y = (mapPos and y) or 0

    if x and y and x ~= 0 and y ~= 0 then
      coords = format("%.1f, %.1f", x*100, y*100)
    else 
      coords = "--.-, --.-"
    end
  end
  
  return coords
end

local function rUpdateStrings()
  f1.text:SetText(rZoneCoords().." / ".."|c009C907D"..rLatency().." "..rFPS().."|r")
  f1:SetHeight(f1.text:GetStringHeight())
  f1:SetWidth(f1.text:GetStringWidth())
end

local function rInfoStringOnEnter(self)
  -- GameTooltip:SetParent(f1)
  -- GameTooltip:ClearAllPoints()
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
  GameTooltip:AddLine(self:GetName(), 1, 0.5, 0, 1, 1, 1)
  --experience
  if UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled() then
    local cur, max = UnitXP("player"), UnitXPMax("player")
    local lvl = UnitLevel("player")
    local rested = GetXPExhaustion()
    GameTooltip:AddLine("Experience", 0, 1, 0.5, 1, 1, 1)
    GameTooltip:AddDoubleLine("Level", lvl, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Cur / Max", cur.." / "..max, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Needed", (max-cur), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Rested", rested, 1, 1, 1, 1, 1, 1)
  end
  --honor
  --if InActiveBattlefield() or IsInActiveWorldPVP() then
    local cur, max = UnitHonor("player"), UnitHonorMax("player")
    local lvl = UnitHonorLevel("player")
    GameTooltip:AddLine("Honor", 0, 1, 0.5, 1, 1, 1)
    GameTooltip:AddDoubleLine("Level", lvl, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Cur / Max", cur.." / "..max, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Needed", (max-cur), 1, 1, 1, 1, 1, 1)
  --end
  --reputation
  local name, standing, min, max, cur = GetWatchedFactionInfo()
  if name then
    GameTooltip:AddLine(name.." Reputation", 0, 1, 0.5, 1, 1, 1)
    GameTooltip:AddDoubleLine("Level", _G["FACTION_STANDING_LABEL"..standing], 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Cur / Max", cur.." / "..max, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine("Needed", (max-cur), 1, 1, 1, 1, 1, 1)
  end
  -- --azerite
  -- local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
  -- if azeriteItem then
  --   local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
  --   local lvl = C_AzeriteItem.GetPowerLevel(azeriteItem)
  --   GameTooltip:AddLine("Azerite", 0, 1, 0.5, 1, 1, 1)
  --   GameTooltip:AddDoubleLine("Level", lvl, 1, 1, 1, 1, 1, 1)
  --   GameTooltip:AddDoubleLine("Cur / Max", cur.." / "..max, 1, 1, 1, 1, 1, 1)
  --   GameTooltip:AddDoubleLine("Needed", (max-cur), 1, 1, 1, 1, 1, 1)
  -- end
  -- --islandweekly
  -- local iwqID = C_IslandsQueue.GetIslandsWeeklyQuestID()
  -- if iwqID and C_QuestLog.IsQuestFlaggedCompleted(iwqID) then
  --   GameTooltip:AddLine("Island Weekly", 0, 1, 0.5, 1, 1, 1)
  --   GameTooltip:AddDoubleLine("Status", "Finished", 1, 1, 1, 1, 1, 1)
  -- elseif iwqID then
  --   local _, _, _, cur, max = GetQuestObjectiveInfo(iwqID, 1, false)
  --   if max then
  --     GameTooltip:AddLine("Island Weekly", 0, 1, 0.5, 1, 1, 1)
  --     GameTooltip:AddDoubleLine("Cur / Max", cur.." / "..max, 1, 1, 1, 1, 1, 1)
  --     GameTooltip:AddDoubleLine("Needed", (max-cur), 1, 1, 1, 1, 1, 1)
  --   end
  -- end
  GameTooltip:Show()
end

local function rInfoStringOnLeave(self)
  GameTooltip:Hide()
end

local rInfoStringLoop = function(self)
  --timer
  local ag = self:CreateAnimationGroup()
  ag.anim = ag:CreateAnimation()
  ag.anim:SetDuration(1)
  ag:SetLooping("REPEAT")
  ag:SetScript("OnLoop", function(self, event, ...)
    rUpdateStrings()
  end)
  ag:Play()
end

local a = CreateFrame("Frame")
a:RegisterEvent("ADDON_LOADED")
a:SetScript("OnEvent", function(self, event, ...)
  f1:SetScript("OnEnter", rInfoStringOnEnter)
  f1:SetScript("OnLeave", rInfoStringOnLeave)
  rInfoStringLoop(self)
end)

--drag frame
rLib:CreateDragFrame(MinimapCluster, L.dragFrames, -2, true)

--create slash commands
rLib:CreateSlashCmd(L.addonName, L.addonShortcut, L.dragFrames, L.addonColor)