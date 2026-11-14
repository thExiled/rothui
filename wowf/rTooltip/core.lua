
-- rTooltip: core
-- zork, 2019

-----------------------------
-- Variables
-----------------------------

local A, L = ...

local unpack, type, select = unpack, type, select
local RAID_CLASS_COLORS, FACTION_BAR_COLORS, ICON_LIST = RAID_CLASS_COLORS, FACTION_BAR_COLORS, ICON_LIST
local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar
local classColorHex, factionColorHex, barColor = {}, {}, nil

-----------------------------
-- Functions
-----------------------------

local function GetHexColor(color)
  local r, g, b
  if color.r then
    r, g, b = color.r, color.g, color.b
  else
    r, g, b = unpack(color)
  end
  return ("%.2x%.2x%.2x"):format(r * 255, g * 255, b * 255)
end

local function GetTooltipLine(tooltip, index)
  local name = tooltip:GetName()
  return name and _G[name .. "TextLeft" .. index]
end

local function GetTarget(unit)
  if UnitIsUnit(unit, "player") then
    return ("|cffff0000%s|r"):format("<YOU>")
  elseif UnitIsPlayer(unit) then
    local _, class = UnitClass(unit)
    local color = classColorHex[class]
    if color then
      return ("|cff%s%s|r"):format(color, UnitName(unit))
    end
  else
    local reaction = UnitReaction(unit, "player")
    local color = reaction and factionColorHex[reaction]
    if color then
      return ("|cff%s%s|r"):format(color, UnitName(unit))
    end
  end
  local name = UnitName(unit)
  if name then
    return ("|cffffffff%s|r"):format(name)
  else
    return "Unknown"
  end
end

local function OnTooltipSetUnit(self)
  local _, unit = self:GetUnit()
  if not unit then return end
  barColor = nil
  local textLeft1 = GetTooltipLine(self, 1)
  local textLeft2 = GetTooltipLine(self, 2)
  local textLeft3 = GetTooltipLine(self, 3)
  --color tooltip textleft2..8
  for i = 2, 8 do
    local line = GetTooltipLine(self, i)
    if line then
      line:SetTextColor(unpack(L.C.textColor))
    end
  end
  --position raidicon
  --local raidIconIndex = GetRaidTargetIndex(unit)
  --if raidIconIndex then
  --  GameTooltipTextLeft1:SetText(("%s %s"):format(ICON_LIST[raidIconIndex].."14|t", unitName))
  --end
  if not UnitIsPlayer(unit) then
    --unit is not a player
    --color textleft1 and statusbar by faction color
    local reaction = UnitReaction(unit, "player")
    if reaction then
      local color = FACTION_BAR_COLORS[reaction]
      if color and textLeft1 then
        barColor = color
        if GameTooltipStatusBar then
          GameTooltipStatusBar:SetStatusBarColor(color.r,color.g,color.b)
        end
        textLeft1:SetTextColor(color.r,color.g,color.b)
      end
    end
    --color textleft2 by classificationcolor
    local unitClassification = UnitClassification(unit)
    local levelLine
    if textLeft2 and string.find(textLeft2:GetText() or "empty", "%a%s%d") then
      levelLine = textLeft2
    elseif textLeft3 and string.find(textLeft3:GetText() or "empty", "%a%s%d") then
      if textLeft2 then
        textLeft2:SetTextColor(unpack(L.C.guildColor)) --seems like the npc has a description, use the guild color for this
      end
      levelLine = textLeft3
    end
    if levelLine then
      local l = UnitLevel(unit)
      local color = GetCreatureDifficultyColor((l and l > 0) and l or 999)
      levelLine:SetTextColor(color.r,color.g,color.b)
    end
    if unitClassification == "worldboss" or UnitLevel(unit) == -1 then
      self:AppendText(" |cffff0000{B}|r")
      if textLeft2 then
        textLeft2:SetTextColor(unpack(L.C.bossColor))
      end
    elseif unitClassification == "rare" then
      self:AppendText(" |cffff9900{R}|r")
    elseif unitClassification == "rareelite" then
      self:AppendText(" |cffff0000{R+}|r")
    elseif unitClassification == "elite" then
      self:AppendText(" |cffff6666{E}|r")
    end
  else
    --unit is any player
    local _, unitClass = UnitClass(unit)
    --color textleft1 and statusbar by class color
    local color = unitClass and RAID_CLASS_COLORS[unitClass]
    if color then
      barColor = color
      if GameTooltipStatusBar then
        GameTooltipStatusBar:SetStatusBarColor(color.r,color.g,color.b)
      end
      if textLeft1 then
        textLeft1:SetTextColor(color.r,color.g,color.b)
      end
    end
    --color textleft2 by guildcolor
    local unitGuild = GetGuildInfo(unit)
    local l = UnitLevel(unit)
    color = GetCreatureDifficultyColor((l and l > 0) and l or 999)
    if unitGuild and textLeft2 then
      --move level line to a new one
      self:AddLine(textLeft2:GetText(), color.r,color.g,color.b)
      --add guild info
      textLeft2:SetText("<"..unitGuild..">")
      textLeft2:SetTextColor(unpack(L.C.guildColor))
    end
    local levelLine = unitGuild and textLeft3 or textLeft2
    if levelLine then
      levelLine:SetTextColor(color.r,color.g,color.b)
    end
    --afk?
    if UnitIsAFK(unit) then
      self:AppendText((" |cff%s<AFK>|r"):format(L.C.afkColorHex))
    end
  end
  --dead?
  if UnitIsDeadOrGhost(unit) then
    if textLeft1 then
      textLeft1:SetTextColor(unpack(L.C.deadColor))
    end
  end
  --target line
  if (UnitExists(unit.."target")) then
    self:AddDoubleLine(("|cff%s%s|r"):format(L.C.targetColorHex, "Target"),GetTarget(unit.."target") or "Unknown")
  end
