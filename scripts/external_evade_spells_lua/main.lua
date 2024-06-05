

-- if true then return end
local initialized_evade_db = false;
on_update(function ()
 
    if initialized_evade_db then
        return
    end
    initialized_evade_db = true
    -- console.print("inserted evade spells from lua")
    evade.register_circular_spell({"knight_caster_holystrike_proxy"}, "HolyStrike", 1.00, color_yellow(255), danger_level.medium);
    -- evade.register_circular_spell({"fallen_lunatic_suicide_prep_ring"}, "Lunatic Suicide", 3.00, color_red(255), danger_level.high);
    evade.register_circular_spell({"electricLance_beamActor_B"}, "Electric Lance", 3.50, color_red(255), danger_level.high);
    
    
    evade.register_circular_spell({"DRLG_Trap_Spikes_3x3"}, 
    "Spike Trap", 2.00, 
    color_white(255), danger_level.medium);

    evade.register_circular_spell({"MarkerLocation_SkeletonBoss_Capstone_Center"}, 
    "Capstone Static", 2.00, 
    color_white(255), danger_level.medium);

    evade.register_circular_spell({"skeleton_boss_capstone_storm"}, 
    "Capstone Storm", 2.00, 
    color_white(255), danger_level.medium);

    -- 
  
    -- console.print(type("Brute Slam") .. " " ..  type({"knightBrute_groundSlam_projectileCore"}) .. " " .. 
    -- type(1.20) .. " " ..  type(10.20) .. " " ..  type(color_white(255)) .. " " ..  type(true) .. " " .. 
    --  type(danger_level.high)  .. " " .. 
    --  type(false)  .. " " ..  type(2.0))

    -- wip, not working
    -- evade.register_rectangular_spell("Brute Slam", {"knightBrute_groundSlam_projectileCore"},
    -- 1.20, 10.0, color_white(255), true, danger_level.high, false, 2.0);

end)

local initialized_evade_dash_db = false;
on_update(function ()
    if initialized_evade_dash_db then
        -- only insert information 1 time
        return
    end

    local local_player = get_local_player()
    if not local_player then
        return
    end
    initialized_evade_dash_db = true
    -- local spell_range = 4.5
    -- local cast_delay = 0.0
    -- local teleport_spell_id = 288106
    -- local is_sorcerer = local_player:get_character_class_id() == 0 -- 0 is sorcerer
    -- evade.register_dash(is_sorcerer, "Sorcerer Teleport", teleport_spell_id , spell_range , cast_delay, true, true, true)

    -- local spell_range = 6.5
    -- local cast_delay = 0.10
    -- local dash_spell_id = 358761
    -- local is_rogue= local_player:get_character_class_id() == 3 -- 3 is rogue
    -- evade.register_dash(is_rogue, "Rogue Dash", dash_spell_id, spell_range , cast_delay, true, true, true)


end)

