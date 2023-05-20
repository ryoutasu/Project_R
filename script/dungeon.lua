local rooms = {}
local areas = GLOBAL_TABLES.Dungeon

function dungeon_init()
    -- rooms_n = number_of_rooms
    for key, value in pairs(areas) do
        r = {}
        rooms[key] = r
        r.spawn = up.actor_point(value.spawn)
        r.exit = GameAPI.get_circle_area_by_res_id(value.exit)
        r.visited = false
    end


end