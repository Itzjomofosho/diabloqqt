local local_utility = require("utility/local_utility");
local local_target_selector = require("utility/target_selector")


local menu_elements = 
{
    cast_ice_shards_opts = combo_box:new(2, get_hash(local_utility.plugin_label .. "is_copt")),
    ice_shards_sub_tree = tree_node:new(1),
    logics_enable = checkbox:new(true, get_hash(local_utility.plugin_label .. "ice_shards_enable")),
    -- possible extra logics to add here:
    -- prevent aoe logic for pvp, but only under some specific circunstances
    -- for example, prevent always but if aoe hits > X, (X could be a slider in the menu )
    -- then don't prevent aoe cast, or prevent aoe for pvp only if my hp is les than X hp percentage,
    -- or only prevent aoe when main target selector enemy is close to me in X units, etc
    prevent_aoe_logic_for_pvp = checkbox:new(true, get_hash(local_utility.plugin_label .. "ice_shards_prevent_aoe_logic_for_pvp"))
}

local function menu()
    if menu_elements.ice_shards_sub_tree:push("Ice Shards") then
        menu_elements.logics_enable:render("Enable Ice Shards Cast", "")
        if menu_elements.logics_enable:get() then
            menu_elements.cast_ice_shards_opts:render("Cast Options", local_utility.combo_options, "")
        end
        menu_elements.ice_shards_sub_tree:pop()
    end

end


local ice_shards_data = spell_data.new(
    1.5,                        -- radius
    10.0,                       -- range
    0.05,                       -- cast_delay
    12.0,                       -- projectile_speed
    true,                       -- has_collision
    293195,                     -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    --targeting_type
)

local next_time_allowed_cast = 0.0;
local function logics(main_ts_target)

    local menu_boolean = menu_elements.logics_enable:get();
    local is_logic_allowed = local_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                293195);

    if not is_logic_allowed then
        return false
    end;

    if not local_utility.is_cast_enabled_by_orbwalker_menu(menu_elements.cast_ice_shards_opts:get()) then
        return false
    end

    local is_preventing_aoe_for_pvp_menucheck = menu_elements.prevent_aoe_logic_for_pvp:get()
    local is_orb_mode_pvp = orbwalker.get_orb_mode() == orb_mode.pvp

    local final_target_to_use = main_ts_target

    -- not pvp or not preventing aoe for pvp then
    local player_position = get_player_position()

    if not is_orb_mode_pvp or not is_preventing_aoe_for_pvp_menucheck then
        local aoe_target = local_target_selector.get_most_hits_circular(player_position, ice_shards_data.range, ice_shards_data.radius * 2)
        if aoe_target.is_valid then
            final_target_to_use = aoe_target.main_target
        end

        if is_orb_mode_pvp then
            local victims = aoe_target.victim_list
            -- this means that there are no elites if we attack this unit, so stick to the initial target
            if not local_utility.is_pvp_cast_allowed_aoe(victims) then
                final_target_to_use = main_ts_target
            end
        end
    end

    local is_pvp = orbwalker.get_orb_mode() == orb_mode.pvp
    if not is_pvp and final_target_to_use:is_elite() then
        return false
    end

    local pred_params = prediction_parameters:new(player_position, 1.0)
    local pred_result = prediction.get_prediction_result(final_target_to_use, pred_params, ice_shards_data, false)

    if pred_result.hitchance <= 0.20 then -- collision
        return false
    end

    if cast_spell.position(293195, pred_result.cast_position, ice_shards_data.cast_delay) then
        
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + ice_shards_data.cast_delay;
        
        --console.print(ice_shards_data.range)
        
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}