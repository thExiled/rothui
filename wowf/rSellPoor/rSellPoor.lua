
-- rSellPoor: core
-- zork, 2019

-----------------------------
-- Variables
-----------------------------

local A, L = ...
local container = C_Container
local getContainerNumSlots = container and container.GetContainerNumSlots or GetContainerNumSlots
local getContainerItemInfo = container and container.GetContainerItemInfo or GetContainerItemInfo
local getContainerItemLink = container and container.GetContainerItemLink or GetContainerItemLink
local useContainerItem = container and container.UseContainerItem or UseContainerItem

-----------------------------
-- Functions
-----------------------------

local stop = true
local list = {}

local function GetItemQuality(itemLink, itemInfo)
  if itemInfo and itemInfo.quality ~= nil then
    return itemInfo.quality
  end
  if GetItemInfo then
    return select(3, GetItemInfo(itemLink))
  elseif C_Item and C_Item.GetItemInfo then
    local name, _, quality = C_Item.GetItemInfo(itemLink)
    if type(name) == "table" then
      return name.itemQuality or name.quality
    end
    return quality
  end
end

local function SellGray()
  if stop or not getContainerNumSlots or not useContainerItem then return end
  for bag=0,NUM_BAG_SLOTS or 4 do
    for slot=1,getContainerNumSlots(bag) do
      if stop then return end
      local itemInfo = getContainerItemInfo and getContainerItemInfo(bag, slot)
      local link = itemInfo and itemInfo.hyperlink
      if not link and getContainerItemLink then
        link = getContainerItemLink(bag, slot)
      end
      if link and GetItemQuality(link, itemInfo) == 0 and not list["b"..bag.."s"..slot] then
        print(A,"selling",link,"bag",bag,"slot",slot)
        list["b"..bag.."s"..slot] = true
        useContainerItem(bag, slot)
        C_Timer.After(0.2, SellGray)
        return
      end
    end
  end
end


local function OnEvent(self,event)
  if event == "MERCHANT_SHOW" then
    stop = false
    wipe(list)
    SellGray()
  elseif event == "MERCHANT_CLOSED" then
    stop = true
  end
end

-----------------------------
-- Init
-----------------------------

--eventHandler
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("MERCHANT_SHOW")
eventHandler:RegisterEvent("MERCHANT_CLOSED")
eventHandler:SetScript("OnEvent", OnEvent)