-- Save to my_lua_mod/example/player.lua

local ui = require('openmw.ui')
local self = require('openmw.self')
local core = require("openmw.core")
local util = require("mwnav/util")

local counter_for_new_mark = 0

return {
    eventHandlers = {
        MarHoard_NotifyText = function(data)
            ui.showMessage(data.text)
        end
    }
}