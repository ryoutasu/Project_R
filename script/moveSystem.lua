local tickrate = 1/30
local attack_slow = 80
local defend_slow = 40
local time_to_reset_attack = 3

local Player = {}

local attack_projectile = {
    134281458,
    134245113,
    134245644
}

local function dash(player, direction, end_dash)
    local unit = Player[player].unit

    local speed = GameAPI.get_unit_key_float_kv(unit:get_key(), 'dash_speed')
    local distance = GameAPI.get_unit_key_float_kv(unit:get_key(), 'dash_distance')
    local dash_effect = GameAPI.get_unit_key_model_kv(unit:get_key(), 'dash_effect')
    up.particle{ model = dash_effect, target = unit:get_point(), angle = direction, time = -1 }

    local unit_collide = function()
        -- print('unit collide')
    end
    local mover_finish = function()
        -- print('mover finish')
        GameAPI.break_unit_mover(unit._base)
    end
    local terrain_collide = function()
        -- print('terrain collide')
        GameAPI.break_unit_mover(unit._base)
    end
    local mover_interrupt = function()
        -- print('mover interrupt')
        GameAPI.break_unit_mover(unit._base)
    end
    local mover_removed = function()
        -- print('mover removed')
        if end_dash then
            end_dash()
        end
    end

    local angle              = Fix32(direction)
    local max_dist           = Fix32(distance)
    local init_velocity      = Fix32(speed)
    local acceleration       = Fix32(0)
    local max_velocity       = Fix32(99999)
    local min_velocity       = Fix32(0)
    local init_height        = Fix32(0)
    local fin_height         = Fix32(0)
    local parabola_height    = Fix32(0)
    local collision_type     = 0
    local collision_radius   = Fix32(65)
    local is_face_angle      = true
    local is_multi_collision = false
    local terrain_block      = true
    local priority           = 1
    local is_parabola_height = false

    GameAPI.create_straight_mover(unit._base, angle, max_dist, init_velocity, acceleration, max_velocity,
        min_velocity, init_height, fin_height, parabola_height, collision_type, collision_radius,
        is_face_angle, is_multi_collision, terrain_block, priority, is_parabola_height,
        mover_finish, mover_interrupt, mover_removed, terrain_collide, unit_collide)
end

local function create_projectile(player, attack_num, direction)
    local unit = Player[player].unit
    local projectile = GameAPI.create_projectile_on_socket(attack_projectile[attack_num],
        unit._base, 'weapon1', Fix32(direction), unit._base, nil, 1)
    
    local speed = GameAPI.get_projectile_key_float_kv(projectile:api_get_key(), 'speed')
    local distance = GameAPI.get_projectile_key_float_kv(projectile:api_get_key(), 'distance')
    local radius = GameAPI.get_projectile_key_float_kv(projectile:api_get_key(), 'collision_radius')
    local damage = GameAPI.get_projectile_key_float_kv(projectile:api_get_key(), 'damage')
    local damage_effect = GameAPI.get_projectile_key_model_kv(projectile:api_get_key(), 'damage_effect')
    local finish_effect = GameAPI.get_projectile_key_model_kv(projectile:api_get_key(), 'finish_effect')

    local unit_collide = function()
        -- print('unit collide')
        local hit_target = up.actor_unit(GameAPI.get_mover_collide_unit())
        unit:damage{ target = hit_target, damage = damage }
        if damage_effect then
            up.particle{ target = hit_target, model = damage_effect, time = -1}
        end

        if attack_num ~= 3 then
            GameAPI.break_unit_mover(projectile)
        end
    end
    local mover_finish = function()
        -- print('mover finish')
    end
    local terrain_collide = function()
        -- print('terrain collide')
        -- local list = GameAPI.get_all_dest_in_point_rng(projectile.api_get_position(), Fix32(radius:float()/100))
        -- for i in Python.enumerate(list) do
        --     local d = list[i]
        --     print(i, d)
        --     if d.api_is_alive() and d.api_is_attacked() then
        --         print('is attacked')
        --         -- d.api_add_hp_cur_value(Fix32(damage))
        --         d.api_delete()
        --     end
        -- end

        GameAPI.break_unit_mover(projectile)
    end
    local mover_interrupt = function()
        -- print('mover interrupt')
    end
    local mover_removed = function()
        -- print('mover removed')
        if damage_effect then
            up.particle{ target = up.actor_point(projectile.api_get_position()), model = finish_effect, time = -1}
        end
        
        projectile:api_delete()
    end

    local angle              = Fix32(direction)
    local max_dist           = Fix32(distance)
    local init_velocity      = Fix32(speed)
    local acceleration       = Fix32(0)
    local max_velocity       = Fix32(99999)
    local min_velocity       = Fix32(0)
    local init_height        = Fix32(65)
    local fin_height         = Fix32(65)
    local parabola_height    = Fix32(0)
    local collision_type     = 0
    local collision_radius   = Fix32(radius)
    local is_face_angle      = true
    local is_multi_collision = false
    local terrain_block      = true
    local priority           = 1
    local is_parabola_height = false

    GameAPI.create_straight_mover(projectile, angle, max_dist, init_velocity, acceleration, max_velocity,
        min_velocity, init_height, fin_height, parabola_height, collision_type, collision_radius, is_face_angle,
        is_multi_collision, terrain_block, priority, is_parabola_height,
        mover_finish, mover_interrupt, mover_removed, terrain_collide, unit_collide)
end

