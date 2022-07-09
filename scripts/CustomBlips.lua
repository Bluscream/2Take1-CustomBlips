local function clearConsole() for _=1, 50 do print(" ") end end
clearConsole()
package.path = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\?.lua;"..package.path
require("Kek's Natives")

local function create_dir(dir) if not utils.dir_exists(dir) then utils.make_dir(dir) end end

local blipsDir = utils.get_appdata_path("PopstarDevs", "2Take1Menu".."\\cfg\\blips\\")
create_dir(blipsDir)

local function isCommentOrWhiteSpace(line) return line == nil or line == "" or line == " " or line == "\t" or line == "\r" or line == "\n" or line == "\r\n" or line:sub(1,3) == "-- " end
function string.starts(String,Start) return string.sub(String,1,string.len(Start))==Start end
local function printtable(table, indent)
    indent = indent or 0;
    local keys = {};
    for k in pairs(table) do
      keys[#keys+1] = k;
    end
    print(string.rep('  ', indent)..'{');
    indent = indent + 1;
    for k, v in pairs(table) do
      local key = k;
      if (type(key) == 'string') then
        if not (string.match(key, '^[A-Za-z_][0-9A-Za-z_]*$')) then
          key = "['"..key.."']";
        end
      elseif (type(key) == 'number') then
        key = "["..key.."]";
      end
      if (type(v) == 'table') then
        if (next(v)) then
          print(string.rep('  ', indent) .. tostring(key) .. " =");
          printtable(v, indent);
        else
          print(string.rep('  ', indent) .. tostring(key) .. " = {},");
        end 
      elseif (type(v) == 'string') then
        print(string.rep('  ', indent) .. tostring(key) .. " = '"..v.."',");
      else
        print(string.rep('  ', indent) .. tostring(key) .. " = "..tostring(v)..",");
      end
    end
    indent = indent - 1;
    print(string.rep('  ', indent)..'}');
end
local function lines_from(file)
    if not utils.file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do 
        lines[#lines + 1] = line
    end
    return lines
end
local function array_concat(table1, table2)
    for _,v in ipairs(table2) do 
        table.insert(table1, v)
    end
end
local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
 end
local function GetRandomBool()
    local trueAndFalse = {true, false}
    return trueAndFalse[math.random(1, 2)]
end
local function contains(table, val)
    for i=1,#table do
       if table[i] == val then 
          return true
       end
    end
    return false
end
local function notify(text, success)
    success = success or true
    menu.notify(text, "CustomBlips", 3, success and 0xff0000ff or 0xffffffff)
end
local function parseString(string)
    if tonumber(string) ~= nil then return tonumber(string)
    elseif string == "true" then return true
    elseif string == "false" then return false
    end return string
end
local function ParseBlipLine(line, sep)
    local blip = {}
    local line = split(line, sep)
    for i,section in ipairs(line) do
        local section = split(section, "=")
        blip[section[1]:lower()] = parseString(section[2])
    end
    return blip
end
local function loadBlipsCSV(file)
    print("Loading blips from file "..tostring(file))
    local blips = {}
    local lines = lines_from(file)
    for i,line in ipairs(lines) do
        if not isCommentOrWhiteSpace(line) then
            table.insert(blips, ParseBlipLine(line, ";"))
        end
    end
    print("Loading " .. #blips .. " blips from file "..tostring(file))
    return blips
end
local function loadBlipsDir(dir)
    print("Loading blips from directory "..tostring(dir))
    local blips = {}
    local files = utils.get_all_files_in_directory(dir, "csv")
    for i,file in ipairs(files) do
        array_concat(blips, loadBlipsCSV(dir .. "\\" .. file))
    end
    print("Loaded " .. #blips .. " blips from directory "..tostring(dir))
    return blips
end

staticBlips = {}
entityBlips = {}

local function AddBlipForCoord(x, y, z)
    local coords = v3(x, y, z)
    local blip = ui.add_blip_for_coord(coords)
    staticBlips[coords] = blip -- table.insert(currentBlips, blip)
    return blip
end
local function AddBlipForEntity(entity,sprite,color,size,alpha,secondary_color_r,secondary_color_g,secondary_color_b,route_enabled,route_colour,player,fade_opacity,fade_duration,rotation,flash_duration,flash_p1,hidden_on_legend,high_detail,mission_creator,flashes,flashes_alternate,short_range,priority,displayid,category_index,friendly,extended_height,minimal_on_edge,bright,cone,cone_hudcolorindex,text)
    local blip = ui.add_blip_for_entity(entity)
    if sprite then ui.set_blip_sprite(blip, sprite) end
    if color then ui.set_blip_colour(blip, color) end
    if secondary_color_r then hud.set_blip_secondary_colour(blip, secondary_color_r, secondary_color_g, secondary_color_b) end
    if size then hud.set_blip_scale(blip, size) end
    if alpha then ui.set_blip_alpha(blip, alpha) end

    if route_enabled then ui.set_blip_route(blip, route_enabled) end
    if route_colour then ui.set_blip_route_colour(blip, route_colour) end
    if player then hud.set_blip_name_to_player_name(player) end
    if fade_opacity then hud.set_blip_fade(blip, fade_opacity, fade_duration) end
    if rotation then hud.set_blip_rotation(blip, rotation) end
    if flash_duration then hud.set_blip_flash_timer(blip, flash_duration) end
    if flash_p1 then hud.set_blip_flash_interval(blip, flash_p1) end
    if hidden_on_legend then hud.set_blip_hidden_on_legend(blip, hidden_on_legend) end
    if high_detail then hud.set_blip_high_detail(blip, high_detail) end
    if mission_creator then ui.set_blip_as_mission_creator_blip(blip, mission_creator) end
    if flashes then hud.set_blip_flashes(blip, flashes) end
    if flashes_alternate then hud.set_blip_flashes_alternate(blip, flashes_alternate) end
    if short_range then hud.set_blip_as_short_range(blip, short_range) end
    if priority then hud.set_blip_priority(blip, priority) end
    if displayid then hud.set_blip_display(blip, displayid) end
    if category_index then hud.set_blip_category(blip, category_index) end
    if friendly then hud.set_blip_as_friendly(blip, friendly) end
    if extended_height then hud.set_blip_extended_height_threshold(blip, extended_height) end
    if minimal_on_edge then hud.set_blip_as_minimal_on_edge(blip, minimal_on_edge) end
    if bright then hud.set_blip_bright(blip, bright) end
    if cone then hud.set_blip_show_cone(blip, cone, cone_hudcolorindex) end
    if text then
        hud.begin_text_command_set_blip_name("STRING");
        hud.add_text_component_substring_player_name(text);
        hud.end_text_command_set_blip_name(blip);
    end

    entityBlips[entity] = blip -- table.insert(currentBlips, blip)
    return blip
end

local function removeEntityBlips()
    notify("Removing " .. #entityBlips .. " entity blips")
    for k,v in pairs(entityBlips) do
        ui.remove_blip(v)
        coroutine.yield(1)
    end
    entityBlips = {}
end
local function removeStaticBlips()
    notify("Removing " .. #staticBlips .. " static blips")
    for k,v in pairs(staticBlips) do
        ui.remove_blip(v)
        coroutine.yield(1)
    end
    staticBlips = {}
end

-- for _,v in pairs(blipIds) do
--     local blip = GetFirstBlipInfoId(v)

--     while DoesBlipExist(blip) do
--         if isBlipAttachedToPlayer(blip) then
--             SetBlipAlpha(blip, 0) -- Lambda doesn't touch alpha, it's safe to set it :)
--         end
        
--         blip = GetNextBlipInfoId(v)
--     end

-- end
local function removeBlip(sprite, blip, count, fails)
    count = count+1
    local success = ui.remove_blip(blip)
    print("Removing blip "..tostring(blip).." ("..tostring(sprite)..")... success: "..tostring(success))
    if not success then fails = fails+1 end
    return {count=count, fails=fails}
end
local function removeNativeBlips()
    local count = 0;local fails = 0
    for i = 3, 826 do
        local blip = hud.get_first_blip_info_id(i)
        if blip ~= 0 and hud.does_blip_exist(blip) then
            local next = hud.get_next_blip_info_id(i)
            while next ~= 0 and hud.does_blip_exist(next) do
                local result = removeBlip(i, next, count, fails)
                count = result.count; fails = result.fails
                next = hud.get_next_blip_info_id(i)
                -- system.yield(0)
            end
            local result = removeBlip(i, blip, count, fails)
            count = result.count; fails = result.fails
        end
        -- system.yield(0)
    end
    print("Removed "..tostring(count).." blips, failed "..tostring(fails))
end
local function removeAllBlips()
    notify("Removing all blips")
    removeEntityBlips()
    removeStaticBlips()
    local entitys = {}
    -- table.insert(entitys, ped.get_all_peds())
    -- table.insert(entitys, vehicle.get_all_vehicles())
    -- table.insert(entitys, object.get_all_objects())
    -- table.insert(entitys, object.get_all_pickups())
    for i,entity in ipairs(entitys) do
        local blip = ui.get_blip_from_entity(entity)
        print("entity: "..tostring(entity).." blip: "..tostring(blip))
        if blip ~= 0 then ui.remove_blip(blip) end
        coroutine.yield(1)
    end
    removeNativeBlips()
end

local onExit = event.add_event_listener("exit",function()
    removeAllBlips()
    print("CustomBlips unloaded. Cleanup Successful.")
    notify("CustomBlips unloaded.\nCleanup Successful.", false)
end)

scriptMenu = {items = {}}
local initMenu = function()
    scriptMenu.root = menu.add_feature("Custom Blips", "parent", 0)
    scriptMenu.vehicles = menu.add_feature("Vehicles", "parent", scriptMenu.root.id)
    scriptMenu.items.vehicles = {}
    menu.add_feature("Clear all blips", "action", scriptMenu.root.id, removeAllBlips)
end
local initVehicleMenu = function()
    for i,item in ipairs(scriptMenu.items.vehicles) do
        menu.delete_feature(item.id)
    end
    scriptMenu.items.vehicles = {}
    local vehicleDir = blipsDir.."vehicles"
    create_dir(vehicleDir)
    local veh_blips = loadBlipsDir(vehicleDir)
    printtable(veh_blips, 2)
    for i, _blip in ipairs(veh_blips) do
        local vehicleName = _blip.entity
        local sprite = _blip.sprite
        local color = _blip.color
        local size = _blip.size
        local alpha = _blip.alpha
        table.insert(scriptMenu.items.vehicles, menu.add_feature(vehicleName, "toggle", scriptMenu.vehicles.id, function(value)
            local vehName = string.upper(vehicleName)
            while value.on do
                local vlist = vehicle.get_all_vehicles()
                for i = 1, #vlist do
                    if not value.on then
                        notify("Disabled Blips for Vehicle " .. vehicleName)
                        return
                    end
                    local name = vehicle.get_vehicle_model_label(vlist[i])
                    if name == vehName then
                        local blip = ui.get_blip_from_entity(vlist[i])
                        print("blip = " .. tostring(blip))
                        if blip == 0 then
                            print("Adding Blip for " .. name)
                            AddBlipForEntity(vlist[i], sprite, color, size, alpha)
                        end
                    end
                end
                coroutine.yield(1000)
            end
        end))
    end
end

initMenu()
initVehicleMenu()

notify(hud.get_number_of_active_blips() .. " blips active")

misc.set_this_script_can_remove_blips_created_by_any_script(true)