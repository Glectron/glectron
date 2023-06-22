local GTRON_PATH = "%GLECTRON_PATH%"
local GTRON_ATTRIBUTES = { -- DO NOT MODIFY
    VERSION = {
        MAJOR = "%GLECTRON_VER_MAJOR%",
        MINOR = "%GLECTRON_VER_MINOR%",
        PATCH = "%GLECTRON_VER_PATCH%"
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

    _GTRON_VERSIONS = _GTRON_VERSIONS or {}

    local function checkAndInitialize()
        print(string.format("Found %d Glectron version(s)", #_GTRON_VERSIONS))
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

        GLECTRON_PATH = bestVersion.PATH
        
        addDirectory(bestVersion.PATH)
        print(string.format("Using Glectron v%d.%d.%d (%s Version) in clients", ver.MAJOR, ver.MINOR, ver.PATCH, bestVersion.EMBED and "Embeded" or "Standalone"))
        include(GTRON_PATH .. "/sv_init.lua")
    end

    local function registerGlectronVersion(attribute)
        table.insert(_GTRON_VERSIONS, attribute)
    end

    registerGlectronVersion(GTRON_ATTRIBUTES)
    if not GTRON_LOADER_VER or GTRON_LOADER_VER < LOADER_VER then
        hook.Add("Initialize", "GlectronLoader", checkAndInitialize)
        GTRON_LOADER_VER = LOADER_VER
    end
end

if CLIENT and file.Exists(GTRON_PATH .. "/init.lua", "LUA") then
    local ver = GTRON_ATTRIBUTES.VERSION
    GLECTRON_PATH = GTRON_PATH
    print(string.format("Initializing Glectron v%d.%d.%d (%s Version)", ver.MAJOR, ver.MINOR, ver.PATCH, GTRON_ATTRIBUTES.EMBED and "Embeded" or "Standalone"))
    include(GTRON_PATH .. "/init.lua")
end