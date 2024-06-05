local my_utility = require("my_utility/my_utility")

local menu_elements = {
    bone_storm_submenu      = tree_node:new(1),
    bone_storm_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_storm_boolean_blight")),
    bone_storm_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "bone_storm_cast_modes_blight")),
    enable_panic_cast       = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_storm_enable_panic_cast_blight")),
    min_enemies_slider      = slider_int:new(0, 30, 10, get_hash(my_utility.plugin_label .. "bone_storm_min_enemies_slider_blight")),
    min_hp_slider           = slider_float:new(0.0, 1.0, 0.50, get_hash(my_utility.plugin_label .. "bone_storm_min_hp_slider"))
}

local function menu()
    if menu_elements.bone_storm_submenu:push("Bone Storm") then
        menu_elements.bone_storm_boolean:render("Enable Storm Cast", "")

        if menu_elements.bone_storm_boolean:get() then
            -- create the combo box elements as a table
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only"}
            menu_elements.bone_storm_mode:render("Cast Modes", dropbox_options, "")
            menu_elements.min_enemies_slider:render("Min Enclosed Enemies", "")
        end
        
        menu_elements.enable_panic_cast:render("Enable Panic Cast", "")
        if menu_elements.enable_panic_cast:get() then
            menu_elements.min_hp_slider:render("Panic Cast Min HP Percent", "", 2)
        end

        menu_elements.bone_storm_submenu:pop()
    end
end

local bone_storm_id = 499281
-- to get the spell id, go to debug -> draw spell ids

local last_bone_storm_cast_time = 0.0
local function logics()
  
    local menu_boolean = menu_elements.bone_storm_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_bone_storm_cast_time, 
                bone_storm_id,
                menu_elements.bone_storm_mode:get());

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local player_position = local_player:get_position();
    local player_hp_pct = local_player:get_current_health() / local_player:get_max_health();
    local menu_min_hp_pct = menu_elements.min_hp_slider:get();
    local is_panic_cast = menu_elements.enable_panic_cast:get() and player_hp_pct <= menu_min_hp_pct;

    local enemies_near = target_selector.get_near_target_list(player_position, 5.0);
    local enemies_far = target_selector.get_near_target_list(player_position, 10.0);
    local min_enemies = menu_elements.min_enemies_slider:get();

    local should_cast = is_panic_cast or #enemies_near >= min_enemies or #enemies_far >= min_enemies * 2.2
    
    if not should_cast then
        return false;
    end
    
    if cast_spell.self(bone_storm_id, 0.10) then
        local current_time = get_time_since_inject();
        last_bone_storm_cast_time = current_time + 0.20;
        console.print("[Necromancer] [SpellCast] [Bone Storm] Reason: " .. (is_panic_cast and "Panic" or "Multi Hits"));
        return true;
    end

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}