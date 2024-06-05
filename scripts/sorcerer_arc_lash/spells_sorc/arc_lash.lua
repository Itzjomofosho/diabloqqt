local my_utility = require("my_utility/my_utility");

local menu_elements_sorc = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(my_utility.plugin_label .. "main_boolean_arc_lash")),
    use_as_filler_only    = checkbox:new(true, get_hash(my_utility.plugin_label .. "_filler_only_"))
}

local function menu()
    
    if menu_elements_sorc.tree_tab:push("Arc Lash") then
        menu_elements_sorc.main_boolean:render("Enable Spell", "")
        menu_elements_sorc.use_as_filler_only:render("Filler Only", "")
 
        menu_elements_sorc.tree_tab:pop()
    end
end

local local_player = get_local_player();
if local_player == nil then
    return
end

local spell_id_arc_lash = 297902
local arc_lash_data = spell_data:new(
    2.0,                              -- radius
    1.0,                            -- range
    0.8,                            -- cast_delay
    1.2,                            -- projectile_speed
    true,                          -- has_collision
    spell_id_arc_lash,              -- spell_id
    spell_geometry.circular,        -- geometry_type
    targeting_type.skillshot        --targeting_type
)
local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_sorc.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast,
                spell_id_arc_lash);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local is_filler_enabled = menu_elements_sorc.use_as_filler_only:get();  
    if is_filler_enabled then
        local current_resource_ws = player_local:get_primary_resource_current();
        local max_resource_ws = player_local:get_primary_resource_max();
        local mana_perc = current_resource_ws / max_resource_ws 
        local low_in_mana = mana_perc < 0.2

        if not low_in_mana then
            return false;
        end
    end;

    if cast_spell.target(target, spell_id_arc_lash, 0.4, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.6;

        return true;
    end;
            
    return false;
end

return
{
    menu = menu,
    logics = logics,
}