end

local function SetBackdropStyle(self,style)
  if self.TopOverlay then self.TopOverlay:Hide() end
  if self.BottomOverlay then self.BottomOverlay:Hide() end
  if not self.SetBackdrop and BackdropTemplateMixin and Mixin then
    Mixin(self, BackdropTemplateMixin)
  end
  if not self.SetBackdrop then return end
  self:SetBackdrop(L.C.backdrop)
  self:SetBackdropColor(unpack(L.C.backdrop.bgColor))
  local _, itemLink
  if self.GetItem then
    _, itemLink = self:GetItem()
  end
  if itemLink and GetItemInfo and GetItemQualityColor then
    local _, _, itemRarity = GetItemInfo(itemLink)
    if itemRarity then
      local r,g,b = GetItemQualityColor(itemRarity)
      self:SetBackdropBorderColor(r,g,b,L.C.backdrop.itemBorderColorAlpha)
    else
      self:SetBackdropBorderColor(unpack(L.C.backdrop.borderColor))
    end
  else
    --no item, use default border
    self:SetBackdropBorderColor(unpack(L.C.backdrop.borderColor))
  end
end

local function OnTooltipCleared(self)
  if self == GameTooltip then
    barColor = nil
  end
  SetBackdropStyle(self)
end

local function SetStatusBarColor(self,r,g,b)
  if not barColor then return end
  if r == barColor.r and g == barColor.g and b == barColor.b then return end
  self:SetStatusBarColor(barColor.r,barColor.g,barColor.b)
end

-----------------------------
-- Init
-----------------------------

--hex class colors
for class, color in next, RAID_CLASS_COLORS do
  classColorHex[class] = GetHexColor(color)
end
--hex reaction colors
--for idx, color in next, FACTION_BAR_COLORS do
for i = 1, #FACTION_BAR_COLORS do
  factionColorHex[i] = GetHexColor(FACTION_BAR_COLORS[i])
end

L.C.targetColorHex = GetHexColor(L.C.targetColor)
L.C.afkColorHex = GetHexColor(L.C.afkColor)

if GameTooltipHeaderText then
  GameTooltipHeaderText:SetFont(L.C.fontFamily, 14, "OUTLINE")
  GameTooltipHeaderText:SetShadowOffset(1,-2)
  GameTooltipHeaderText:SetShadowColor(0,0,0,0.75)
end
if GameTooltipText then
  GameTooltipText:SetFont(L.C.fontFamily, 12, "OUTLINE")
  GameTooltipText:SetShadowOffset(1,-2)
  GameTooltipText:SetShadowColor(0,0,0,0.75)
end
if Tooltip_Small then
  Tooltip_Small:SetFont(L.C.fontFamily, 11, "OUTLINE")
  Tooltip_Small:SetShadowOffset(1,-2)
  Tooltip_Small:SetShadowColor(0,0,0,0.75)
end

