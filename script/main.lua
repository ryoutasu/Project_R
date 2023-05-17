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
UI_EVENT_LIST = {}

-- GLOBAL_TABLES - tables
-- cli.copy_table - deep copy

require 'up'
---resource block start---
---The resource usage statement should be at the beginning of the script and the comments at the beginning and end of this section cannot be modified!!!  xxx_id refer to maps/offical_expr_data/trigger_related_xxx.json

local setmetatable = setmetatable

require 'moveSystem'

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
        local point = up.actor_point(10039)
        local player = up.player(1)
        local hero = up.create_unit(134252905, point, 270, player)
        -- GameAPI.set_trigger_variable_unit_entity('hero', hero._base)
        set_player_movement(player, hero)

        local main_panel = GameAPI.get_comp_by_absolute_path(player._base, 'GameHUD.main_panel')
        for i = 1, 4 do
            local skill = hero:find_skill('Hero', nil, i)
            local btn = GameAPI.get_comp_by_path(player._base, main_panel, 'skill_list.skill_btn_' .. i .. '.skill_btn')
            if skill then
                GameAPI.set_skill_on_ui_comp(player._base, skill._base, btn)
                GameAPI.set_ui_comp_visible(player._base, true, btn)
                -- GameAPI.set_role_key_float_kv(player._base, 'skill_btn_'..i, skill._base)
            else
                GameAPI.unbind_ui_comp(player._base, btn)
                GameAPI.set_ui_comp_visible(player._base, false, btn)
            end
        end

        local hp_bar = GameAPI.get_comp_by_path(player._base, main_panel, 'hp_bar')
        GameAPI.set_ui_comp_bind_attr(player._base, hp_bar, 'current_value_bind', 'hp_cur', 2)
        GameAPI.set_ui_comp_bind_attr(player._base, hp_bar, 'max_value_bind', 'hp_max', 2)
        GameAPI.ui_comp_bind_unit(player._base, hp_bar, hero._base)
        
        local mp_bar = GameAPI.get_comp_by_path(player._base, main_panel, 'mp_bar')
        GameAPI.set_ui_comp_bind_attr(player._base, mp_bar, 'current_value_bind', 'mp_cur', 2)
        GameAPI.set_ui_comp_bind_attr(player._base, mp_bar, 'max_value_bind', 'mp_max', 2)
        GameAPI.ui_comp_bind_unit(player._base, mp_bar, hero._base)
        
        local hp_text = GameAPI.get_comp_by_path(player._base, hp_bar, 'hp_value')
        local mp_text = GameAPI.get_comp_by_path(player._base, mp_bar, 'mp_value')
        up.loop(1/30, function ()
            local hp = tostring(math.floor(hero:get('hp_cur'))) .. '/' .. tostring(math.floor(hero:get('hp_max')))
            local mp = tostring(math.floor(hero:get('mp_cur'))) .. '/' .. tostring(math.floor(hero:get('mp_max')))
            GameAPI.set_ui_comp_text(player._base, hp_text, hp)
            GameAPI.set_ui_comp_text(player._base, mp_text, mp)
        end)
    -- end)
end)


