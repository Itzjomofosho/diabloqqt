local my_utility = require("my_utility/my_utility");

local menu_elements_heartseeker_base = 
{
    tree_tab_bone                       = tree_node:new(1),
    main_boolean_bone                   = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_heartseeker_base")),
}

local function menu()
    
    if menu_elements_heartseeker_base.tree_tab_bone:push("Heartseeker") then
        menu_elements_heartseeker_base.main_boolean_bone:render("Enable Spell", "")
        menu_elements_heartseeker_base.tree_tab_bone:pop()
    end 
end

local spell_id_heartseeker = 363402
local next_time_allowed_cast = 0.0;
local heartseeker_spell_data = spell_data:new(
    0.5,                        -- radius
    30.0,                       -- range
    0.01,                        -- cast_delay
    4.0,                        -- projectile_speed
    true,                      -- has_collision
    spell_id_heartseeker,        -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
)

local function logics(target)
    
    local menu_boolean = menu_elements_heartseeker_base.main_boolean_bone:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_heartseeker);

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local player_pos = get_player_position();
    local current_resource = local_player:get_primary_resource_current();
    local max_resource = local_player:get_primary_resource_max();
    local resource_percentage = current_resource / max_resource; 
    local is_low_resources = resource_percentage < 0.2;

    local rectangle_width = 2.0;
    local rectangle_lenght = 10
    local area_data = target_selector.get_most_hits_target_rectangle_area_heavy(player_pos, rectangle_lenght, rectangle_width)
    local best_target = area_data.main_target;

    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point_rec(best_target_position, 1, 1, area_data.victim_list);

    local best_hit_list = best_cast_data.victim_list

    local best_cast_hits = best_cast_data.hits;

    local best_cast_position = best_cast_data.point;
    local target_position = target:get_position();
    if cast_spell.position(spell_id_heartseeker, best_cast_position, 0.60) then
        console.print("Casted Heartseeker, Target " .. best_target:get_skin_name() .. " Hits: " .. best_cast_hits);
        return true;
    end
    
    return false;
end

return
{
    menu = menu,
    logics = logics,
}