local function get_dest_point(player)
    local unit = Player[player].unit
    local dx, dy = 0, 0
    if player:is_key_pressed('W') then
        dy = dy - 1
    end
    if player:is_key_pressed('S') then
        dy = dy + 1
    end

    if player:is_key_pressed('A') then
        dx = dx - 1
    end
    if player:is_key_pressed('D') then
        dx = dx + 1
    end

    local m = math.sqrt(dx*dx + dy*dy)
    dx = dx / m
    dy = dy / m

    local point = unit:get_point()
    local speed = unit:get('move_speed')
    local x = dx*speed*tickrate
    local y = dy*speed*tickrate

    local dest_point = up.point(point.x + x, point.y + y, point.z)
    return dest_point, (x ~= 0 or y ~= 0)
end

up.game:event('Mouse-LeftDown', function(_, player)
    if not Player[player] then return end

    Player[player].lmb_pressed = true
end)
up.game:event('Mouse-LeftRelease', function(_, player)
    if not Player[player] then return end
    
    if Player[player].lmb_pressed then
        Player[player].lmb_pressed = false
    end
end)

up.game:event('Mouse-RightDown', function (_, player)
    if not Player[player] then return end
    
    Player[player].rmb_pressed = true
end)
up.game:event('Mouse-RightRelease', function (_, player)
    if not Player[player] then return end
    
    if Player[player].rmb_pressed then
        Player[player].rmb_pressed = false
    end
end)

up.game:event('Keyboard-Down', function (_, player, key)
    if not Player[player] then return end
    
    if key == KEY['SPACE'] then
        Player[player].space_pressed = true
    end
end)

function set_player_movement(player, unit)
    player:set_mouse_click(false)
    player:set_mouse_select(false)

    local p = {}
    Player[player] = p

    p.is_attacking = false
    p.is_defending = false
    p.animation = 'idle'

    p.lmb_pressed = false
    p.rmb_pressed = false
    p.space_pressed = false

    p.unit = unit
    
    local attack_time = 0
    local attack_count = 0
    local state = 'idle'
    local facing = 270

    local anticipation_start = GameAPI.get_unit_key_float_kv(unit:get_key(), 'anticipation_start'):float()
    local anticipation_end = GameAPI.get_unit_key_float_kv(unit:get_key(), 'anticipation_end'):float()

    p.timer = up.loop(tickrate, function ()
        local unit_point = unit:get_point()
        player:set_camera(unit_point, 1)

        if attack_time > 0 then
            attack_time = attack_time - tickrate
            if attack_time <= 0 then attack_count = 0 end
        end

        if unit:is_alive() then

            if p.lmb_pressed and state ~= 'dash' then
                if state ~= 'attack' then
                    local point = player:get_mouse_pos()
                    if state == 'defend' then p.unit:add('move_speed', defend_slow, 'AllRatio') end
                    state = 'attack'

                    local attack_speed = unit:get('attack_speed') / 100
                    local start = anticipation_start / attack_speed
                    local fin = anticipation_end / attack_speed

                    facing = unit:get_point() / point
                    unit:add_animation({ name = 'attack1', loop = false, speed = attack_speed })
                    p.unit:add('move_speed', -attack_slow, 'AllRatio')

                    up.wait(start, function()
                        attack_count = attack_count + 1
                        if attack_count > 3 then attack_count = 1 end
                        attack_time = time_to_reset_attack
                        create_projectile(player, attack_count, facing)

                        up.wait(fin, function ()
                            p.unit:add('move_speed', attack_slow, 'AllRatio')

                            state = 'idle'
                        end)
                    end)
                end
            end
                
            local dest_point, moved = get_dest_point(player)
            
            if p.space_pressed then
                p.space_pressed = false
                if state ~= 'dash' and state ~= 'attack' then
                    state = 'dash'

                    local point = player:get_mouse_pos()
                    -- local direction = unit:get_point() / point
                    local direction = unit:get_facing()
                    local end_dash = function()
                        state = 'idle'
                        unit:stop_animation()
                    end
                    dash(player, direction, end_dash)
                    unit:add_animation({ name = 'walk', loop = true, speed = 2, })
                end
            end
            if state ~= 'dash' then
                if p.rmb_pressed and (state == 'idle' or state == 'walk') then
                    if state ~= 'defend' then
                        state = 'defend'
                        p.unit:add('move_speed', -defend_slow, 'AllRatio')
                        unit:add_animation({ name = 'defend', init_time = 0, end_time = 0.15, loop = false, speed = 0.5, return_idle = false })

                        up.wait(0.3, function()
                            if state == 'defend' then
                                unit:add_animation({ name = 'defend', init_time = 0.15, end_time = 0.60, loop = true, speed = 0.25, return_idle = false })
                            end
                        end)
                    end

                    facing = unit:get_point() / player:get_mouse_pos()
                end

                if not p.rmb_pressed and state == 'defend' then
                    state = 'idle'
                    p.unit:add('move_speed', defend_slow, 'AllRatio')
                    unit:stop_animation()
                end
                
                if not unit:can_collide_with_point(dest_point, 25) then
                    if moved then
                        if state == 'idle' then
                            state = 'walk'
                            unit:add_animation({ name = 'walk', loop = true, speed = 1, })
                        end

                        if state == 'walk' then
                            facing = unit:get_point() / dest_point
                        end
                    end
                    
                    unit:set_point(dest_point, true)
                else
                    facing = unit:get_point() / player:get_mouse_pos()
                    if state == 'walk' then
                        state = 'idle'
                        unit:stop_animation()
                    end
                end

                unit:set_facing(facing)
            end
        end
    end)
end