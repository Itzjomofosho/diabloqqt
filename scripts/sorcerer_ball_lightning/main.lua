local local_player = get_local_player();
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_sorc = character_id == 0;
if not is_sorc then
 return
end;

local menu = require("menu");

local spells =
{
    teleport                = require("spells/teleport"),
    flame_shield            = require("spells/flame_shield"),           
    ice_blade               = require("spells/ice_blade"),               
    spear                   = require("spells/spear"),                     
    ball                    = require("spells/ball"),                  
    unstable_current        = require("spells/unstable_current"),     
}

on_render_menu (function ()

    if not menu.main_tree:push("Sorcerer: Ball Lightning") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.teleport.menu();
    spells.ice_blade.menu();
    spells.ball.menu();
    spells.spear.menu();
    spells.flame_shield.menu();
    spells.unstable_current.menu();
    menu.main_tree:pop();
    
end)

local my_target_selector = require("my_utility/my_target_selector");

local cast_end_time = 0.0;
on_update(function ()

    local_player = get_local_player();
    if local_player == nil then
        return
    end

    if menu.main_boolean:get() == false then
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    local orbwalker_mode = orbwalker.get_orb_mode()
    if orbwalker_mode == 0 then
        return;
    end;

    local screen_range = 16.0;
    local player_position = local_player:get_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local max_range = 12.0;
    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local distance_sqr = best_target_position:squared_dist_to_ignore_z(player_position);

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end

    -- spells logics begins:

    if spells.unstable_current.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.flame_shield.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.teleport.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.ice_blade.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.spear.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.ball.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

end);

console.print("Lua Plugin - Sorcerer Ball Lightning - Version 1.3");