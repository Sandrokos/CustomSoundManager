CustomSoundManager = CustomSoundManager or {}

local Registry = {}
CustomSoundManager.Registry = Registry

local lsmOverride

function CustomSoundManager.Print(msg)
  print("|cff33ff99Custom Sound Manager|r: " .. tostring(msg))
end

function Registry.SetLSM(lsm)
  lsmOverride = lsm
end

local function GetLSM()
  if lsmOverride then
    return lsmOverride
  end
  local LibStub = _G.LibStub
  if not LibStub then
    return nil
  end
  local ok, lsm = pcall(LibStub, "LibSharedMedia-3.0")
  if ok then
    return lsm
  end
  return nil
end

function Registry.NormalizePath(path)
  return (string.gsub(path, "/", "\\"))
end

local function Trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function HasSoundExtension(path)
  local lower = string.lower(path)
  return string.find(lower, "%.ogg$") or string.find(lower, "%.mp3$")
end

local function IsUnderInterface(path)
  local lower = string.lower(path)
  return string.sub(lower, 1, 10) == "interface\\"
end

local function WarnIfUnknownLooseFile(path)
  local api = _G.C_UIFileAsset
  if not api or type(api.IsLooseFile) ~= "function" then
    return
  end
  local ok, isLoose = pcall(api.IsLooseFile, path)
  if ok and not isLoose then
    CustomSoundManager.Print("Warning: file not seen as a loose asset yet (may need a client restart): " .. path)
  end
end

local function MediaName(name)
  return "Custom: " .. name
end

local function RegisterOne(name, path)
  local lsm = GetLSM()
  if not lsm then
    CustomSoundManager.Print("LibSharedMedia-3.0 not available; cannot register '" .. name .. "'.")
    return false
  end
  return lsm:Register("sound", MediaName(name), path)
end

function Registry.Add(name, path)
  name = Trim(tostring(name or ""))
  path = Trim(tostring(path or ""))
  if name == "" then
    return false, "Name is required."
  end
  if path == "" then
    return false, "Path is required."
  end
  path = Registry.NormalizePath(path)

  local DB = CustomSoundManager.DB
  if DB.FindIndexByName(name) then
    return false, "A sound named '" .. name .. "' already exists."
  end

  if not HasSoundExtension(path) then
    return false, "Path must end with .ogg or .mp3."
  end
  if not IsUnderInterface(path) then
    return false, "Path must start with Interface\\."
  end
  WarnIfUnknownLooseFile(path)

  if not RegisterOne(name, path) then
    return false, "Could not register with LibSharedMedia (name may already be in use)."
  end

  local sounds = DB.GetSounds()
  sounds[#sounds + 1] = { name = name, path = path }
  return true, "Registered '" .. name .. "'."
end

function Registry.Remove(name)
  name = Trim(tostring(name or ""))
  local DB = CustomSoundManager.DB
  local index = DB.FindIndexByName(name)
  if not index then
    return false, "No sound named '" .. name .. "'."
  end
  table.remove(DB.GetSounds(), index)
  return true, "Removed '" .. name .. "'. Other addons may need /reload to refresh sound lists."
end

function Registry.List()
  return CustomSoundManager.DB.GetSounds()
end

function Registry.Play(name)
  name = Trim(tostring(name or ""))
  local index = CustomSoundManager.DB.FindIndexByName(name)
  if not index then
    return false, "No sound named '" .. name .. "'."
  end
  local entry = CustomSoundManager.DB.GetSounds()[index]
  local willPlay = PlaySoundFile(entry.path, "Master")
  if not willPlay then
    return false, "Could not play '" .. name .. "' (missing file or muted)."
  end
  return true, "Playing '" .. name .. "'."
end

function Registry.RegisterAll()
  local lsm = GetLSM()
  if not lsm then
    CustomSoundManager.Print("LibSharedMedia-3.0 not available; skipped sound registration.")
    return
  end
  for _, entry in ipairs(CustomSoundManager.DB.GetSounds()) do
    if type(entry) == "table" and entry.name and entry.path then
      lsm:Register("sound", MediaName(entry.name), entry.path)
    end
  end
end
