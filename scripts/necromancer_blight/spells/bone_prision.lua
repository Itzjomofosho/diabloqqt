local my_utility = require("my_utility/my_utility")

local menu_elements = {
    bone_prision_submenu      = tree_node:new(1),
    bone_prision_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_prision_boolean_base_blight")),
    
    bone_prision_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "bone_prision_mode_base_blight")),
    
    bone_prision_logic        = combo_box:new(0, get_hash(my_utility.plugin_label .. "bone_prision_logic_base_blight")),
    keybind                   = keybind:new(0x01, false, get_hash(my_utility.plugin_label .. "bone_prision_keybind_base_blight")),
    keybind_ignore_hits       = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_prision_keybind_ignore_min_hits_base_blight")),
   
    min_hits                  = slider_int:new(1, 20, 8, get_hash(my_utility.plugin_label .. "bone_prision_min_hits_to_cast_base_blight")),
    
    allow_percentage_hits     = checkbox:new(true, get_hash(my_utility.plugin_label .. "bone_prision_allow_percentage_hits_base_blight")),
    min_percentage_hits       = slider_float:new(0.1, 1.0, 0.70, get_hash(my_utility.plugin_label .. "bone_prision_min_percentage_hits_base_blight")),
    soft_score                = slider_float:new(3.0, 15.0, 6.0, get_hash(my_utility.plugin_label .. "bone_prision_soft_score_base_blight")),
}

local function menu()
    if menu_elements.bone_prision_submenu:push("Bone Prision") then
        menu_elements.bone_prision_boolean:render("Enable Prision Cast", "")

        if menu_elements.bone_prision_boolean:get() then
            -- create the combo box elements as a table
            
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only"}
            menu_elements.bone_prision_mode:render("Mode", dropbox_options, "");

            local logic_options =  {"Auto", "Keybind"};
            menu_elements.bone_prision_logic:render("Logic", logic_options, "");

            menu_elements.keybind:render("Keybind", "");
            menu_elements.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");

            menu_elements.min_hits:render("Min Hits", "");

            menu_elements.allow_percentage_hits:render("Allow Percentage Hits", "");
            if menu_elements.allow_percentage_hits:get() then
                menu_elements.min_percentage_hits:render("Min Percentage Hits", "", 1);
                menu_elements.soft_score:render("Soft Score", "", 1);
            end       
        end

        menu_elements.bone_prision_submenu:pop()
    end
end

local my_target_selector = require("my_utility/my_target_selector");

local bone_prision_spell_id = 493453
-- to get the spell id, go to debug -> draw spell ids

local last_bone_prison_cast_time = 0.0;
local function logics()

    local menu_boolean = menu_elements.bone_prision_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_bone_prison_cast_time, 
                bone_prision_spell_id,
                menu_elements.bone_prision_mode:get());

    
    if not is_logic_allowed then
        return false;
    end;

    local keybind_used = menu_elements.keybind:get_state() == 1;
    local bone_prision_logic = menu_elements.bone_prision_logic:get();
    
    -- console.print("Is Keybind Down:", keybind_used)
    -- console.print("Bone Prision Mode: ", bone_prision_logic)
    if bone_prision_logic == 1 then
        if  keybind_used == 0 then   
            return false;
        end;
    end;

	local spell_range = 8.0
	local spell_radius = 2.90
	local area_data = my_target_selector.get_most_hits_circular(player_position, spell_range, spell_radius)
    local best_target = area_data.main_target;
    
    if not best_target then
        return;
    end

    local best_target_position = best_target:get_position();
    local best_cast_data = my_utility.get_best_point(best_target_position, circle_radius, area_data.victim_list);

    local best_cast_hits = best_cast_data.hits;
    local best_cast_position = best_cast_data.point;

    local keybind_ignore_hits = menu_elements.keybind_ignore_hits:get();
 
     ---@type boolean
        local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)

    local is_percentage_hits_allowed = menu_elements.allow_percentage_hits:get();
    local min_percentage = menu_elements.min_percentage_hits:get();
    if not is_percentage_hits_allowed then
        min_percentage = 0.0;
    end

    local min_hits_menu = menu_elements.min_hits:get();
    -- console.print("min_hits_menu ", min_hits_menu);
    
    local screen_range = 16.0;

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local is_area_valid = my_target_selector.is_valid_area_spell_aio(area_data, min_hits_menu, entity_list, min_percentage);
    
    if not is_area_valid and not keybind_can_skip  then
        return false;
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    local constains_boss = false;
    local constains_elite = false;
    local constains_champion = false;
    for _, victim in ipairs(area_data.victim_list) do
        if victim:is_boss() then
            constains_boss = true;
            break;
        end
        if victim:is_elite()  then
            constains_elite = true;
        else
            if victim:is_champion() then
                constains_champion = true;
            end
        end       
    end

    local constains_relevant = constains_boss or constains_elite or constains_champion;
    if not constains_relevant and area_data.score < menu_elements.soft_score:get() and not keybind_can_skip  then
        return false;
    end

    local value = 5;
    if constains_boss then
        value = 1;
    else
        if constains_elite then
            value = 2;
        else
            if constains_champion then
                value = 3;
            end
        end
    end
    
    if area_data.n_hits < value and not keybind_can_skip  then
        return false;
    end    

    if cast_spell.position(bone_prision_spell_id, best_cast_position, 0.40) then
        
        local current_time = get_time_since_inject();
        last_bone_prison_cast_time = current_time + 0.50;
        console.print("[Necromancer] [SpellCast] [Bone Prision] Target: " .. best_target:get_skin_name() .. " Hits: " .. best_cast_hits);
        
        return true;
    end
   
    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}