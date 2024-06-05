local local_utility = require("utility/local_utility");
local menu_elements = 
{
    nova_subtree = tree_node:new(1),
    nova_logics_enable = checkbox:new(true, get_hash(local_utility.plugin_label .. "frost_nova_enable")),
    cast_frost_nova_opts = combo_box:new(2, get_hash(local_utility.plugin_label .. "cast_forstnova_options")),
    min_nova_aoe_hits = slider_int:new(1, 30, 8, get_hash(local_utility.plugin_label .. "frost_nova_min_aoe_hits")),
    remove_aoe_min_aoe_hits_on_pvp = checkbox:new(true, get_hash(local_utility.plugin_label .. "remove_aoe_min_hits_pvp")) 
}

local function menu()
    if menu_elements.nova_subtree:push("Frost Nova") then
        menu_elements.nova_logics_enable:render("Enable Spell", "")
        if menu_elements.nova_logics_enable:get() then
            menu_elements.min_nova_aoe_hits:render("Min Enemy Hits", "")
            menu_elements.remove_aoe_min_aoe_hits_on_pvp:render("Remove Min Hits For Elites",
             "The previous restriction will be removed for elites (includes enemy players), so frost nova will be casted even for one single enemy player / elite mob.")
            menu_elements.cast_frost_nova_opts:render("Cast Options", local_utility.combo_options, "")
        end
        menu_elements.nova_subtree:pop()
    end
end

local spell_id_nova = 291215
local next_time_allowed_cast = 0.0;
local function logics()

    local menu_boolean = menu_elements.nova_logics_enable:get();
    local is_logic_allowed = local_utility.is_spell_allowed_no_mana_check(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_nova);
    
    if not is_logic_allowed then
        -- console.print(1111)
        return false;
    end

    if not local_utility.is_cast_enabled_by_orbwalker_menu(menu_elements.cast_frost_nova_opts:get()) then
        -- console.print(2222)
        return false
    end

    local current_time = get_time_since_inject();

    local is_removing_aoe_restriction = false

    -- pvp == combo, all elites count for this mode
    local is_removing_aoe_restriction_on_pvp = menu_elements.remove_aoe_min_aoe_hits_on_pvp:get()
    local is_pvp = orbwalker.get_orb_mode() == orb_mode.pvp

    if is_removing_aoe_restriction_on_pvp then
        if is_pvp then
            is_removing_aoe_restriction = true
        end
    end

    local spell_radius = 4.0
    local units_that_im_going_to_hit = utility.get_units_inside_circle_list(get_player_position(), spell_radius)
    local is_there_any_enemy_elite_hit = false

    if is_pvp then
        if not local_utility.is_pvp_cast_allowed_aoe(units_that_im_going_to_hit) then
            return false
        else
            is_there_any_enemy_elite_hit = true
        end
    end

    local amount_of_units_that_im_going_to_hit = #units_that_im_going_to_hit
    local min_amount_of_units_to_hit = menu_elements.min_nova_aoe_hits:get()

    if not is_removing_aoe_restriction or not is_there_any_enemy_elite_hit then
        if amount_of_units_that_im_going_to_hit < min_amount_of_units_to_hit then
            return false
        end
    end

    if cast_spell.self(spell_id_nova, 0.15) then
        next_time_allowed_cast = current_time + 0.4;
        return true
    end

    return true;

end

return 
{
    menu = menu,
    logics = logics,   
}