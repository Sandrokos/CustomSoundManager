CustomSoundManager = CustomSoundManager or {}



local Options = {}

CustomSoundManager.Options = Options



local panel

local nameBox

local pathBox

local listChild

local rowFrames = {}

local optionsCategory

local optionsRegistered = false



local PANEL_WIDTH = 660

local ROW_HEIGHT = 28



local function CreateRow(parent)

  local row = CreateFrame("Frame", nil, parent)

  row:SetSize(PANEL_WIDTH - 60, ROW_HEIGHT)



  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")

  row.label:SetPoint("LEFT", 4, 0)

  row.label:SetWidth(200)

  row.label:SetJustifyH("LEFT")



  row.pathLabel = row:CreateFontString(nil, "ARTWORK", "GameFontDisable")

  row.pathLabel:SetPoint("LEFT", row.label, "RIGHT", 8, 0)

  row.pathLabel:SetWidth(280)

  row.pathLabel:SetJustifyH("LEFT")



  row.playBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")

  row.playBtn:SetSize(50, 22)

  row.playBtn:SetPoint("RIGHT", -58, 0)

  row.playBtn:SetText("Play")



  row.removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")

  row.removeBtn:SetSize(60, 22)

  row.removeBtn:SetPoint("RIGHT", -4, 0)

  row.removeBtn:SetText("Remove")



  return row

end



local function RefreshList()

  if not listChild then

    return

  end

  local sounds = CustomSoundManager.Registry.List()

  local y = -4

  for i, entry in ipairs(sounds) do

    local row = rowFrames[i]

    if not row then

      row = CreateRow(listChild)

      rowFrames[i] = row

    end

    row:ClearAllPoints()

    row:SetPoint("TOPLEFT", 4, y)

    row.label:SetText(entry.name)

    row.pathLabel:SetText(entry.path)

    row.playBtn:SetScript("OnClick", function()

      local _, msg = CustomSoundManager.Registry.Play(entry.name)

      CustomSoundManager.Print(msg)

    end)

    row.removeBtn:SetScript("OnClick", function()

      local _, msg = CustomSoundManager.Registry.Remove(entry.name)

      CustomSoundManager.Print(msg)

      RefreshList()

    end)

    row:Show()

    y = y - ROW_HEIGHT

  end

  for j = #sounds + 1, #rowFrames do

    rowFrames[j]:Hide()

  end

  listChild:SetHeight(math.max(1, (#sounds * ROW_HEIGHT) + 8))

end



local function EnsurePanel()

  if panel then

    return panel

  end



  panel = CreateFrame("Frame", "CustomSoundManagerOptionsPanel")

  panel.name = "CustomSoundManager"

  panel:SetSize(PANEL_WIDTH, 500)



  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")

  title:SetPoint("TOPLEFT", 16, -16)

  title:SetText("Custom Sound Manager")



  local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")

  hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

  hint:SetPoint("RIGHT", panel, "RIGHT", -16, 0)

  hint:SetJustifyH("LEFT")

  hint:SetText("Enter a display name and full path (e.g. Interface\\CustomSounds\\alert.ogg). Files must exist before login/reload.")



  local nameLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")

  nameLabel:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -16)

  nameLabel:SetText("Name")



  nameBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")

  nameBox:SetSize(220, 20)

  nameBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 5, -4)

  nameBox:SetAutoFocus(false)



  local pathLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")

  pathLabel:SetPoint("LEFT", nameLabel, "RIGHT", 240, 0)

  pathLabel:SetText("Path")



  pathBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")

  pathBox:SetSize(320, 20)

  pathBox:SetPoint("TOPLEFT", pathLabel, "BOTTOMLEFT", 5, -4)

  pathBox:SetAutoFocus(false)



  local addBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")

  addBtn:SetSize(80, 22)

  addBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -5, -12)

  addBtn:SetText("Add")

  addBtn:SetScript("OnClick", function()

    local ok, msg = CustomSoundManager.Registry.Add(nameBox:GetText(), pathBox:GetText())

    CustomSoundManager.Print(msg)

    if ok then

      nameBox:SetText("")

      pathBox:SetText("")

      RefreshList()

    end

  end)



  local scroll = CreateFrame("ScrollFrame", "CustomSoundManagerSoundScroll", panel, "UIPanelScrollFrameTemplate")

  scroll:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -16)

  scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -36, 16)



  listChild = CreateFrame("Frame", nil, scroll)

  listChild:SetSize(PANEL_WIDTH - 50, 1)

  scroll:SetScrollChild(listChild)



  panel.OnCommit = function() end

  panel.OnDefault = function() end

  panel.OnRefresh = function()

    RefreshList()

  end



  return panel

end



function Options.GetPanel()

  return EnsurePanel()

end



function Options.RegisterWithSettings()

  if optionsRegistered then

    return

  end

  if not Settings or not Settings.RegisterCanvasLayoutCategory then

    return

  end

  local p = EnsurePanel()

  optionsCategory = Settings.RegisterCanvasLayoutCategory(p, "Custom Sound Manager")
  -- Midnight requires the numeric ID from RegisterCanvasLayoutCategory.
  -- Do not overwrite category.ID with a string — OpenToCategory will error.
  Settings.RegisterAddOnCategory(optionsCategory)
  optionsRegistered = true
end

function Options.Open()
  Options.RegisterWithSettings()
  if Settings and Settings.OpenToCategory and optionsCategory then
    local categoryID = optionsCategory.GetID and optionsCategory:GetID() or optionsCategory.ID
    if type(categoryID) == "number" then
      Settings.OpenToCategory(categoryID)
      return
    end
  end
  local p = EnsurePanel()
  p:Show()
end



function Options.Show()

  Options.Open()

end

