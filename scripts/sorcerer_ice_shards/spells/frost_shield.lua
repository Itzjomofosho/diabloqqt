local local_utility = require("utility/local_utility");

local menu_elements = 
{
    tree_tab              = tree_node.new(1),
    main_boolean          = checkbox.new(true, get_hash(local_utility.plugin_label .. "main_boolean_frost_shield")),
    min_health_pct = slider_float:new(0.0, 1.0, 1.0, get_hash(local_utility.plugin_label .. "min_hp_pct_frost_shield")),
    cast_frost_shield_opts = combo_box:new(2, get_hash(local_utility.plugin_label .. "cast_frost_shield_opts"))
}

local function menu()  
    if menu_elements.tree_tab:push("Frost Shield") then
        menu_elements.main_boolean:render("Enable Spell", "")
        if menu_elements.main_boolean:get() then
            local health_pct_current_value = menu_elements.min_health_pct:get()
            -- show the current value in the tooltip, easier to read for the user than "X" for example
            menu_elements.min_health_pct:render("Min Health Pct", 
            "Basic health percentage check. Frost shield won't be casted unless your health percentage is below than " .. tostring(health_pct_current_value) .. ".")
            menu_elements.cast_frost_shield_opts:render("Cast Options", local_utility.combo_options, "")
        end
        menu_elements.tree_tab:pop()
    end
end

local spell_id_ball = 514030
local next_time_allowed_cast = 0.0;
local function logics()
    
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = local_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_ball);

    if not is_logic_allowed then
        return false;
    end;

    if not local_utility.is_cast_enabled_by_orbwalker_menu(menu_elements.cast_ice_shards_opts:get()) then
        return false
    end

    local units_around = utility.get_units_inside_circle_list(player_pos(), 10.0)

    -- pvp and no enemy elites - no cast
    local is_pvp = orbwalker.get_orb_mode() == orb_mode.pvp
    if is_pvp then
        if not local_utility.is_pvp_cast_allowed_aoe(units_around) then
            return false
        end
    end


    if cast_self_spell(spell_id_ball) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.4;
        
        c_print("Sorcerer Plugin, Casted Ball");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}