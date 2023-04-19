local tickrate = 1/30
local attack_slow = 80
local defend_slow = 40

local Player = {}

local function try_change_defend(player, flag)
    local p = Player[player]
    if flag then
        if not p.is_attacking and p.rmb_pressed then
            p.unit:add('move_speed', -defend_slow, 'AllRatio')
            p.is_defending = true
        end
    else
        if p.is_defending then
            p.is_defending = false
            p.unit:add('move_speed', defend_slow, 'AllRatio')
        end
    end
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
    try_change_defend(player, true)
end)
up.game:event('Mouse-RightRelease', function (_, player)
    if not Player[player] then return end
    
    if Player[player].rmb_pressed then
        Player[player].rmb_pressed = false
        
        try_change_defend(player, false)
    end
end)

function set_player_movement(player, unit)
    player:set_mouse_click(false)
    player:set_mouse_select(false)
    
    player:camera_focus(unit)

    local p = {}
    Player[player] = p

    p.is_attacking = false
    p.is_defending = false
    p.animation = 'idle'

    p.lmb_pressed = false
    p.rmb_pressed = false

    p.unit = unit

    p.timer = up.loop(tickrate, function ()
        if unit:is_alive() then
            if p.lmb_pressed then
                if not p.is_attacking then
                    try_change_defend(player, false)

                    p.is_attacking = true
                    unit:set_facing_point(player:get_mouse_pos())
                    p.animation = 'idle'
                    unit:add_animation({ name = 'attack1', loop = false, speed = 0.75 })
                    p.unit:add('move_speed', -attack_slow, 'AllRatio')
        
                    up.wait(0.70, function()
                        p.is_attacking = false
                        p.unit:add('move_speed', attack_slow, 'AllRatio')

                        try_change_defend(player, true)
                    end)
                end
            end
                
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
            
            if not p.is_attacking then
                if p.is_defending or x == 0 and y == 0 then
                    unit:set_facing_point(player:get_mouse_pos())
                else
                    unit:set_facing_point(dest_point)
                end
            
                if p.is_defending then
                    if p.animation ~= 'defend' then
                        p.animation = 'defend'
                        unit:add_animation({ name = 'defend', init_time = 0, end_time = 0.15, loop = false, speed = 0.5, return_idle = false })
                        up.wait(0.3, function()
                            if p.is_defending then
                                unit:add_animation({ name = 'defend', init_time = 0.15, end_time = 0.60, loop = true, speed = 0.25, return_idle = false })
                            end
                        end)
                    end
                else
                    if (x ~= 0 or y ~= 0) then
                        if p.animation ~= 'walk' then
                            p.animation = 'walk'
                            unit:add_animation({ name = 'walk', loop = true, speed = 1, })
                        end
                    else
                        p.animation = 'idle'
                        unit:stop_animation()
                    end
                end
            end

            if not unit:can_collide_with_point(dest_point, 50) then
                unit:set_point(dest_point, true)
            else
                if not p.is_defending and not p.is_attacking then
                    p.animation = 'idle'
                    unit:stop_animation()
                end
            end
        end
    end)
end