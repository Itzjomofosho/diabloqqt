local local_player = get_local_player();
if local_player == nil then
    return
end

local character_id = local_player:get_character_class_id();
local is_druid = character_id == 5;
if not is_druid then
     return
end;

local menu = require("menu");

local spells =
{
    tornado         = require("spells/tornado"),
    wind_shear      = require("spells/wind_shear"),
    hurricane       = require("spells/hurricane"),
    grizzly_rage    = require("spells/grizzly_rage"),
    cyclone_armor   = require("spells/cyclone_armor"),
    blood_howls     = require("spells/blood_howls"),
}

on_render_menu (function ()

    if not menu.main_tree:push("Druid: Tornado") then
        return;
    end;

    menu.main_boolean:render("Enable Plugin", "");

    if menu.main_boolean:get() == false then
      -- plugin not enabled, stop rendering menu elements
      menu.main_tree:pop();
      return;
   end;
 
    spells.tornado.menu();
    spells.wind_shear.menu();
    spells.hurricane.menu();
    spells.grizzly_rage.menu();
    spells.cyclone_armor.menu();
    spells.blood_howls.menu();
    menu.main_tree:pop();

end
)

local can_move = 0.0;
local cast_end_time = 0.0;

-- local glow_target = local_player;

local claw_buff_name = "legendary_druid_100"
local claw_buff_name_hash = claw_buff_name
local claw_buff_name_hash_c = 1206403

local bear_buff_name = "druid_maul"
local bear_buff_name_hash = bear_buff_name
local bear_buff_name_hash = 309070

local my_target_selector = require("my_utility/my_target_selector");

-- on_update callback
on_update(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    -- local local_player = get_local_player();
    -- local buffs = local_player:get_buffs();
    
    -- for _, buff in ipairs(buffs) do
    --     local buff_name = buff:name();
    --     console.print("Buff Name: " .. buff_name);
    -- end    

    local is_wolf_form = false;
    local local_player_buffs = local_player:get_buffs();
    for _, buff in ipairs(local_player_buffs) do
        -- console.print("buff name ", buff:name());
        -- console.print("buff hash ", buff.name_hash);
        if buff.name_hash == claw_buff_name_hash_c then
            is_wolf_form = true;
            break;
        end

        -- if buff.name_hash == mount_buff_name_hash_c then
        --     is_blood_mist = true;
        --     break;
        -- end

        -- if buff.name_hash == shrine_conduit_buff_name_hash_c then
        --     is_blood_mist = true;
        --     break;
        -- end
    end

    local current_time = get_time_since_inject()
    if current_time < cast_end_time then
        return;
    end;

    local screen_range = 16.0;
    local player_position = get_player_position();

    local collision_table = { false, 2.0 };
    local floor_table = { true, 5.0 };
    local angle_table = { false, 90.0 };

    local entity_list = my_target_selector.get_target_list(
        player_position,
        screen_range, 
        collision_table, 
        floor_table, 
        angle_table);

    local target_selector_data = my_target_selector.get_target_selector_data(
        player_position, 
        entity_list);

    if not target_selector_data.is_valid then
        return;
    end

    local max_range = 12.0;
    local best_target = target_selector_data.closest_unit;

    if target_selector_data.has_elite then
        local unit = target_selector_data.closest_elite;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end        
    end

    if target_selector_data.has_boss then
        local unit = target_selector_data.closest_boss;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end

    if target_selector_data.has_champion then
        local unit = target_selector_data.closest_champion;
        local unit_position = unit:get_position();
        local distance_sqr = unit_position:squared_dist_to_ignore_z(player_position);
        if distance_sqr < (max_range * max_range) then
            best_target = unit;
        end
    end   

    if not best_target then
        return;
    end

    -- will be used in render
    -- glow_target = best_target;

    local best_target_position = best_target:get_position();
    local distance_sqr = best_target_position:squared_dist_to_ignore_z(player_position);

    if distance_sqr > (max_range * max_range) then            
        best_target = target_selector_data.closest_unit;
        local closer_pos = best_target:get_position();
        local distance_sqr_2 = closer_pos:squared_dist_to_ignore_z(player_position);
        if distance_sqr_2 > (max_range * max_range) then
            return;
        end
    end

    local orbwalker_mode = orbwalker.get_orb_mode()
    if orbwalker_mode == 0 then
        return;
    end;

    if spells.grizzly_rage.logics(player_position) then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.hurricane.logics(player_position) then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.cyclone_armor.logics(player_position) then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.blood_howls.logics() then
        cast_end_time = current_time + 0.2;
        return;
    end;

    if spells.tornado.logics(best_target) then
        cast_end_time = current_time + 0.5;
        return;
    end;

    if spells.wind_shear.logics(best_target)then
        cast_end_time = current_time + 0.4;
        return;
    end;

end)

local draw_player_circle = false;
local draw_enemy_circles = false;

on_render(function ()

    if menu.main_boolean:get() == false then
        return;
    end;

    local local_player = get_local_player();
    if not local_player then
        return;
    end

    local player_position = local_player:get_position();
    local player_screen_position = graphics.w2s(player_position);
    if player_screen_position:is_zero() then
        return;
    end

    -- if glow_target and glow_target:is_enemy()  then
    --     local glow_target_position = glow_target:get_position();
    --     local glow_target_position_2d = graphics.w2s(glow_target_position);
    --     graphics.line(glow_target_position_2d, player_screen_position, color_red(150), 2)
    -- end

    if draw_player_circle then
        graphics.circle_3d(player_position, 8, color_white(85), 3.5, 144)
        graphics.circle_3d(player_position, 6, color_white(85), 2.5, 144)
    end    

    if draw_enemy_circles then
        local enemies = actors_manager.get_enemy_npcs()

        for i,obj in ipairs(enemies) do
        local position = obj:get_position();
        local distance_sqr = position:squared_dist_to_ignore_z(player_position);
        local is_close = distance_sqr < (8.0 * 8.0);
            -- if is_close then
                graphics.circle_3d(position, 1, color_white(100));

                local future_position = prediction.get_future_unit_position(obj, 0.4);
                graphics.circle_3d(future_position, 0.5, color_yellow(100));
            -- end;
        end;
    end

end);

console.print("Lua Plugin - Druid Tornado - Version 1.4");