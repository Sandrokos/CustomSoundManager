CustomSoundManager = CustomSoundManager or {}

local addonName = ...
local CSM = CustomSoundManager

local function OnAddonLoaded()
  CSM.DB.Init()
  CSM.Registry.RegisterAll()
  CSM.Options.RegisterWithSettings()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
  if name ~= addonName then
    return
  end
  self:UnregisterEvent("ADDON_LOADED")
  OnAddonLoaded()
end)

SLASH_CUSTOMSOUNDMANAGER1 = "/csm"
SLASH_CUSTOMSOUNDMANAGER2 = "/customsounds"
SlashCmdList.CUSTOMSOUNDMANAGER = function(msg)
  msg = string.lower(strtrim(msg or ""))
  if msg == "" or msg == "config" or msg == "options" then
    CSM.Options.Open()
    return
  end
  CSM.Print("Usage: /csm — open options")
end
