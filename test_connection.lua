-- Test script to verify menu connection
-- Run this after loading both sosiski.lua and sosiski3.lua

print("=== Testing Menu Connection ===")

-- Test if configurations are available
print("Testing configurations:")
print("Config:", Config and "Found" or "Not found")
print("FlyConfig:", FlyConfig and "Found" or "Not found")
print("NoClipConfig:", NoClipConfig and "Found" or "Not found")
print("SpeedHackConfig:", SpeedHackConfig and "Found" or "Not found")
print("LongJumpConfig:", LongJumpConfig and "Found" or "Not found")
print("InfiniteJumpConfig:", InfiniteJumpConfig and "Found" or "Not found")
print("YBAConfig:", YBAConfig and "Found" or "Not found")
print("TeleportConfig:", TeleportConfig and "Found" or "Not found")

-- Test if functions are available
print("\nTesting functions:")
local functions = {
    "startFly", "stopFly", "startNoClip", "stopNoClip", 
    "startSpeedHack", "stopSpeedHack", "startLongJump", "stopLongJump",
    "startInfiniteJump", "stopInfiniteJump", "startYBA", "stopYBA",
    "startTeleport", "stopTeleport"
}

for _, funcName in ipairs(functions) do
    local func = _G[funcName]
    if func and type(func) == "function" then
        print(funcName .. ": Found in _G")
    else
        print(funcName .. ": Not found in _G")
    end
end

print("\n=== Test Complete ===")
print("If you see 'Found' for most items, the connection is working!")
print("If you see 'Not found', make sure to load sosiski.lua BEFORE sosiski3.lua")