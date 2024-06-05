local my_utility = require("my_utility/my_utility");

local menu_elements_spear = 
{
    tree_tab_bone               = tree_node:new(1),
    main_boolean_bone           = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_bone_spear")),
    allow_elite_single_target   = checkbox:new(true, get_hash(my_utility.plugin_label .. "allow_elite_single_target")),
    min_hits_slider             = slider_int:new(0, 30, 1, get_hash(my_utility.plugin_label .. "min_max_number_of_targets_for_cast_spear")),
}

local function menu()
    
    if menu_elements_spear.tree_tab_bone:push("Bone Spear") then
        menu_elements_spear.main_boolean_bone:render("Enable Spell", "")

        if menu_elements_spear.main_boolean_bone:get() then
            menu_elements_spear.allow_elite_single_target:render("Prio Bosses/Elites", "")
            menu_elements_spear.min_hits_slider:render("Min Hit Enemies", "")

        end
       menu_elements_spear.tree_tab_bone:pop()
    end 
end

local spell_id_bone_spear = 432879
local next_time_allowed_cast = 0.0;
local bone_spear_spell_data = spell_data:new(
    0.5,                        -- radius
    10.0,                       -- range
    1.7,                        -- cast_delay
    4.0,                        -- projectile_speed
    false,                      -- has_collision
    spell_id_bone_spear,        -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)
local local_player = get_local_player();
if local_player == nil then
    return
end

local function logics(target)
    
    local menu_boolean = menu_elements_spear.main_boolean_bone:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_bone_spear);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local player_pos = get_player_position();
    local current_resource = local_player:get_primary_resource_current();
    local max_resource = local_player:get_primary_resource_max();
    local resource_percentage = current_resource / max_resource; 
    local is_low_resources = resource_percentage < 0.2;

    if is_low_resources then

        local corpses_data = corpse_explosion_.get_corpse_explosion_data_default();
        if corpses_data.is_valid then
            return false;
        end
    end

    local rectangle_radius = 1;
    local destination_spear = 10
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_pos, destination_spear, 0.3)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, 1, 1, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list
    
    local is_single_target_allowed = false;
    if menu_elements_spear.allow_elite_single_target:get() then
        for _, unit in ipairs(best_hit_list) do
            local current_health_percentage = unit:get_current_health() / unit:get_max_health() * 100

      
            if unit:is_boss() and current_health_percentage > 2 then
                is_single_target_allowed = true
                break 
            end
        
       
            if unit:is_elite() and current_health_percentage > 2 then
                is_single_target_allowed = true
                break 
            end
        end
    end

    local best_cast_hits = best_cast_data.hits;
    if best_cast_hits < menu_elements_spear.min_hits_slider:get() and not is_single_target_allowed then
        return false
    end

    local best_cast_position = best_cast_data.point;
    local target_position = target:get_position();
    if cast_spell.position(spell_id_bone_spear, best_cast_position, 0.60) then
        console.print("Necromancer Plugin, Casted Spear, Target " .. best_target:get_skin_name() .. " Hits: " .. best_cast_hits);
        return true;
    end
    
    return false;
end

return
{
    menu = menu,
    logics = logics,
}