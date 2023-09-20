local check_time = tonumber(core.settings:get("anticheatf_check_time")) or 5 -- In secs

local suspected = {}

minetest.register_on_joinplayer(function(name)
    if suspected[name] ~= nil then
        suspected[name] = nil
    end
end)

local function check_fly(player)
    local name = player:get_player_name()
    local vel = player:get_player_velocity()
    local pos = player:get_pos()
    pos.y = pos.y - 2
    if not minetest.check_player_privs(name, {fly = true}) then
        if minetest.get_node(pos).name == "air" then
            if vector.length(vel) > 3 then
                if suspected[name] ~= nil then
                    suspected[name] = suspected[name] + 1
                else
                    suspected[name] = 1
                end
            end
        end
    end
end

local function check_noclip(player)
    local name = player:get_player_name()
    local vel = player:get_player_velocity()
    local pos = player:get_pos()
    if not minetest.check_player_privs(name, {noclip = true}) then
        if minetest.get_node(pos).name ~= "air" then
            if vector.length(vel) > 3 then
                if suspected[name] ~= nil then
                    suspected[name] = suspected[name] + 1
                else
                    suspected[name] = 1
                end
            end
        end
    end
end

local timer = 0
local timer2 = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    timer2 = timer2 + dtime
    if timer >= check_time then
        timer = 0
        for _, player in ipairs(minetest.get_connected_players()) do
            check_fly(player)
            check_noclip(player)
            local name = player:get_player_name()
            if suspected[name] == 3 then
                suspected[name] = 0
                minetest.kick_player(name, "You was suspected of using cheats (AntiCheat)")
            end
            if timer2 >= 60 then
                timer2 = 0
                if suspected[name] ~= nil or suspected[name] ~= 0 then
                    suspected[name] = 0
                end
            end
        end
    end
end)
