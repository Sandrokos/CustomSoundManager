-- Offline tests for CustomSoundManager (Lua 5.1). Run:

--   lua tests/run_tests.lua

-- from the addon root.



package.path = package.path .. ";./Core/?.lua;./?.lua"



local failures = 0



local function fail(msg)

  failures = failures + 1

  print("FAIL: " .. msg)

end



local function assert_eq(actual, expected, msg)

  if actual ~= expected then

    fail(string.format("%s (got %s, expected %s)", msg, tostring(actual), tostring(expected)))

  end

end



local function assert_true(cond, msg)

  if not cond then fail(msg) end

end



-- Minimal WoW globals used by modules under test

CreateFrame = CreateFrame or function() return {} end



print("== DB tests ==")



-- Load DB after faking empty SavedVariables

CustomSoundManager = {}

CustomSoundManagerDB = nil



dofile("Core/DB.lua")



CustomSoundManager.DB.Init()

assert_true(type(CustomSoundManagerDB) == "table", "Init creates CustomSoundManagerDB")

assert_true(type(CustomSoundManagerDB.sounds) == "table", "Init creates sounds table")

assert_eq(#CustomSoundManager.DB.GetSounds(), 0, "starts empty")



CustomSoundManager.DB.SetSounds({

  { name = "Alert", path = [[Interface\CustomSounds\a.ogg]] },

  { name = "Warn", path = [[Interface\CustomSounds\b.ogg]] },

})

assert_eq(#CustomSoundManager.DB.GetSounds(), 2, "SetSounds stores entries")

assert_eq(CustomSoundManager.DB.FindIndexByName("alert"), 1, "FindIndexByName case-insensitive")

assert_eq(CustomSoundManager.DB.FindIndexByName("missing"), nil, "FindIndexByName nil when missing")



-- Re-init must not wipe existing data

CustomSoundManager.DB.Init()

assert_eq(#CustomSoundManager.DB.GetSounds(), 2, "Init preserves existing sounds")



print("== Registry tests ==")



-- Fake LSM

local registered = {}

local lsmRegisterReturns = true

local fakeLSM = {

  Register = function(_, mediaType, name, path)

    registered[#registered + 1] = { mediaType = mediaType, name = name, path = path }

    return lsmRegisterReturns

  end,

}



-- Fake PlaySoundFile

local lastPlay

PlaySoundFile = function(path, channel)

  lastPlay = { path = path, channel = channel }

  return true, 1

end



-- Soft-warn helpers: capture prints

local prints = {}

local realPrint = print

print = function(...)

  local parts = { ... }

  local s = table.concat(parts, "\t")

  prints[#prints + 1] = s

  realPrint(...)

end



dofile("Core/Registry.lua")

CustomSoundManager.Registry.SetLSM(fakeLSM)



-- Reset DB for registry tests

CustomSoundManagerDB = { sounds = {} }

CustomSoundManager.DB.Init()

registered = {}

prints = {}

lsmRegisterReturns = true



local ok, msg = CustomSoundManager.Registry.Add("", "Interface\\CustomSounds\\a.ogg")

assert_eq(ok, false, "empty name rejected")



ok, msg = CustomSoundManager.Registry.Add("Alert", "")

assert_eq(ok, false, "empty path rejected")



ok, msg = CustomSoundManager.Registry.Add("  Alert  ", "Interface/CustomSounds/a.ogg")

assert_eq(ok, true, "add succeeds")

assert_eq(CustomSoundManager.DB.GetSounds()[1].path, [[Interface\CustomSounds\a.ogg]], "path normalized")

assert_eq(registered[1].mediaType, "sound", "LSM type sound")

assert_eq(registered[1].name, "Custom: Alert", "LSM name prefixed Custom:")



ok, msg = CustomSoundManager.Registry.Add("alert", [[Interface\CustomSounds\b.ogg]])

assert_eq(ok, false, "duplicate name rejected")



ok, msg = CustomSoundManager.Registry.Add("Other", [[Interface\CustomSounds\x.wav]])

assert_eq(ok, false, "non-ogg/mp3 rejected")



ok, msg = CustomSoundManager.Registry.Add("BadPath", [[Sound\CustomSounds\x.ogg]])

assert_eq(ok, false, "path not under Interface\\ rejected")

assert_eq(#CustomSoundManager.DB.GetSounds(), 1, "invalid path not persisted")



ok, msg = CustomSoundManager.Registry.Add("Good", [[Interface\CustomSounds\c.ogg]])

assert_eq(ok, true, "valid ogg still works")

assert_eq(#CustomSoundManager.DB.GetSounds(), 2, "valid ogg persisted")



lsmRegisterReturns = false

registered = {}

ok, msg = CustomSoundManager.Registry.Add("LSMFail", [[Interface\CustomSounds\fail.ogg]])

assert_eq(ok, false, "LSM false return fails Add")

assert_eq(#CustomSoundManager.DB.GetSounds(), 2, "LSM failure not persisted")

assert_eq(#registered, 1, "LSM Register still called")

lsmRegisterReturns = true



ok, msg = CustomSoundManager.Registry.Play("Alert")

assert_eq(ok, true, "play known sound")

assert_eq(lastPlay.path, [[Interface\CustomSounds\a.ogg]], "plays stored path")

assert_eq(lastPlay.channel, "Master", "Master channel")



ok, msg = CustomSoundManager.Registry.Remove("Alert")

assert_eq(ok, true, "remove works")

assert_eq(CustomSoundManager.DB.FindIndexByName("Alert"), nil, "removed from DB")



-- RegisterAll

CustomSoundManager.DB.SetSounds({

  { name = "One", path = [[Interface\CustomSounds\1.ogg]] },

  { name = "Two", path = [[Interface\CustomSounds\2.ogg]] },

})

registered = {}

CustomSoundManager.Registry.RegisterAll()

assert_eq(#registered, 2, "RegisterAll registers all")



print = realPrint



if failures > 0 then

  realPrint(string.format("%d failure(s)", failures))

  os.exit(1)

else

  realPrint("All tests passed")

end

