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

function copy_rect_to(rect, point)
    
end


up.game:event('Game-Init', function ()
    -- up.wait(0, function()
        print 'Game start'
        local point = up.actor_point(10039)
        local player = up.player(1)
        local hero = up.create_unit(134252905, point, 270, player)
        set_player_movement(player, hero)

    -- end)
end)


