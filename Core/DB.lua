CustomSoundManager = CustomSoundManager or {}

local DB = {}
CustomSoundManager.DB = DB

function DB.Init()
  if type(CustomSoundManagerDB) ~= "table" then
    CustomSoundManagerDB = {}
  end
  if type(CustomSoundManagerDB.sounds) ~= "table" then
    CustomSoundManagerDB.sounds = {}
  end
end

function DB.GetSounds()
  DB.Init()
  return CustomSoundManagerDB.sounds
end

function DB.SetSounds(sounds)
  DB.Init()
  CustomSoundManagerDB.sounds = sounds or {}
end

function DB.FindIndexByName(name)
  if type(name) ~= "string" then
    return nil
  end
  local needle = string.lower(name)
  local sounds = DB.GetSounds()
  for i, entry in ipairs(sounds) do
    if type(entry) == "table" and type(entry.name) == "string" and string.lower(entry.name) == needle then
      return i
    end
  end
  return nil
end
