local _, PlayerClass = UnitClass'player'
local unpack = unpack

local ClassPowerID = Enum.PowerType.Runes or 6
local ClassPowerType = 'RUNES'

local runemap = {1, 2, 3, 4, 5, 6}
local hasSortOrder = false

local function onUpdate(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
end

local function ascSort(runeAID, runeBID)
  local runeAStart, _, runeARuneReady = GetRuneCooldown(runeAID)
  local runeBStart, _, runeBRuneReady = GetRuneCooldown(runeBID)
  if(runeARuneReady ~= runeBRuneReady) then
    return runeARuneReady
  elseif(runeAStart ~= runeBStart) then
    return runeAStart < runeBStart
  else
    return runeAID < runeBID
  end
end

local function descSort(runeAID, runeBID)
  local runeAStart, _, runeARuneReady = GetRuneCooldown(runeAID)
  local runeBStart, _, runeBRuneReady = GetRuneCooldown(runeBID)
  if(runeARuneReady ~= runeBRuneReady) then
    return runeBRuneReady
  elseif(runeAStart ~= runeBStart) then
    return runeAStart > runeBStart
  else
    return runeAID > runeBID
  end
end

local function CreateSplit(self,i)
  local bar = self.rRuneBar
  local split = bar:CreateTexture()
  split:SetTexture(self.cfg.classbar.splits.texture)
  split:SetSize(unpack(self.cfg.classbar.splits.size))
  split:SetVertexColor(unpack(self.cfg.classbar.splits.color))
  local layer, sublayer = bar:GetStatusBarTexture():GetDrawLayer()
  split:SetDrawLayer(layer,sublayer+1)
  bar.splits[i] = split
  return split
end

local function UpdateSplits(self,maxSegments)
  if not self.cfg.classbar.splits or not self.cfg.classbar.splits.enabled then return end
  local bar = self.rRuneBar
  if bar.maxSegments == maxSegments then return end
  bar.maxSegments = maxSegments
  if not maxSegments or maxSegments < 2 then
    if not bar.splits then return end
    for i=1,8 do
      if bar.splits[i] and bar.splits[i]:IsShown() then
        bar.splits[i]:Hide()
      end
    end
    return
  end
  
  if maxSegments > 8 then maxSegments = 5 end --anything above 8 will be split into 5 parts of 20%.
  if not bar.splits then bar.splits = {} end
  local p = bar:GetWidth()/maxSegments
  for i=1,8 do
    if i>maxSegments-1 then
      if bar.splits[i] and bar.splits[i]:IsShown() then
        bar.splits[i]:Hide()
      end
    else
      local split = bar.splits[i] or CreateSplit(self,i)
      split:SetPoint("CENTER",bar,"LEFT",p*i,0)
      if not split:IsShown() then split:Show() end
    end
  end
end

local function Update(self, event, unit, powerType)
  if(not (self.unit == unit and (unit == 'player' and powerType == ClassPowerType
    or unit == 'vehicle' and powerType == 'COMBO_POINTS'))) then
    return
  end
  if event == 'ClassPowerDisable' then return end
  local element = self.rRuneBar

  local ppcur, ppmax
  ppcur = UnitPower('player', ClassPowerID, true) or 0
  ppmax = UnitPowerMax('player', ClassPowerID, true)
  
  UpdateSplits(self, UnitPowerMax('player', ClassPowerID))

  if ppcur == 0 then
    --element:Hide()
  else
    local color = oUF.colors.power[powerType] or {1,1,1}
    local r,g,b = unpack(color)
    element:SetStatusBarColor(r,g,b)
    if element.bg then
      local mu = element.bg.multiplier or 0.3
      element.bg:SetVertexColor(r*mu, g*mu, b*mu)
    end
    element:SetMinMaxValues(0, ppmax)
    element:SetValue(ppcur)
    element:Show()
  end
end

local function Path(self, ...)
  return (self.rRuneBar.Override or Update) (self, ...)
end

local function ClassPowerEnable(self)
  -- self:RegisterEvent('UNIT_POWER_FREQUENT', Path)
  -- self:RegisterEvent('UNIT_MAXPOWER', Path)
  self:RegisterEvent('RUNE_POWER_UPDATE', Path, true)

  self.rRuneBar.isEnabled = true
  
  Path(self, 'ClassPowerEnable', 'player', ClassPowerType)
end

local function ClassPowerDisable(self)
  -- self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
  -- self:UnregisterEvent('UNIT_MAXPOWER', Path)
  self:UnregisterEvent('RUNE_POWER_UPDATE', Path)
  self.rRuneBar:Hide()
  self.rRuneBar.isEnabled = false
  Path(self, 'ClassPowerDisable', 'player', ClassPowerType)
end

local function Visibility(self, event, unit)
  local element = self.rRuneBar
  local shouldEnable
  if(UnitHasVehicleUI('player')) then
    shouldEnable = false
  else 
    shouldEnable = true
  end
  local isEnabled = element.isEnabled
  local powerType = ClassPowerType
  if(shouldEnable and not isEnabled) then
    ClassPowerEnable(self)
  elseif(not shouldEnable and (isEnabled or isEnabled == nil)) then
    ClassPowerDisable(self)
  elseif(shouldEnable and isEnabled) then
    Path(self, event, unit, powerType)
  end
end

local function VisibilityPath(self, ...)
  return (self.rRuneBar.OverrideVisibility or Visibility) (self, ...)
end

local function ForceUpdate(element)
  return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
  if(unit ~= 'player') then return end
  local element = self.rRuneBar
  if(not element) then return end
  element.__owner = self
  element.ForceUpdate = ForceUpdate
  self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', VisibilityPath)
  return true
end

local function Disable(self)
  if self.rRuneBar then
    ClassPowerDisable(self)
    self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', VisibilityPath))
  end
end

oUF:AddElement('rRuneBar', VisibilityPath, Enable, Disable)