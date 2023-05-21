function init_ui(player, unit)
    local main_panel = GameAPI.get_comp_by_absolute_path(player._base, 'GameHUD.main_panel')
    for i = 1, 4 do
        local skill = unit:find_skill('Hero', nil, i)
        local btn = GameAPI.get_comp_by_path(player._base, main_panel, 'skill_list.skill_btn_' .. i .. '.skill_btn')
        if skill then
            GameAPI.set_skill_on_ui_comp(player._base, skill._base, btn)
            GameAPI.set_ui_comp_visible(player._base, true, btn)
            
            local icon = GameAPI.get_comp_by_path(player._base, btn, 'icon')
            GameAPI.create_ui_comp_event_ex_ex(icon, 24, 'show_skill_tip')
            GameAPI.create_ui_comp_event_ex_ex(icon, 25, 'hide_tip')
        else
            GameAPI.unbind_ui_comp(player._base, btn)
            GameAPI.set_ui_comp_visible(player._base, false, btn)
        end
    end

    local hp_bar = GameAPI.get_comp_by_path(player._base, main_panel, 'hp_bar')
    GameAPI.set_ui_comp_bind_attr(player._base, hp_bar, 'current_value_bind', 'hp_cur', 2)
    GameAPI.set_ui_comp_bind_attr(player._base, hp_bar, 'max_value_bind', 'hp_max', 2)
    GameAPI.ui_comp_bind_unit(player._base, hp_bar, unit._base)
    
    local mp_bar = GameAPI.get_comp_by_path(player._base, main_panel, 'mp_bar')
    GameAPI.set_ui_comp_bind_attr(player._base, mp_bar, 'current_value_bind', 'mp_cur', 2)
    GameAPI.set_ui_comp_bind_attr(player._base, mp_bar, 'max_value_bind', 'mp_max', 2)
    GameAPI.ui_comp_bind_unit(player._base, mp_bar, unit._base)
    
    local hp_text = GameAPI.get_comp_by_path(player._base, hp_bar, 'hp_value')
    local mp_text = GameAPI.get_comp_by_path(player._base, mp_bar, 'mp_value')
    up.loop(1/30, function ()
        local hp = tostring(math.floor(unit:get('hp_cur'))) .. '/' .. tostring(math.floor(unit:get('hp_max')))
        local mp = tostring(math.floor(unit:get('mp_cur'))) .. '/' .. tostring(math.floor(unit:get('mp_max')))
        GameAPI.set_ui_comp_text(player._base, hp_text, hp)
        GameAPI.set_ui_comp_text(player._base, mp_text, mp)
    end)
end