local local_utility = require("utility/local_utility");
local frost_nova_l   = require("spells/frost_nova")

local menu_elements = 
{
    tree_tab              = tree_node:new(1),
    main_boolean          = checkbox:new(true, get_hash(local_utility.plugin_label .. "main_boolean_teleport")),
   
    teleport_mode         = combo_box:new(0, get_hash(local_utility.plugin_label .. "teleport_mode")),
    keybind               = keybind:new(0x01, false, get_hash(local_utility.plugin_label .. "teleport_keybind")),
    keybind_ignore_hits   = checkbox:new(true, get_hash(local_utility.plugin_label .. "keybind_ignore_min_hits")),

    min_hits              = slider_int:new(1, 20, 6, get_hash(local_utility.plugin_label .. "min_hits_to_cast")),
    cast_nova_after_always = checkbox:new(true, get_hash(local_utility.plugin_label .. "cast_nova_after_tp_always")),
    
    tp_options =  {"AuTo", "Keybind"};
    cast_tp_opts = combo_box:new(2, get_hash(local_utility.plugin_label .. "tp_cast_options"))
}

local function menu()
    if menu_elements.tree_tab:push("Teleport") then
        menu_elements.main_boolean:render("Enable Spell", "");

        if menu_elements.main_boolean:get() then
            
            menu_elements.teleport_mode:render("Cast Options", menu_elements.tp_options, "");
            local is_keybind = menu_elements.teleport_mode:get() == 1
            if is_keybind then
                menu_elements.keybind:render("Keybind", "");
                menu_elements.keybind_ignore_hits:render("Keybind Ignores Min Hits", "");    
            else
               menu_elements.cast_tp_opts:render("Auto - Cast Restrictions", local_utility.combo_options, "")
            end

            menu_elements.min_hits:render("Min Hits", ""); 
            menu_elements.cast_nova_after_always:render("Force Nova Cast After TP", "")   
        end

        menu_elements.tree_tab:pop();
    end
end

local target_selector = require("utility/target_selector");

local spell_id_tp = 288106;

local spell_radius = 2.5;
local spell_max_range = 10.0;

local next_time_allowed_cast = 0.0;
local spell_id_nova = 291215
local function logics(entity_list, target_selector_data, best_target)
 
    local menu_boolean = menu_elements.main_boolean:get()
    local is_logic_allowed = local_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_tp)
                

    if not is_logic_allowed then
        return false
    end

    if not utility.can_cast_spell(spell_id_nova) then
        return false;
    end;

    local keybind_used = menu_elements.keybind:get_state()
    local teleport_mode = menu_elements.teleport_mode:get()
    local is_keybind_mode = teleport_mode == 1

    if is_keybind_mode then
        if keybind_used == 0 then   
            return false;
        end
    else
        -- keybind is keybind - dont restrict any cast if user is explicitly asking to cast
        if not local_utility.is_cast_enabled_by_orbwalker_menu(menu_elements.cast_tp_opts:get()) then
            return false
        end
    end

    local keybind_ignore_hits = menu_elements.keybind_ignore_hits:get();

    ---@type boolean
        local keybind_can_skip = keybind_ignore_hits == true and keybind_used > 0;
    -- console.print("keybind_can_skip " .. tostring(keybind_can_skip))
    -- console.print("keybind_used " .. keybind_used)
    
    local player_position = get_player_position();
    local min_hits_menu = menu_elements.min_hits:get();

    local area_data = target_selector.get_most_hits_circular(player_position, spell_max_range, spell_radius);

    if not is_area_valid and not keybind_can_skip  then
        return false;
    end

    if not area_data.main_target then
        return false
    end

    if not area_data.main_target:is_enemy() then
        return false;
    end

    local n_hits = menu_elements.min_hits:get()
    if local_utility.is_auto_play_enabled() then
        n_hits = 10
    end

    if area_data.hits_amount < n_hits then
        return false
    end

    -- todo in future avg weight vec3 (?)
    local cast_position = area_data.main_target:get_position();

    -- evade check - prevent teleporting into an enemy aoe
    if evade.is_dangerous_position(cast_position) then
        return false
    end

    if cast_spell.position(spell_id_tp, cast_position, 0.15) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 2.0;
        local_utility.force_nova_cast = true
        console.print("Sorcerer Plugin, Casted Tp");
        return true
    end
        
    
    return true;

end

return 
{
    menu = menu,
    menu_elements = menu_elements,
    logics = logics,   
}