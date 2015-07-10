utils = require "mp.utils"
msg = require "mp.msg"

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.split(str, delim, maxsplit)
    local result = {}
    local buffer = ""
    local splits = 0
    for c in str:gmatch(".") do
        if splits ~= maxsplit and c == delim then
            table.insert(result, buffer)
            buffer = ""
            splits = splits + 1
        else
            buffer = buffer..c
        end
    end
    table.insert(result, buffer)
    return result
end

function string.trim(s)
    return s:match'^%s*(.*%S)' or ''
end

function extract_broken_json(str, key)
    local last_match = nil
    for match in str:gmatch("[^%\\](\""..key.."\"%s-:%s-\"?.-\"?)%s-[,}]") do
        last_match = match
    end
    if last_match then
        last_match = utils.parse_json("{"..last_match.."}")
        return last_match[key]
    else
        return nil
    end
end

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function exec(args)
    local ret = utils.subprocess({args = args})
    return ret.status, ret.stdout, ret
end

function readAll(file)
    local f = io.open(file, "rb")
    local content = ""
    if f then
        content = f:read("*all")
        f:close()
    end
    return content
end

function readAllHTTP(url)
    local command = {"curl", "-k", "-s", url}
    local status, content = exec(command)
    return content or ""
end
