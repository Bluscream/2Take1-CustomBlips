local function clearConsole() for _=1, 50 do print(" ") end end
clearConsole()
package.path = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\?.lua;"..package.path
require("Kek's Natives")
local ini = require("fuelMod\\ini_parser")

local function create_dir(dir) if not utils.dir_exists(dir) then utils.make_dir(dir) end end
local paths = {}
paths.cfgDir = utils.get_appdata_path("PopstarDevs", "2Take1Menu".."\\cfg\\")
paths.cfgFile = paths.cfgDir.."CustomBlips.ini"
paths.blipsDir = paths.cfgDir.."blips\\"
create_dir(paths.blipsDir)

local scriptSettings = {
    general = {
        autoExecDelayMS = 10,
        autoLoadFromSettings = true
    },
    enabledStaticLists = {},
    enabledVehicleBlips = {}
}

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
    print("CustomBlips > "..text)
end
local function parseString(string)
    if tonumber(string) ~= nil then return tonumber(string)
    elseif string == "true" then return true
    elseif string == "false" then return false
    end return string
end
local function writeINI(file_path, content)
    local file_path = file_path or paths.cfgFile
    print("scriptSettings:")
    printtable(scriptSettings)
    local content = content or scriptSettings
    print("content:")
    printtable(content)
    print("Writing "..tostring(content).." to "..file_path)
    local iniFile = io.open(file_path, "w")
    for section_name,section_content in pairs(content) do
        if section_name ~= "save" then
            iniFile:write("["..tostring(section_name).."]\n")
            for item_name,item_value in pairs(section_content) do
                iniFile:write(tostring(item_name) .. "=" .. tostring(item_value) .. "\n")
            end
        end
    end
    iniFile:close()
end
local function setSetting(section, key, value)
    print("setSetting: "..section.."["..key.."] = "..tostring(value))
    if section == "save" then return end
    local section = section or "general"
    scriptSettings[section][key] = value
    writeINI()
end
local function ParseBlipLine(line, sep)
    local blip = { z = 30 }
    local line = split(line, " -- ")[1]
    line = split(line, sep)
    for i,section in ipairs(line) do
        local section = split(section, "=")
        blip[section[1]:lower()] = parseString(section[2])
    end
    return blip
