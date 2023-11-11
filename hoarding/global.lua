local core = require("openmw.core")
local world = require('openmw.world')
local types = require('openmw.types')

local counter_for_new_mark = 0

local locked_object = nil --TODO: save, also should probably be per-player

return {
    engineHandlers = {
        onUpdate = function(dt)
            counter_for_new_mark = counter_for_new_mark + dt
            if counter_for_new_mark >= 1 then
                counter_for_new_mark = counter_for_new_mark - 1

                -- TODO: when .49 is released, replace with .players

                for _, player in ipairs(world.activeActors) do
                    if types.Player.objectIsInstance(player) then
                        print(locked_object)
                        if locked_object ~= nil then
                            if locked_object.source == "cell" then
                                text = locked_object.item.recordId .. " in cell at x:" .. locked_object.item.position.x .. " y:" .. locked_object.item.position.y .. " z:" .. locked_object.item.position.z
                            elseif locked_object.source == "container" then
                                text = locked_object.item.recordId .. " in container " .. locked_object.inside.recordId
                            elseif locked_object.source == "actor" then
                                text = locked_object.item.recordId .. " on actor " .. locked_object.inside.recordId
                                if locked_object.alive then
                                    text = text .. " (alive)"
                                else
                                    text = text .. " (dead)"
                                end
                            end
                            player:sendEvent("MarHoard_NotifyText", {text = text})
                        end
                        -- Would be nice to instead do that when locked_object is nil and to set it to nil once it moved or something like that
                        if true then
                            local cell = player.cell
                            local items = {}
                            for _, cell_entity in ipairs(cell:getAll()) do
                                if types.Item.objectIsInstance(cell_entity) then
                                    print(cell_entity)
                                    table.insert(items, {
                                        item = cell_entity,
                                        source = "cell"
                                    })
                                elseif types.Actor.objectIsInstance(cell_entity) then
                                    for _, owned in ipairs(types.Actor.inventory(cell_entity):getAll()) do
                                        table.insert(items, {
                                            item = owned,
                                            inside = cell_entity,
                                            source = "actor",
                                            alive = types.Actor.stats.dynamic.health(cell_entity).current > 0
                                        })
                                    end
                                elseif types.Container.objectIsInstance(cell_entity) then
                                    for _, contained in ipairs(types.Container.content(cell_entity):getAll()) do
                                        table.insert(items, {
                                            item = contained,
                                            inside = cell_entity,
                                            source = "container"
                                        })
                                    end
                                end
                            end

                            if locked_object ~= nil then
                                local match_found = false
                                for _, item in ipairs(items) do
                                    if item.item == locked_object.item then
                                        match_found = true
                                    end
                                end
                                if not match_found then
                                    locked_object = nil
                                end
                            end
                            if #items > 0 and locked_object == nil then
                                locked_object = items[ math.random( #items )]
                            end
                        end
                    end
                end

                -- Execute once per second
                -- print(self.position)
                -- print(util.cell_to_string(self.cell))
            end
        end
    }
}