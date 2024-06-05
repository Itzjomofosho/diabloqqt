local local_utility = require("utility/local_utility");

local menu_elements = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(local_utility.plugin_label .. "main_boolean_flame_shield")),
    cast_flame_shield_opts = combo_box:new(2, get_hash(local_utility.plugin_label .. "fs_cast-opts")),
    hp_usage_shield       = slider_float:new(0.0, 1.0, 0.30, get_hash(local_utility.plugin_label .. "pct_in_which_shield_will_cast"))
}

local function menu()
    
    if menu_elements.tree_tab:push("Flame Shield") then
        menu_elements.main_boolean:render("Enable Spell", "")

        if menu_elements.main_boolean:get() then
            menu_elements.hp_usage_shield:render("Min cast HP Percent", "", 2)
            menu_elements.cast_flame_shield_opts:render("Cast Options", local_utility.combo_options, "")
        end

       menu_elements.tree_tab:pop()
    end 
end

local next_time_allowed_cast = 0.0;
local spell_id_flame_shield = 167341;
local function logics()
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = local_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_flame_shield);

    if not is_logic_allowed then
        return false;
    end;

    if not local_utility.is_cast_enabled_by_orbwalker_menu(menu_elements.cast_flame_shield_opts:get()) then
        return false
    end
    
    local local_player = get_local_player();
    local player_current_health = local_player:get_current_health();
    local player_max_health = local_player:get_max_health();
    local health_percentage = player_current_health / player_max_health;
    local menu_min_percentage = menu_elements.hp_usage_shield:get();

    if health_percentage > menu_min_percentage then
        return false;
    end;

    if cast_self_spell(spell_id_flame_shield) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.2;
        
        c_print("Sorcerer Plugin, Casted Flame Shield");
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}