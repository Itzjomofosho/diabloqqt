local local_player = get_local_player();
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_sorc_lash = character_id == 0;
if not is_sorc_lash then
 return
end;

local menu = require("menu");

local spells =
{
    teleport                    = require("spells_sorc/teleport"),
    ice_armor                   = require("spells_sorc/ice_armor"),           
    flame_shield                = require("spells_sorc/flame_shield"),               
    frost_nova                  = require("spells_sorc/frost_nova"),                     
    chain_lightning             = require("spells_sorc/chain_lightning"),                  
    unstable_current            = require("spells_sorc/unstable_current"),     
    arc_lash                    = require("spells_sorc/arc_lash"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Sorcerer: Arc Lash") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
        menu.main_tree:pop();
        return;
    end;
    
    spells.teleport.menu();
    spells.ice_armor.menu();
    spells.flame_shield.menu();
    spells.frost_nova.menu();
    spells.chain_lightning.menu();
    spells.unstable_current.menu();
    spells.arc_lash.menu();
    menu.main_tree:pop();
    
end
)

local mount_buff_name = "Generic_SetCannotBeAddedToAITargetList";
local mount_buff_name_hash = mount_buff_name;
local mount_buff_name_hash_c = 1923;

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

    local is_mounted = false;
    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
        -- console.print("buff name ", buff:name());
        -- console.print("buff hash ", buff.name_hash);
        if buff.name_hash == mount_buff_name_hash_c then
            is_mounted = true;
            break;
        end
    end

    if is_mounted then
        return;
    end

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

    local orbwalker_mode = orbwalker.get_orb_mode()
    if orbwalker_mode == 0 then
        return;
    end;

    if spells.teleport.logics(entity_list, target_selector_data, best_target)then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if spells.frost_nova.logics()then
        cast_end_time = current_time + 0.4;
        return;
    end;

    if spells.unstable_current.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.chain_lightning.logics(best_target)then
        cast_end_time = current_time + 0.6;
        return;
    end;

    if spells.ice_armor.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.flame_shield.logics()then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.arc_lash.logics(best_target)then
        cast_end_time = current_time + 0.6 
        return;
    end


end);

console.print("Lua Plugin - Sorcerer Arc Lash - Version 1.3");