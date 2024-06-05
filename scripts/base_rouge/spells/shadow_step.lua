local my_utility = require("my_utility/my_utility")

local menu_elements_shadow_step_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_step_base_bool_main")),
    spell_range         = slider_float:new(2.0, 8.0, 7.0, get_hash(my_utility.plugin_label .. "shadow_step_range")),
    min_range           = slider_float:new(0.0, 6.0, 0.0, get_hash(my_utility.plugin_label .. "shadow_step_min_range")),
    max_dist_cursor     = slider_float:new(1.0, 10.0, 10.0, get_hash(my_utility.plugin_label .. "shadow_step_max_dist_cursor")),
    trigger_range           = slider_float:new(0.0, 6.0, 0.0, get_hash(my_utility.plugin_label .. "shadow_step_trigger_range")),
}

local function menu()
    
    if menu_elements_shadow_step_base.tree_tab:push("Shadow Step")then
        menu_elements_shadow_step_base.main_boolean:render("Enable Spell", "")
        menu_elements_shadow_step_base.spell_range:render("Spell Range", "", 1)
        menu_elements_shadow_step_base.min_range:render("Min Range", "", 1)
        menu_elements_shadow_step_base.max_dist_cursor:render("Max Dist Cursor", "", 1)
        menu_elements_shadow_step_base.trigger_range:render("Trigger Range", "", 1)
 
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
local next_time_allowed_cast = 0.0;
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

    local spell_range =menu_elements_shadow_step_base.spell_range:get()
    local player_position = get_player_position();
    local target_position = target:get_position();
    local distance_sqr = target_position:squared_dist_to_ignore_z(player_position)
    if distance_sqr > (spell_range * spell_range ) then
        return false
    end

    local min_range = menu_elements_shadow_step_base.min_range:get()
    if distance_sqr < (min_range * min_range ) then
        return false
    end

    local trigger_range =  menu_elements_shadow_step_base.trigger_range:get()
    if trigger_range > 0.0 then
        if distance_sqr > (trigger_range * trigger_range ) then
            return false
        end
    end

    local is_auto_play_active = auto_play.is_active();
    local cursor_dist_qqr = target_position:squared_dist_to_ignore_z(get_cursor_position())
    local max_dist_cursor = menu_elements_shadow_step_base.max_dist_cursor:get()
    if cursor_dist_qqr < (max_dist_cursor * max_dist_cursor ) and max_dist_cursor < 10.0 and not is_auto_play_active then
        return false
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