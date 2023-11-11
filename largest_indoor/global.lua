local core = require("openmw.core")
local world = require('openmw.world')
local types = require('openmw.types')

local new_counter = 0
local cell_path_table = {

}

local function merge_cell_path_table(merge_into_key, merge_with_key)
    --print("merge "  .. merge_with_key .. " into " .. merge_into_key)
    for _, v in ipairs(cell_path_table[merge_with_key]) do
        table.insert(cell_path_table[merge_into_key], v)
    end
    cell_path_table[merge_with_key] = nil
end

local function add_connected_group_to_cell_path_table(group)
    local merge_with = nil
    for k, cur_table in pairs(cell_path_table) do
        skip = false
        for _, entry in ipairs(cur_table) do
            for _, to_add in ipairs(group) do
                if not skip then
                    if to_add == entry then
                        skip = true
                        if merge_with == nil then
                            merge_with = k
                        else
                            merge_cell_path_table(merge_with, k)
                        end
                    end
                end
            end
        end
    end
    
    if merge_with == nil then
        merge_with = new_counter
        -- print("newly added into " .. merge_with)
        cell_path_table[merge_with] = {}
        new_counter = new_counter + 1
    end

    for _, to_add in ipairs(group) do
        found = false
        for _, entry in ipairs(cell_path_table[merge_with]) do
            if entry == to_add then
                found = true
            end
        end
        if not found then
            table.insert(cell_path_table[merge_with], to_add)
        end
    end
end

local function print_result()
    print(#cell_path_table)
    for _, v in pairs(cell_path_table) do
        local text = ""
        if #v >= 20 then
            for _, cell in ipairs(v) do
                text = text .. cell .. " | "
            end
            print(#v .. ":" .. v[1])
        end
    end
end

local cells = world.cells
local cell_pos = 1

return {
    engineHandlers = {
        -- on loaded instead of this ugly thing
        onUpdate = function(dt)
            if not tested then
                for i = 1, 20 do
                    if not (cell_pos > #cells) then
                        local cell = cells[cell_pos]
                        if not cell.isExterior then
                            local to_add = {}
                            table.insert(to_add, cell.name)
                            for _, door in ipairs(cell:getAll(types.Door)) do
                                local destCell = types.Door.destCell(door)
                                if destCell ~= nil then
                                    if not destCell.isExterior then
                                        foundReverseConnection = false
                                        for _, inverseDoor in ipairs(destCell:getAll(types.Door)) do
                                            local invertCell = types.Door.destCell(inverseDoor)
                                            if invertCell ~= nil then
                                                if invertCell.name == cell.name then
                                                    foundReverseConnection = true
                                                end
                                            end
                                        end
                                        if foundReverseConnection then
                                            table.insert(to_add, destCell.name)
                                        end
                                    end
                                end
                            end
                            add_connected_group_to_cell_path_table(to_add)
                        end
                        cell_pos = cell_pos + 1
                    else
                        if not tested then
                            print_result()
                        end
                        tested = true
                    end
                end
            end
        end
    }
}