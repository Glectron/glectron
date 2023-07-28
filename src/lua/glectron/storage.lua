local STORAGE = {}
Glectron.Storage = STORAGE

if not sql.TableExists("glectron_storage") then
    sql.Query("CREATE TABLE glectron_storage (id TEXT, key TEXT, value TEXT)")
end

function STORAGE:SetStorage(id, key, value)
    if value then
        sql.Query("REPLACE INTO glectron_storage (id, key, value) VALUES (" .. sql.SQLStr(id) .. ", " .. sql.SQLStr(key) .. ", " .. sql.SQLStr(value) .. ")")
    else
        sql.Query("DELETE FROM glectron_storage WHERE id = " .. sql.SQLStr(id) .. " AND key = " .. sql.SQLStr(key))
    end
end

function STORAGE:GetStorage(id)
    return sql.Query("SELECT key, value FROM glectron_storage WHERE id = " .. sql.SQLStr(id))
end

function STORAGE:ClearStorage(id)
    sql.Query("DELETE FROM glectron_storage WHERE id = " .. sql.SQLStr(id))
end