local GTRON_PATH = "glectron" -- TODO: For Glectron Node Tools
local GTRON_ATTRIBUTES = { -- DO NOT MODIFY
    VERSION = {
        MAJOR = 0,
        MINOR = 0,
        PATCH = 1
    },
    EMBED = false,
    PATH = GTRON_PATH
}
local LOADER_VER = 1

if SERVER then
    local function addDirectory(dir)
        local files, dirs = file.Find(dir .. "/*", "LUA")
        for _,v in pairs(files) do
            if string.EndsWith(v, ".lua") then
                AddCSLuaFile(dir .. "/" .. v)
            end
        end
        for _,v in pairs(dirs) do
            addDirectory(dir .. "/" .. v)
        end
    end

    addDirectory(GTRON_PATH) -- TODO: Only add best version of Glectron to client
    return
end

_GTRON_VERSIONS = _GTRON_VERSIONS or {}

local function checkAndInitialize()
    print(string.format("Found %d Glectron(s)", #_GTRON_VERSIONS))
    table.sort(_GTRON_VERSIONS, function(a, b)
        local AVER = a.VERSION
        local BVER = b.VERSION
        
        if AVER.MAJOR > BVER.MAJOR then
            return true
        elseif AVER.MAJOR < BVER.MAJOR then
            return false
        end

        if AVER.MINOR > BVER.MINOR then
            return true
        elseif AVER.MINOR < BVER.MINOR then
            return false
        end

        if AVER.PATCH > BVER.PATCH then
            return true
        elseif AVER.PATCH < BVER.PATCH then
            return false
        end

        return not a.EMBED and b.EMBED
    end)

    local bestVersion = _GTRON_VERSIONS[1]
    local ver = bestVersion.VERSION
    print(string.format("Initializing Glectron v%d.%d.%d (%s Version)", ver.MAJOR, ver.MINOR, ver.PATCH, bestVersion.EMBED and "Embeded" or "Standalone"))
    include(bestVersion.PATH .. "/init.lua")
    print("Glectron is loaded.")
end

local function registerGlectronVersion(attribute)
    table.insert(_GTRON_VERSIONS, attribute)
end

registerGlectronVersion(GTRON_ATTRIBUTES)
if not GTRON_LOADER_VER or GTRON_LOADER_VER < LOADER_VER then
    hook.Add("Initialize", "GlectronLoader", checkAndInitialize)
    GTRON_LOADER_VER = LOADER_VER
end