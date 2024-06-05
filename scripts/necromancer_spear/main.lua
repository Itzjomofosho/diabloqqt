local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_necro = character_id == 6;
if not is_necro then
 return
end;

local menu = require("menu");

local spells =
{
    blood_mist                  = require("spells_spear/blood_mist"),
    bone_spear                  = require("spells_spear/bone_spear"),           
    bone_splinters              = require("spells_spear/bone_splinters"),               
    corpse_explosion            = require("spells_spear/corpse_explosion"),                     
    corpse_tendrils             = require("spells_spear/corpse_tendrils"),                  
    decrepify                   = require("spells_spear/decrepify"),     
}

on_render_menu (function ()

    if not menu.main_tree:push("Necromancer: Bone Spear") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.bone_spear.menu();
    spells.bone_splinters.menu();
    spells.corpse_explosion.menu();
    spells.corpse_tendrils.menu();
    spells.decrepify.menu();
    spells.blood_mist.menu();
    menu.main_tree:pop();
    
end);

local my_utility = require("my_utility/my_utility")
local my_target_selector = require("my_utility/my_target_selector");

local cast_end_time = 0.0;
on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    if not my_utility.is_action_allowed() then
        return;
    end

    local screen_range = 16.0;
    local player_position = get_player_position();

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

    if spells.blood_mist.logics()then
        cast_end_time = current_time + 3.0;
        return;
    end;

    if spells.decrepify.logics()then
        cast_end_time = current_time + 0.50;
        return;
    end;  

    if spells.corpse_tendrils.logics()then
        cast_end_time = current_time + 0.30 
        return;
    end

    if spells.bone_spear.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.corpse_explosion.logics()then
        cast_end_time = current_time + 0.50;
        return;
    end;

    if spells.bone_splinters.logics(best_target)then
        cast_end_time = current_time + 0.5;
        return;
    end;

    
end);

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            -- if is_close then
                graphics.circle_3d(position, 1, color_white(100));

                local future_position = prediction.get_future_unit_position(obj, 0.4);
                graphics.circle_3d(future_position, 0.5, color_yellow(100));
            -- end;
        end;
    end

end);

console.print("Lua Plugin - Necromancer Bone Spear - Version 1.3");