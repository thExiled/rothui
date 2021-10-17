-- rVignette: core
-- zork, 2018

-----------------------------
-- Variables
-----------------------------

local A, L = ...

-----------------------------
-- Functions
-----------------------------

local function OnVignetteAdded(self,event,id)
  if not id then return end
  self.vignettes = self.vignettes or {}
  if self.vignettes[id] then return end
  local vignetteInfo = C_VignetteInfo.GetVignetteInfo(id)
  if not vignetteInfo then return end
  local info = C_Texture.GetAtlasInfo(vignetteInfo.atlasName)
  -- info = { filename, width, height, txLeft, txRight, txTop, txBottom}
  if not info.filename then return end
  local atlasWidth = info.width/(info.rightTexCoord-info.leftTexCoord)
  local atlasHeight = info.height/(info.bottomTexCoord-info.topTexCoord)
  local str = string.format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", info.filename, 0, 0, atlasWidth, atlasHeight, atlasWidth*info.leftTexCoord, atlasWidth*info.rightTexCoord, atlasHeight*info.topTexCoord, atlasHeight*info.bottomTexCoord)
  PlaySoundFile("Sound\\Interface\\RaidWarning.ogg")
  RaidNotice_AddMessage(RaidWarningFrame, str.." "..vignetteInfo.name.." spotted!", ChatTypeInfo["RAID_WARNING"])
  print(str.." "..vignetteInfo.name,"spotted!")
  self.vignettes[id] = true
end

-----------------------------
-- Init
-----------------------------

--eventHandler
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
eventHandler:SetScript("OnEvent", OnVignetteAdded)