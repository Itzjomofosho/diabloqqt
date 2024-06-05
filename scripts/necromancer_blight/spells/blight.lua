local my_utility = require("my_utility/my_utility");

local menu_elements = {
    blight_submenu      = tree_node:new(1),
    blight_boolean      = checkbox:new(true, get_hash(my_utility.plugin_label .. "blight_boolean")),
    blight_mode         = combo_box:new(0, get_hash(my_utility.plugin_label .. "blight_cast_modes")),
    
}

local function menu()
    if menu_elements.blight_submenu:push("Blight") then
        menu_elements.blight_boolean:render("Enable Blight Cast", "");

        if menu_elements.blight_boolean:get() then
            -- create the combo box elements as a table
            local dropbox_options = {"Combo & Clear", "Combo Only", "Clear Only", "Automatic"};
            menu_elements.blight_mode:render("Cast Modes", dropbox_options, "");

        end;

        menu_elements.blight_submenu:pop();
    end;
end

local blight_spell_id = 481293;
-- to get the spell id, go to debug -> draw spell ids

local blight_spell_data = spell_data.new(
    0.40,                       -- radius
    8.00,                       -- range
    0.20,                       -- cast_delay
    12.0,                       -- projectile_speed
    true,                       -- has_wall_collision
    blight_spell_id,            -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
);

local blight_spell_data_2 = spell_data.new(
    0.40,                       -- radius
    8.00,                       -- range
    0.20,                       -- cast_delay
    12.0,                       -- projectile_speed
    false,                       -- has_wall_collision
    blight_spell_id,            -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
);

local spell_data = spell_data.new(
    0.40,                       -- radius
    8.00,                       -- range
    0.20,                       -- cast_delay
    12.0,                       -- projectile_speed
    true,                       -- has_wall_collision
    blight_spell_id,            -- spell_id
    spell_geometry.rectangular, -- geometry_type
    targeting_type.skillshot    -- targeting_type
);

local corpse_explosion_ = require("spells/corpse_explosion");

local last_blight_cast = 0.0;
local last_blight_target_id = 0;
local function logics()

    local menu_boolean = menu_elements.blight_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                last_blight_cast, 
                blight_spell_id,
                menu_elements.blight_mode:get());

    if not is_logic_allowed then
        return false;
    end;

    local local_player = get_local_player();
    local current_resource = local_player:get_primary_resource_current();
    local max_resource = local_player:get_primary_resource_max();
    local resource_percentage = current_resource / max_resource; 

    local corpses_data = corpse_explosion_.get_corpse_explosion_data();
    if corpses_data.is_valid and resource_percentage < 0.80 then
        return false;
    end

    local player_position = get_player_position();
    local cursor_position = get_cursor_position(); -- get cursor position for angle calculation
    local all_targets = target_selector.get_near_target_list(player_position, 10.0); 

    local near_list, far_list = {}, {};

    -- Split targets into near and far lists
    for _, target in ipairs(all_targets) do
        local target_position = target:get_position();
        local distance_sqr = target_position:squared_dist_to_ignore_z(player_position);
        local is_near = distance_sqr < (5.5 * 5.5);

        if is_near then
            table.insert(near_list, target);
        else
            table.insert(far_list, target);
        end
    end

    local target_list = #near_list > 0 and near_list or far_list;

    -- Early exit for far targets with low resource
    if #near_list == 0 and resource_percentage <= 55 then
        return false;
    end

    local best_target = nil;
    local max_peers = 0;

    local friend_actors_list = actors_manager.get_ally_actors();
    for _, target in ipairs(target_list) do

        local target_position = target:get_position();
        local is_wall_collision = target_selector.is_wall_collision(player_position, target, 1.0);
        
        local is_wall_exception = false;
        if is_wall_collision then
            for _, actor in ipairs(friend_actors_list) do
                local actor_position = actor:get_position();
                local actor_distance_sqr = actor_position:squared_dist_to_ignore_z(target_position);
                if actor_distance_sqr < (3.0 * 3.0) then
                    local actor_name = actor:get_skin_name();
                    if actor_name == "necro_boneWall_actor" then
                        is_wall_exception = true;
                        break;
                    end
                end
            end
        end

        if not is_wall_collision or is_wall_exception then
            
            local is_valid_target = #near_list > 0 or my_utility.is_target_within_angle(player_position, cursor_position, target_position, 45);

            if is_valid_target then
                local peers_count = utility.get_amount_of_units_inside_circle(target_position, 2.0);

                if peers_count > max_peers then
                    best_target = target;
                    max_peers = peers_count;
                end
            end
        end
    end

    if not best_target then
        return false;
    end

    local current_time = get_time_since_inject();
    local best_target_id = best_target:get_id();
    if last_blight_target_id == best_target_id then
        if current_time - last_blight_cast < 2.0 then
            return false;
        end;
    end

    -- generate prediction

    local best_target_position = best_target:get_position();

    local is_wall_exception = false;
    for _, actor in ipairs(friend_actors_list) do
        local actor_position = actor:get_position();
        local actor_distance_sqr = actor_position:squared_dist_to_ignore_z(best_target_position);
        if actor_distance_sqr < (3.0 * 3.0) then
            local actor_name = actor:get_skin_name();
            if actor_name == "necro_boneWall_actor" then
                is_wall_exception = true;
                break;
            end
        end
    end

    if is_wall_exception then
        spell_data = blight_spell_data_2; -- has no collision
    else
        spell_data = blight_spell_data;
    end

    local debug_call = false;
    local parameters = prediction_parameters:new(player_position, 0.20);
    local prediction_result = prediction.get_prediction_result(best_target, parameters, spell_data, debug_call)
    local prediction_hitchance = prediction_result.hitchance;

    if prediction_hitchance < 0.50 then
        return false;
    end

    local cast_position = prediction_result.cast_position
    if cast_spell.position(blight_spell_id, cast_position, 0.55) then
        console.print("[Necromancer] [SpellCast] [Bligt] Target " .. best_target:get_skin_name());
        last_blight_cast = current_time + 0.60;
        last_blight_target_id = best_target_id;
        return true;
    end;

    return false;
end

return 
{
    menu = menu,
    logics = logics,   
}