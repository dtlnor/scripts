-- set mpv title to what it says in #EXTINF

require "shared.helpers"

local titles = {}

function parse_titles(m3u_file)
    local title_table = {}
    local file_content = ""
    if m3u_file:starts("http://") or m3u_file:starts("https://") then
        file_content = readAllHTTP(m3u_file)
    else
        file_content = readAll(m3u_file)
    end
    local playlist_counter = 1
    for line in file_content:gmatch("[^\r\n]+") do
        local line = line:trim()
        if line:starts("#EXTINF") then
            local title = line:split(",", 1)[2] or ""
            table.insert(title_table, playlist_counter, title)
        elseif not ((line == "") or line:starts("#")) then
            playlist_counter = playlist_counter + 1
        end
    end
    return title_table
end

function get_titles()
    local path = mp.get_property("path")
    if path:ends(".m3u") then
        print("Getting titles from "..path)
        titles = parse_titles(path)
    end
end

function set_title()
    local pos = mp.get_property("playlist-pos")
    local title = titles[pos + 1]
    if title then
        print("Setting title to "..title)
        mp.set_property("file-local-options/force-media-title", title)
    end
end

mp.register_event("start-file", get_titles)
mp.register_event("file-loaded", set_title)
