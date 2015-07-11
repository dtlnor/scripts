require "shared.helpers"

local scrobbling = false
local timer = nil
local artist, title, album, length = nil
local scrobbler_path = script_path()
scrobbler_path = utils.split_path(scrobbler_path)
scrobbler_path = utils.join_path(scrobbler_path, "shared/last_fm_scrobbler.py")
local fj = utils.format_json

function debug_msg(json)
    local json = utils.parse_json(json)
    msg.info(json)
end

function scrobble()
    local args = {"python", scrobbler_path, "scrobble", fj(artist), fj(title), fj(album), fj(length)}
    local result = utils.subprocess({args = args})
    debug_msg(result.stdout)
end

function publish_nowplaying()
    local args  = {"python", scrobbler_path, "np", fj(artist), fj(title)}
    utils.subprocess({args = args})
end

function on_metadata(_, metadata)
    local icy_title = metadata['icy-title']
    if icy_title then
        artist, title = icy_title:gmatch("(.+) %- (.+)")()
        album = nil
        length = nil
    else
        length = mp.get_property("duration")
        if length and tonumber(length) < 30 then return end
        artist = metadata["artist"] or metadata["ARTIST"]
        title = metadata["title"] or metadata["TITLE"]
        album = metadata["album"] or metadata["ALBUM"]
    end
    if artist and title then
        publish_nowplaying()
        if timer then timer:kill() end
        timer = mp.add_timeout(math.min(240, (length or 30) / 2), scrobble)
    end
end

function toggle_scrobbling()
    if scrobbling then
        mp.unobserve_property(on_metadata)
        mp.commandv("show-text", "scrobbling disabled")
    else
        mp.observe_property("metadata", "native", on_metadata)
        mp.commandv("show-text", "scrobbling enabled")
    end
    scrobbling = not scrobbling
end

mp.add_key_binding("F2", toggle_scrobbling)