end
local function SetBlipText(blip, text)
    -- local entry = "BLIP_"..text:gsub("% ", "_")
    -- hud.add_text_entry(entry, text)
    hud.begin_text_command_set_blip_name("STRING");
    hud.add_text_component_substring_player_name(text);
    hud.end_text_command_set_blip_name(blip);
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
    print("Loaded " .. #blips .. " blips from file "..tostring(file))
    return blips
end
local function loadBlipsDir(dir, joined)
    joined = joined or false
    print("Loading blips from directory "..tostring(dir)..(joined and " as joined" or ""))
    local blips = {}
    local files = utils.get_all_files_in_directory(dir, "blips")
    for i,file in ipairs(files) do
        local file_blips = loadBlipsCSV(dir .. "\\" .. file)
        if joined then array_concat(blips, file_blips)
        else blips[file] = file_blips end
    end
    print("Loaded " .. #blips .. " blips from directory "..tostring(dir))
    return blips
end
local function loadSettings(file_path, default)
    local file_path = file_path or paths.cfgFile
    local default = default or scriptSettings
    if utils.file_exists(file_path) then
        scriptSettings = ini.parse(file_path)
    else
        notify("Failed to find config file, creating default!", false)
        writeINI(file_path, default)
    end
end

staticBlips = {}

local function AddBlip(_blip) -- x,y,z,entity,sprite,color,size,alpha,secondary_color_r,secondary_color_g,secondary_color_b,route_enabled,route_colour,player,fade_opacity,fade_duration,rotation,flash_duration,flash_p1,hidden_on_legend,high_detail,mission_creator,flashes,flashes_alternate,short_range,priority,displayid,category_index,friendly,extended_height,minimal_on_edge,bright,cone,cone_hudcolorindex,text
    local blip = _blip.x and ui.add_blip_for_coord(v3(_blip.x, _blip.y, _blip.z or 30)) or ui.add_blip_for_entity(_blip.entity)
    if _blip.sprite then ui.set_blip_sprite(blip, _blip.sprite) end
    if _blip.color then ui.set_blip_colour(blip, _blip.color) end
    if _blip.secondary_color_r then hud.set_blip_secondary_colour(blip, _blip.secondary_color_r, _blip.secondary_color_g, _blip.secondary_color_b) end
    if _blip.size then hud.set_blip_scale(blip, _blip.size) end
    if _blip.alpha then hud.set_blip_alpha(blip, _blip.alpha) end
    if _blip.route_enabled then ui.set_blip_route(blip, _blip.route_enabled) end
    if _blip.route_colour then ui.set_blip_route_colour(blip, _blip.route_colour) end
    if _blip.player then hud.set_blip_name_to_player_name(player) end
    if _blip.fade_opacity then hud.set_blip_fade(blip, _blip.fade_opacity, _blip.fade_duration) end
    if _blip.rotation then hud.set_blip_rotation(blip, _blip.rotation) end
    if _blip.flash_duration then hud.set_blip_flash_timer(blip, _blip.flash_duration) end
    if _blip.flash_p1 then hud.set_blip_flash_interval(blip, _blip.flash_p1) end
    if _blip.hidden_on_legend then hud.set_blip_hidden_on_legend(blip, _blip.hidden_on_legend) end
    if _blip.high_detail then hud.set_blip_high_detail(blip, _blip.high_detail) end
    if _blip.mission_creator then ui.set_blip_as_mission_creator_blip(blip, _blip.mission_creator) end
    if _blip.flashes then hud.set_blip_flashes(blip, _blip.flashes) end
    if _blip.flashes_alternate then hud.set_blip_flashes_alternate(blip, _blip.flashes_alternate) end
    if _blip.short_range then hud.set_blip_as_short_range(blip, _blip.short_range) end
    if _blip.priority then hud.set_blip_priority(blip, _blip.priority) end
    if _blip.displayid then hud.set_blip_display(blip, _blip.displayid) end
    if _blip.category_index then hud.set_blip_category(blip, _blip.category_index) end
    if _blip.friendly then hud.set_blip_as_friendly(blip, _blip.friendly) end
    if _blip.extended_height then hud.set_blip_extended_height_threshold(blip, _blip.extended_height) end
    if _blip.minimal_on_edge then hud.set_blip_as_minimal_on_edge(blip, _blip.minimal_on_edge) end
    if _blip.bright then hud.set_blip_bright(blip, _blip.bright) end
    if _blip.cone then hud.set_blip_show_cone(blip, _blip.cone, _blip.cone_hudcolorindex) end
    if _blip.text then SetBlipText(blip, _blip.text) end
    return blip
end

-- local function removeEntityBlips()
--     notify("Removing " .. #entityBlips .. " entity blips")
--     for k,v in pairs(entityBlips) do
--         ui.remove_blip(v)
--         -- if coroutine.yield~=nil then coroutine.yield(1) end
--     end
--     entityBlips = {}
-- end
local function removeStaticBlips()
    notify("Removing " .. #staticBlips .. " static blips")
    for k,v in pairs(staticBlips) do
        ui.remove_blip(v)
        -- if coroutine.yield~=nil then coroutine.yield(1) end
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
    -- removeEntityBlips()
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
    for i,item in ipairs(scriptMenu.items.vehicles) do
        item.on = false
    end
    print("CustomBlips unloaded. Cleanup Successful.")
    notify("CustomBlips unloaded.\nCleanup Successful.", false)
end)


local initVehicleMenu = function()
    for i,item in ipairs(scriptMenu.items.vehicles) do
        menu.delete_feature(item.id)
    end
    scriptMenu.items.vehicles = {}
    scriptMenu.blips.vehicles = {}
    local vehicleDir = paths.blipsDir.."vehicles"
    create_dir(vehicleDir)
    local veh_blips = loadBlipsDir(vehicleDir, true)
    -- printtable(veh_blips, 2)
    for i, _blip in ipairs(veh_blips) do
        scriptMenu.blips.vehicles[_blip.vehicle] = {}
        table.insert(scriptMenu.items.vehicles, menu.add_feature(_blip.vehicle, "toggle", scriptMenu.vehicles.id, function(item)
            local Disable = function()
                notify("Disabled Blips for Vehicle " .. _blip.vehicle, false)
                for i,blip in ipairs(scriptMenu.blips.vehicles[_blip.vehicle]) do
                    ui.remove_blip(blip)
                end
            end
            setSetting("enabledVehicleBlips", _blip.vehicle, item.on)
            if item.on then
                notify("Enabled Blips for Vehicle " .. _blip.vehicle)
                local vehName = string.upper(_blip.vehicle)
                while item.on do
                    local vlist = vehicle.get_all_vehicles()
                    for i = 1, #vlist do
                        if not item.on then
                            break
                        end
                        local name = vehicle.get_vehicle_model_label(vlist[i])
                        if name == vehName then
                            local blip = ui.get_blip_from_entity(vlist[i])
                            if blip == 0 then
                                _blip.entity = vlist[i]
                                local blip = AddBlip(_blip)
                                table.insert(scriptMenu.blips.vehicles[_blip.vehicle], blip)
                            end
                        end
                    end
                    coroutine.yield(1000)
                end
            else
                Disable()
            end
        end))
    end
    for i,item in ipairs(scriptMenu.items.vehicles) do
        local isAutostart = scriptSettings.enabledVehicleBlips[item.name]
        if isAutostart == true then
            item.on = isAutostart
        end
        if system.yield~=nil then system.yield(scriptSettings.general.autoExecDelayMS) end
    end
end

local initStaticMenu = function()
    for i,item in ipairs(scriptMenu.items.static) do
        menu.delete_feature(item.id)
    end
    scriptMenu.items.static = {}
    scriptMenu.blips.static = {}
    local coord_blips = loadBlipsDir(paths.blipsDir)
    for file_name, blips in pairs(coord_blips) do
        scriptMenu.blips.static[file_name] = {}
        local name = file_name:gsub("%.blips", "")
        table.insert(scriptMenu.items.static, menu.add_feature(name, "toggle", scriptMenu.static.id, function(item)
            setSetting("enabledStaticLists", name, item.on)
            if item.on then
                -- printtable(coord_blips, 2)
                for i, _blip in ipairs(blips) do
                    print("Adding Blip for ".._blip.text.." at "..tostring(v3(_blip.x,_blip.y,_blip.z or 30)))
                    local blip = AddBlip(_blip)
                    staticBlips[v3(_blip.x,_blip.y,_blip.z)] = blip
                    table.insert(scriptMenu.blips.static[file_name], blip)
                end
                notify("Enabled Blips for "..name, true)
            else
                for i, blip in ipairs(scriptMenu.blips.static[file_name]) do
                    ui.remove_blip(blip)
                end
                notify("Disabled Blips for "..name, false)
            end
        end))
    end
    for i,item in ipairs(scriptMenu.items.static) do
        local isAutostart = scriptSettings.enabledStaticLists[item.name]
        if isAutostart == true then
            item.on = isAutostart
        end
        if system.yield~=nil then system.yield(scriptSettings.general.autoExecDelayMS) end
    end
end

local initSettingsMenu = function()
    menu.add_feature("Save settings", "action", scriptMenu.settings.id, function()
        writeINI()
        notify("Saved settings.", true)
        loadSettings(paths.cfgFile, scriptSettings)
    end)
    menu.add_feature("Reload settings", "action", scriptMenu.settings.id, function()
        loadSettings(paths.cfgFile, scriptSettings)
        notify("Settings file reloaded.")
    end)

    for setting,value in pairs(scriptSettings.general) do
        local feat = "action_value_str"
        local setting_return_var = "value"
        if setting == true or setting == false then
            feat = "bool"
            setting_return_var = "on"
        end
        table.insert(scriptMenu.items.settings, menu.add_feature(setting, feat, scriptMenu.settings.id, function(item)
            setSetting("general", item.name, item[setting_return_var])
        end))
    end
end

scriptMenu = {items = {}, blips = {}}
local initMenu = function()
    scriptMenu.root = menu.add_feature("Custom Blips", "parent", 0)
    scriptMenu.vehicles = menu.add_feature("Vehicles", "parent", scriptMenu.root.id)
    scriptMenu.items.vehicles = {}
    initVehicleMenu()
    scriptMenu.static = menu.add_feature("Static Blips", "parent", scriptMenu.root.id)
    scriptMenu.items.static = {}
    initStaticMenu()
    menu.add_feature("Clear all blips", "action", scriptMenu.root.id, removeAllBlips)
    scriptMenu.settings = menu.add_feature("Settings", "parent", scriptMenu.root.id)
    scriptMenu.items.settings = {}
    initSettingsMenu()
end

menu.create_thread(function()
    system.yield(10)
    loadSettings()
    initMenu()
    notify(hud.get_number_of_active_blips() .. " blips active")
    misc.set_this_script_can_remove_blips_created_by_any_script(true)
end, nil)
