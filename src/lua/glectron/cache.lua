local CACHE = {}
Glectron.Cache = CACHE

local function verifyChecksum(data, checksum)
    return util.SHA256(data) == checksum
end

if not sql.TableExists("glectron_cache") then
    sql.Query("CREATE TABLE glectron_cache (id TEXT, last_used INTEGER)")
end

function CACHE:IsCached(checksum, callback)
    local path = "glectron/cache/" .. checksum .. ".dat"
    if file.Exists(path, "DATA") then
        if callback then
            file.AsyncRead(path, "DATA", function(_, _, status, data)
                if status ~= FSASYNC_OK then
                    callback(false)
                    return
                end
                data = util.Decompress(data)
                local res = verifyChecksum(data, checksum)
                callback(res, res and data)
            end)
        else
            local data = util.Decompress(file.Read(path, "DATA"))
            local res = verifyChecksum(data, checksum)
            return res, res and data
        end
    else
        if callback then
            callback(false)
        else
            return false
        end
    end
end

function CACHE:WriteCache(data, checksum)
    checksum = checksum or util.SHA256(data)
    local compressed = util.Compress(data)
    file.Write("glectron/cache/" .. checksum .. ".dat", compressed)
    self:TouchCache(checksum)
end

function CACHE:TouchCache(checksum)
    sql.Query("REPLACE INTO glectron_cache (id, last_used) VALUES ('" .. checksum .. "', strftime('%s'))")
end

function CACHE:CleanupCache()
    local result = sql.Query("SELECT id FROM glectron_cache WHERE last_used >= strftime('%s') - 7 * 24 * 60 * 60")
    if not result then return end
    local validCaches = {}
    for _,v in pairs(result) do
        table.insert(validCaches, v.id)
    end
    local cacheFiles = file.Find("glectron/cache/*", "DATA")
    for _,v in pairs(cacheFiles) do
        if not table.HasValue(validCaches, string.sub(v, 1, #v - 4)) then
            file.Delete("glectron/cache/" .. v)
        end
    end
end

CACHE:CleanupCache()