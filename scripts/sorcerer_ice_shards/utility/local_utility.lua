local function is_spell_allowed(menu_boolean, next_cast_allowed_time, spell_id)

    if not menu_boolean then
        return false;
    end;

    local current_time = get_time_since_inject();
    if current_time < next_cast_allowed_time then
        return false;
    end;

    if not utility.can_cast_spell(spell_id) then
        return false;
    end;
    
    return true;
end

local function is_spell_allowed_no_mana_check(menu_boolean, next_cast_allowed_time, spell_id)

    if not menu_boolean then
        return false;
    end;

    local current_time = get_time_since_inject();
    if current_time < next_cast_allowed_time then
        return false;
    end;

    if not utility.is_spell_ready(spell_id) then
        return false;
    end;
    
    return true;
end


local cast_restrictions_dropdown_options = {
    pvp_only = 0,
    pve_only = 1,
    pve_and_pvp = 2,
    automatic = 3
}

local function is_auto_play_enabled()
    -- auto play fire spells without orbwalker
    local is_auto_play_active = auto_play.is_active();
    local auto_play_objective = auto_play.get_objective();
    local is_auto_play_fighting = auto_play_objective == objective.fight;
    if is_auto_play_active and is_auto_play_fighting then
        return true;
    end

    return false;
end

local function is_cast_enabled_by_orbwalker_menu(dropdown_state)

    if is_auto_play_enabled() then
        return true
    end
    
    local orbwalker_mode = orbwalker.get_orb_mode()
    local is_pvp = orbwalker_mode == orb_mode.pvp
    local is_pve = orbwalker_mode == orb_mode.clear

    local is_using_only_for_pvp = dropdown_state == cast_restrictions_dropdown_options.pvp_only
    local is_using_only_for_pve = dropdown_state == cast_restrictions_dropdown_options.pve_only
    local is_using_for_pve_and_pvp = dropdown_state == cast_restrictions_dropdown_options.pve_and_pvp

    if is_pvp_only and not is_pvp then
        return false
    end

    if is_pvp_only and not is_pve then
        return false
    end

    if is_pvp_or_pve then
        if not is_pvp and not is_pve then
            return false
        end
    end

    return true
end

-- we only cast in pvp if someone from targets is elite 
local function is_pvp_cast_allowed_aoe(target_list)
    for i, unit in ipairs(target_list) do
        if unit:is_elite() then
            return true;
        end
    end

    return false
end

combo_options = {"PvP Only", "PvE Only", "PvE or PvP" }
local plugin_label = "CDEV_ICE_SHARDS_MAGE_"
local force_nova_cast = false

return
{
    plugin_label = plugin_label,
    is_spell_allowed = is_spell_allowed,
    combo_options = combo_options,
    is_pvp_cast_allowed_aoe = is_pvp_cast_allowed_aoe,
    is_cast_enabled_by_orbwalker_menu = is_cast_enabled_by_orbwalker_menu,
    force_nova_cast = force_nova_cast,
    is_auto_play_enabled = is_auto_play_enabled,
    is_spell_allowed_no_mana_check = is_spell_allowed_no_mana_check
}