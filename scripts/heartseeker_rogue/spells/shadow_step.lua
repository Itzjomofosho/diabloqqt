local my_utility = require("my_utility/my_utility")

local menu_elements_shadow_step_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_step_base_bool_main")),
}

local function menu()
    
    if menu_elements_shadow_step_base.tree_tab:push("Shadow Step")then
        menu_elements_shadow_step_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_shadow_step_base.tree_tab:pop()
    end
end

local spell_id_shadow_step = 355606;

local spell_data_dash = spell_data:new(
    0.2,                        -- radius
    5.0,                        -- range
    0.8,                        -- cast_delay
    1.5,                        -- projectile_speed
    true,                       -- has_collision
    spell_id_shadow_step,               -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.targeted    --targeting_type
)
local next_time_allowed_cast = 5.0;
local function logics(target)
    
    local menu_boolean = menu_elements_shadow_step_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_step);

    if not is_logic_allowed then
        return false;
    end;

    local target_position = target:get_position();
    if evade.is_dangerous_position(target_position) then
        return false;
    end

    if cast_spell.target(target, spell_data_dash, false) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        console.print("Rouge, Casted Shadow Step");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}