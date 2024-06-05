local local_player = get_local_player()
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_rouge = character_id == 3;
if not is_rouge then
 return
end;

local menu = require("menu");

local spells =
{
    caltrop                 = require("spells/caltrop"),
    puncture                = require("spells/puncture"),
    heartseeker             = require("spells/heartseeker"),
    forcefull_arrow         = require("spells/forcefull_arrow"),
    blade_shift             = require("spells/blade_shift"),
    invigorating_strike     = require("spells/invigorating_strike"),
    twisting_blade          = require("spells/twisting_blade"),
    barrage                 = require("spells/barrage"),
    rapid_fire              = require("spells/rapid_fire"),
    flurry                  = require("spells/flurry"),
    penetrating_shot        = require("spells/penetrating_shot"),
    dash                    = require("spells/dash"),
    shadow_step             = require("spells/shadow_step"),
    smoke_grenade           = require("spells/smoke_grenade"),
    poison_trap             = require("spells/poison_trap"),
    dark_shroud             = require("spells/dark_shroud"),
    shadow_imbuement        = require("spells/shadow_imbuement"),
    poison_imbuement        = require("spells/poison_imbuement"),
    cold_imbuement          = require("spells/cold_imbuement"),
    shadow_clone            = require("spells/shadow_clone"),
    death_trap              = require("spells/death_trap"),
    rain_of_arrows          = require("spells/rain_of_arrows"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Heartseeker Rogue") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    spells.caltrop.menu();
    spells.puncture.menu();
    spells.heartseeker.menu();
    spells.forcefull_arrow.menu();
    spells.blade_shift.menu();
    spells.invigorating_strike.menu();
    spells.twisting_blade.menu();
    spells.barrage.menu();
    spells.rapid_fire.menu();
    spells.flurry.menu();
    spells.penetrating_shot.menu();
    spells.dash.menu();
    spells.shadow_step.menu();
    spells.smoke_grenade.menu();
    spells.poison_trap.menu();
    spells.dark_shroud.menu();
    spells.shadow_imbuement.menu();
    spells.poison_imbuement.menu();
    spells.cold_imbuement.menu();
    spells.shadow_clone.menu();
    spells.death_trap.menu();
    spells.rain_of_arrows.menu();
    menu.main_tree:pop();
    
end
)

local can_move = 0.0;
local cast_end_time = 0.0;

local my_utility = require("my_utility/my_utility");
local my_target_selector = require("my_utility/my_target_selector");

on_update(function ()

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    if menu.main_boolean:get() == false then
        -- if plugin is disabled dont do any logic
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

    local is_auto_play_active = auto_play.is_active();
    local max_range = 16.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

    local best_target = target_selector_data.closest_unit;
    local closest_target = target_selector_data.closest_unit;
    -- print best_target distance_sqr
    -- console.print("Best Target Distance: " .. best_target:get_position():squared_dist_to_ignore_z(player_position));

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
    glow_target = best_target;

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


    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.smoke_grenade.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.shadow_clone.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.death_trap.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.poison_trap.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.rain_of_arrows.logics(best_target)then
        cast_end_time = current_time + 1.5;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.shadow_imbuement.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.poison_imbuement.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.cold_imbuement.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.shadow_step.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end

    if not utility.can_cast_spell(389667) and spells.heartseeker.logics(best_target)then
        cast_end_time = current_time + 0.1;
        return;
    end;

    if closest_target:get_position():squared_dist_to_ignore_z(player_position) < 6 and spells.caltrop.logics(closest_target)then
        cast_end_time = current_time + 0.4;
        return;
    end

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 10 and spells.dash.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.dark_shroud.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.twisting_blade.logics(best_target)then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.barrage.logics(best_target)then
        cast_end_time = current_time + 0.6;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.rapid_fire.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.flurry.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.penetrating_shot.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.invigorating_strike.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.blade_shift.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.forcefull_arrow.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.heartseeker.logics(best_target)then
        cast_end_time = current_time + 0.1;
        return;
    end;

    if best_target:get_position():squared_dist_to_ignore_z(player_position) < 20 and spells.puncture.logics(best_target)then
        cast_end_time = current_time + 0.1;
        return;
    end;


    -- if best_target:get_position():squared_dist_to_ignore_z(player_position) >= 20 then
    --     if spells.smoke_grenade.logics(best_target)then
    --         cast_end_time = current_time + 0.4;
    --         return;
    --     end;
    --     if spells.heartseeker.logics(best_target)then
    --         cast_end_time = current_time;
    --         console.print("Far Range Heartseeker, Target " .. best_target:get_skin_name());
    --         return;
    --     end;
    -- end;

    -- auto play engage far away monsters
    local move_timer = get_time_since_inject()
    if move_timer < can_move then
        return;
    end;


    local is_auto_play = my_utility.is_auto_play_enabled();
    if is_auto_play then
        local player_position = local_player:get_position();
        local is_dangerous_evade_position = evade.is_dangerous_position(player_position);
        if not is_dangerous_evade_position then
            local closer_target = target_selector.get_target_closer(player_position, 15.0);
            if closer_target then
                if is_blood_mist then
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, -5.0);
                    if pathfinder.move_to_cpathfinder(move_pos, true) then
                        cast_end_time = current_time + 0.40;
                        can_move = move_timer + 1.50;
                        console.print("auto play move_to_cpathfinder - 111")
                    end
                else
                    local closer_target_position = closer_target:get_position();
                    local move_pos = closer_target_position:get_extended(player_position, 4.0);
                    if pathfinder.move_to_cpathfinder(move_pos, true) then
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


    -- glow target -- quick pasted code cba about this game

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

    local is_auto_play_active = auto_play.is_active();
    local max_range = 6.0;
    if is_auto_play_active then
        max_range = 12.0;
    end

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

    if best_target and best_target:is_enemy()  then
        local glow_target_position = best_target:get_position();
        local glow_target_position_2d = graphics.w2s(glow_target_position);
        graphics.line(glow_target_position_2d, player_screen_position, color_red(180), 2.5)
        graphics.circle_3d(glow_target_position, 0.80, color_red(200), 2.0);
    end


end);

console.print("Lua Plugin - Rouge Base - Version 1.5");