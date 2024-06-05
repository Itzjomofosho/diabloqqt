local my_utility = require("my_utility/my_utility")

local menu_elements_dash_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "dash_base_main_bool")),
    allow_elite_single_target   = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target_base_dash")),
    min_hits_slider             = slider_int:new(0, 30, 4, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_dash_base")),
    spell_range   = slider_float:new(1.0, 15.0, 2.80, get_hash(my_utility.plugin_label .. "dash_base_spell_range")),
}

local function menu()
    
    if menu_elements_dash_base.tree_tab:push("Dash")then
        menu_elements_dash_base.main_boolean:render("Enable Spell", "")

        if  menu_elements_dash_base.main_boolean:get() then
            menu_elements_dash_base.allow_elite_single_target:render("Prio Bosses/Elites", "")
            menu_elements_dash_base.min_hits_slider:render("Min Hit Enemies", "")

            menu_elements_dash_base.spell_range:render("Spell Range", "", 1)
        end
 
        menu_elements_dash_base.tree_tab:pop()
    end
end

local spell_id_dash = 358761;

local next_time_allowed_cast = 0.0;
local function get_spell_charges(local_player, spell_id_dash)
    if not local_player then 
        return false 
    end

    local charges = local_player:get_spell_charges(spell_id_dash)
    if not charges then
        return false;
    end
    
    if charges <= 0 then
        return false;
    end
    
    return true;
end;

local function logics(target)
    
    local menu_boolean = menu_elements_dash_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_dash);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local is_spell_ready_charges = get_spell_charges(local_player, spell_id_dash)
    if not is_spell_ready_charges then
        -- if not local_player:is_spell_ready(spell_id_dash) then
            return false;
        -- end
    end

    local spell_range = menu_elements_dash_base.spell_range:get()
    local target_position = target:get_position()
    local player_position = get_player_position()
    local distance_sqr = player_position:squared_dist_to_ignore_z(target_position)
    if distance_sqr > (spell_range * spell_range) then
        return false
    end

    local rectangle_radius = 2.00;
    local destination_dash = 6.50;
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_position, destination_dash, rectangle_radius)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, destination_dash, rectangle_radius * 2, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list
    
    local is_single_target_allowed = false;
    if menu_elements_dash_base.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            local current_health_percentage = unit:get_current_health() / unit:get_max_health()

            if unit:is_boss() and current_health_percentage > 0.15 then
                is_single_target_allowed = true
                break 
            end
       
            if unit:is_elite() and current_health_percentage > 0.35 then
                is_single_target_allowed = true
                break 
            end
        end
    end

    local best_cast_hits = best_cast_data.hits;
    -- console.print("best_cast_hits " .. best_cast_hits)
    if best_cast_hits < menu_elements_dash_base.min_hits_slider:get() and not is_single_target_allowed then
        return false
    end

    local best_cast_position = best_cast_data.point;

    local option_1 = player_position:get_extended(best_cast_position, 7.0)
    if evade.is_dangerous_position(option_1) then
        
        local option_2 = best_cast_position
        if evade.is_dangerous_position(option_2) then
            return false;
        end
        if cast_spell.position(spell_id_dash, option_2, 0.5) then
            local current_time = get_time_since_inject();
            next_time_allowed_cast = current_time + 0.2;
            -- next_time_allowed_cast = current_time + 7.0;
            console.print("Rouge, Casted Dash");
            return true;
        end;

    end
    
    if cast_spell.position(spell_id_dash, option_1, 0.5) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;
        -- next_time_allowed_cast = current_time + 7.0;
        console.print("Rouge, Casted Dash");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}