--gametooltip statusbar
if GameTooltipStatusBar then
  GameTooltipStatusBar:ClearAllPoints()
  GameTooltipStatusBar:SetPoint("LEFT",5,0)
  GameTooltipStatusBar:SetPoint("RIGHT",-5,0)
  GameTooltipStatusBar:SetPoint("TOP",0,-2.5)
  GameTooltipStatusBar:SetHeight(4)
  --gametooltip statusbar bg
  GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil,"BACKGROUND",nil,-8)
  GameTooltipStatusBar.bg:SetAllPoints()
  GameTooltipStatusBar.bg:SetColorTexture(1,1,1)
  GameTooltipStatusBar.bg:SetVertexColor(0,0,0,0.5)
end

--GameTooltipStatusBar:SetStatusBarColor()
if GameTooltipStatusBar then
  hooksecurefunc(GameTooltipStatusBar,"SetStatusBarColor", SetStatusBarColor)
end
--SharedTooltip_SetBackdropStyle
if SharedTooltip_SetBackdropStyle then
  hooksecurefunc("SharedTooltip_SetBackdropStyle", SetBackdropStyle)
end
--OnTooltipSetUnit
if TooltipDataProcessor and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
elseif GameTooltip:HasScript("OnTooltipSetUnit") then
  GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
end

--loop over tooltips
local tooltips = { GameTooltip,ShoppingTooltip1,ShoppingTooltip2,ItemRefTooltip,ItemRefShoppingTooltip1,ItemRefShoppingTooltip2,WorldMapTooltip,
WorldMapCompareTooltip1,WorldMapCompareTooltip2,SmallTextTooltip }
for i, tooltip in next, tooltips do
  if tooltip then
    tooltip:SetScale(L.C.scale)
    if tooltip:HasScript("OnTooltipCleared") then
      tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
    end
  end
end

--loop over menues
local menues = {
  DropDownList1MenuBackdrop,
  DropDownList2MenuBackdrop,
}
for i, menu in next, menues do
  if menu then
    menu:SetScale(L.C.scale)
  end
end

--spellid line

--func TooltipAddSpellID
local function TooltipAddSpellID(self,spellid)
  if not spellid or not self then return end
  self:AddDoubleLine("|cff0099ffspellid|r",spellid)
  self:Show()
end

local function GetAuraSpellID(unit, index, filter, auraType)
  if C_UnitAuras then
    local getter = C_UnitAuras["Get" .. auraType .. "DataByIndex"]
    if getter then
      local result = { getter(unit, index, filter) }
      if type(result[1]) == "table" then
        return result[1].spellId
      end
      return result[10]
    end
    if C_UnitAuras.GetAuraDataByIndex then
      local result = { C_UnitAuras.GetAuraDataByIndex(unit, index, filter) }
      if type(result[1]) == "table" then
        return result[1].spellId
      end
      return result[10]
    end
  end
  local getter = _G[auraType == "Buff" and "UnitBuff" or auraType == "Debuff" and "UnitDebuff" or "UnitAura"]
  if getter then
    return select(10, getter(unit, index, filter))
  end
end

--hooksecurefunc GameTooltip SetUnitBuff
if GameTooltip.SetUnitBuff then
  hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unit, index, filter)
    TooltipAddSpellID(self, GetAuraSpellID(unit, index, filter, "Buff"))
  end)
end

--hooksecurefunc GameTooltip SetUnitDebuff
if GameTooltip.SetUnitDebuff then
  hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unit, index, filter)
    TooltipAddSpellID(self, GetAuraSpellID(unit, index, filter, "Debuff"))
  end)
end

--hooksecurefunc GameTooltip SetUnitAura
if GameTooltip.SetUnitAura then
  hooksecurefunc(GameTooltip, "SetUnitAura", function(self, unit, index, filter)
    TooltipAddSpellID(self, GetAuraSpellID(unit, index, filter, "Aura"))
  end)
end

--hooksecurefunc SetItemRef
if SetItemRef then
  hooksecurefunc("SetItemRef", function(link)
    if type(link) ~= "string" then return end
    local linkType, value = link:match("(%a+):(.+)")
    if linkType == "spell" then
      TooltipAddSpellID(ItemRefTooltip,value:match("([^:]+)"))
    end
  end)
end

--HookScript GameTooltip OnTooltipSetSpell
local function OnTooltipSetSpell(self, data)
  local spellID = data and data.id
  if not spellID and self.GetSpell then
    spellID = select(2, self:GetSpell())
  end
  TooltipAddSpellID(self, spellID)
end
if TooltipDataProcessor and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
elseif GameTooltip:HasScript("OnTooltipSetSpell") then
  GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
end
