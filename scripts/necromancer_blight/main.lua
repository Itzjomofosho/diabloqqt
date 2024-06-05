local player = get_local_player()
if not player then
  return;
end;

local character_id = player:get_character_class_id();
local is_load = character_id == 6; -- necro = id 6
if not is_load then
  return;
end

local menu = require("menu");
local spells = 
{
    decrepify           = require("spells/decrepify"),
    blight              = require("spells/blight"),
    corpse_explosion    = require("spells/corpse_explosion"),
    bone_prision        = require("spells/bone_prision"),
    bone_storm          = require("spells/bone_storm"),
    blood_mist          = require("spells/blood_mist"),
}

on_render_menu(function ()
    
    if not menu.main_tree:push("Necromancer: Blight") then
      return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
      -- plugin not enabled, stop rendering menu elements
      menu.main_tree:pop();
      return;
   end;
    
    spells.decrepify.menu();
    spells.blight.menu();
    spells.corpse_explosion.menu();
    spells.bone_prision.menu();
    spells.bone_storm.menu();
    spells.blood_mist.menu();
    menu.main_tree:pop();
end);

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

-- needs target c++ export
-- bone prision moving to me packed

local can_move = 0.0;
local last_spell_cast_time = 0.0;

-- local glow_target = player;

on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end
    
    if menu.main_boolean:get() == false then
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < last_spell_cast_time then
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

    -- will be used in render
    -- glow_target = best_target;

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
   
    if spells.blood_mist.logics() then
        last_spell_cast_time = current_time + 1.00;
        return;
    end;

    if spells.decrepify.logics() then
        last_spell_cast_time = current_time + 0.30;
        return;
    end;

    if spells.corpse_explosion.logics() then
        last_spell_cast_time = current_time + 0.40;
        return;
    end;

    if spells.blight.logics() then
        last_spell_cast_time = current_time + 0.40;
        return;
    end;    

    if spells.bone_prision.logics() then
        last_spell_cast_time = current_time + 0.30;
        return;
    end;

    if spells.bone_storm.logics() then
        last_spell_cast_time = current_time + 0.20;
        return;
    end;    

    local is_blood_mist = false;
    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
          -- console.print("buff name ", buff:name());
          -- console.print("buff hash ", buff.name_hash);
          if buff.name_hash == blood_mist_buff_name_hash_c then
              is_blood_mist = true;
              break;
          end
    end

    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;

    -- auto play engage far away monsters
    local is_auto_play_active = auto_play.is_active();
    local auto_play_objective = auto_play.get_objective();
    local is_auto_play_fighting = auto_play_objective == objective.fight;
    if is_auto_play_active and is_auto_play_fighting then
        local player_position = local_player:get_position();
        local is_dangerous_evade_position = evade.is_dangerous_position(player_position);
        if not is_dangerous_evade_position then
            local closer_target = target_selector.get_target_closer(player_position, 15.0);
            if closer_target then
                if is_blood_mist then
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, -5.0);
                    if pathfinder.move_to_cpathfinder(move_pos, true) then
                        last_spell_cast_time = current_time + 1.0;
                        can_move = move_timer + 1.50;
                        console.print("auto play move_to_cpathfinder - 111")
                    end
                else
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, 4.0);
                    if pathfinder.move_to_cpathfinder(move_pos, true) then
                        -- last_spell_cast_time = current_time + 1.0;
                        can_move = move_timer + 1.50;
                        console.print("auto play move_to_cpathfinder - 222")
                    end
                end
                
            end
        end
    end
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

    -- if glow_target and glow_target:is_enemy()  then
    --     local glow_target_position = glow_target:get_position();
    --     local glow_target_position_2d = graphics.w2s(glow_target_position);
    --     graphics.line(glow_target_position_2d, player_screen_position, color_red(150), 2)
    -- end

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

console.print("Lua Plugin - Necromancer Blight - Version 1.4");