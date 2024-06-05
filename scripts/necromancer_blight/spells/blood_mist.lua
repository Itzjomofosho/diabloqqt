local my_utility = require("my_utility/my_utility")

local menu_elements = {
    blood_mist_submenu      = tree_node:new(1),
    blood_mist_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "blood_mist_boolean_blight")),
    blood_mist_mode         = combo_box:new(3, get_hash(my_utility.plugin_label .. "blood_mist_cast_modes_blight_2")),

    blood_mist_on_low_hp    = checkbox:new(true, get_hash(my_utility.plugin_label .. "blood_mist_on_low_hp_blight")),
    min_hp_slider           = slider_float:new(0.0, 1.0, 0.50, get_hash(my_utility.plugin_label .. "blood_mist_min_hp_slider_blight")),

    -- blood_mist_on_fill      = checkbox:new(true, get_hash(my_utility.plugin_label .. "blood_mist_on_fill_blight")),
}

local function menu()
    if menu_elements.blood_mist_submenu:push("Blood Mist") then
        menu_elements.blood_mist_boolean:render("Enable Blood Mist Cast", "")

        if menu_elements.blood_mist_boolean:get() then
            -- Create the combo box elements as a table
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only", "Automatic"}
            menu_elements.blood_mist_mode:render("Cast Modes", dropbox_options, "")

            -- Render the blood_mist_on_low_hp checkbox
            menu_elements.blood_mist_on_low_hp:render("Cast on Low HP", "")

            -- Conditionally render the min_hp_slider if blood_mist_on_low_hp is true
            if menu_elements.blood_mist_on_low_hp:get() then
                menu_elements.min_hp_slider:render("Min Cast HP Percent", "", 2)
            end

            -- Render the blood_mist_on_fill checkbox
            -- menu_elements.blood_mist_on_fill:render("Cast on Fill", "")
        end

        menu_elements.blood_mist_submenu:pop()
    end
end

local corpse_explosion_ = require("spells/corpse_explosion");

local blood_mist_id = 493422;
-- to get the spell id, go to debug -> draw spell ids

local last_blood_mist_cast_time = 0.0;
local function logics()

    local menu_boolean = menu_elements.blood_mist_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_blood_mist_cast_time, 
                blood_mist_id,
                menu_elements.blood_mist_mode:get());

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player()
    local player_hp_pct = local_player:get_current_health() / local_player:get_max_health()
    local menu_min_hp_pct = menu_elements.min_hp_slider:get()

    local should_cast = false

    -- Check for low HP condition
    if menu_elements.blood_mist_on_low_hp:get() and player_hp_pct < menu_min_hp_pct then
        should_cast = true
    end

    -- Check for multiple enemies condition
    local blight_spell_id = 481293;
    local enemies_nearby = target_selector.get_near_target_list(local_player:get_position(), 3.0)
    if #enemies_nearby >= 3 and not utility.is_spell_affordable(blight_spell_id) then
        local corpses_data = corpse_explosion_.get_corpse_explosion_data()
        if not corpses_data.is_valid then
            should_cast = true
        end
    end

    -- Cast the spell if either condition is met
    if should_cast then
        if cast_spell.self(blood_mist_id, 0.10) then

            local current_time = get_time_since_inject();
            last_blood_mist_cast_time = current_time + 1.0;
            console.print("[Necromancer] [SpellCast] [Blood Mist]");

            return true;
        end
    end

    return false
end


return 
{
    menu = menu,
    logics = logics,   
}