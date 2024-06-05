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
    teleport      = require("spells/teleport_ism"),
    flame_shield  = require("spells/flame_shield_ism"),           
    ice_shards    = require("spells/ice_shards_ism"),               
    ice_cube      = require("spells/ice_cube"),                     
    frost_nova    = require("spells/frost_nova"),                  
    frost_shield  = require("spells/frost_shield"),     
}

on_render_menu (function ()
    if not menu.main_tree:push("Sorcerer: Ice Shards") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.ice_shards:menu()
    spells.teleport:menu()
    spells.frost_nova:menu()
    spells.flame_shield:menu()
    spells.frost_shield:menu()
    spells.ice_cube:menu()
    
end)

local target_selector_local = require("utility/target_selector");
local local_utility = require("utility/local_utility");
local cast_end_time = 0.0;
local spell_id_nova = 291215
local last_tp_cast_time = 0.0
local forcing_nova = false
on_update(function ()

    
    -- local buffs = get_local_player():get_buffs()
    -- for i, unit in ipairs(buffs) do
    --     console.print(unit:name())
    -- end

    if menu.main_boolean:get() == false then
        return;
    end;

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    -- orbwalker filter, for now any orbwalker mode
    local orbwalker_mode = orbwalker.get_orb_mode()
    if orbwalker_mode == 0 then
        return;
    end;

    local player_position = local_player:get_position();

   if spells.teleport.menu_elements.cast_nova_after_always:get() == true then
        if forcing_nova or local_utility.force_nova_cast then
            -- avoid wasting nova if no enemies around or tp cast was too long ago
            if current_time - last_tp_cast_time < 2.0 and utility.get_amount_of_units_inside_circle(player_position, 4.0) > 1 then
                if cast_spell.self(spell_id_nova, 0.15) then
                    forcing_nova = false
                end
            else
                forcing_nova = false
            end        
        end
    end

    local screen_range = 16.0;


    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = target_selector.get_near_target_list(player_position, screen_range);

    local target_selector_data = target_selector_local.get_target_selector_data(
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
    if spells.ice_shards.logics(best_target) then
        return;
    end; 

    if spells.teleport.logics(entity_list, target_selector_data, best_target) then
        forcing_nova = true
        last_tp_cast_time = current_time
        return;
    end;

    if spells.frost_nova.logics() then
        return;
    end; 

    if spells.flame_shield.logics() then
        return;
    end;

    if spells.frost_shield.logics() then
        return;
    end;

    if spells.ice_cube.logics() then
        cast_end_time = current_time + 4.0;
        return;
    end;


end)
