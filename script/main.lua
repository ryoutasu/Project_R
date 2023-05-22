--py
require 'python'
Python = python
GameAPI = gameapi
GlobalAPI = globalapi
Fix32Vec3 = Fix32Vec3
Fix32 = Fix32
New_global_trigger = new_global_trigger
New_modifier_trigger = new_modifier_trigger
New_item_trigger = new_item_trigger
-- constant --
PLAYER_CAMP_ID = 1
NEUTRAL_ENEMY_CAMP_ID = 31
NEUTRAL_FRIEND_CAMP_ID = 32

SUMMON_UNITS = {}
MAX_SUMMON_NUM = 5
PLAYER_MAX = 1
ALL_PLAYER = GameAPI.get_all_role_ids()
UI_EVENT_LIST = {
    ['none'] = -1,
    ['click_start'] = 1,
    ['click_end'] = 2,
    ['click_hover'] = 3,
    ['double_click'] = 22,
    ['hover'] = 23,
    ['move_in'] = 24,
    ['move_out'] = 25,
    ['right_click'] = 26,
}

-- GLOBAL_TABLES - tables
-- cli.copy_table - deep copy

require 'up'
---resource block start---
---The resource usage statement should be at the beginning of the script and the comments at the beginning and end of this section cannot be modified!!!  xxx_id refer to maps/offical_expr_data/trigger_related_xxx.json

local setmetatable = setmetatable

require 'moveSystem'
require 'ui'

local MAP_RECT = GameAPI.get_usable_map_range()

function GetArgs(func)
    local args = {}
    for i = 1, debug.getinfo(func).nparams, 1 do
        table.insert(args, debug.getlocal(func, i));
    end
    return args;
end

up.game:event('Game-Init', function ()
    -- up.wait(0, function()
        print 'Game start'
        local player = up.player(1)
        local point = up.actor_point(10039)
        player:set_camera(point, 0)

        local opacity = 100
        local blackout = GameAPI.get_comp_by_absolute_path(player._base, 'GameHUD.blackout')
        GameAPI.set_ui_comp_opacity(player._base, blackout, opacity)
        GameAPI.set_ui_comp_visible(player._base, true, blackout)

        local t
        t = up.loop(1/30, function()
            opacity = opacity - 1
            GameAPI.set_ui_comp_opacity(player._base, blackout, opacity)
            if opacity <= 0 then
                GameAPI.set_ui_comp_visible(player._base, false, blackout)

                local hero = up.create_unit(134252905, point, 270, player)
                GameAPI.set_trigger_variable_unit_entity('hero', hero._base)
                set_player_movement(player, hero)
                init_ui(player, hero)


                t:remove()
            end
        end)
    -- end)
end)


