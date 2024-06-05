-- all in one (aio) target selector data
-- returns table:

-- bool, is_valid -- true once finds 1 valid target inside the list regardless of type
-- game_object, closest unit
-- game_object, lowest current health unit
-- game_object, highest current health unit
-- game_object, lowest max health unit
-- game_object, highest max health unit

-- bool, has_elite -- true once finds 1 elite inside the list
-- game_object, closest elite
-- game_object, lowest current health elite
-- game_object, highest current health elite
-- game_object, lowest max health elite
-- game_object, highest max health elite

-- bool, has_champion -- true once finds 1 champion inside the list
-- game_object, closest champion
-- game_object, lowest current health champion
-- game_object, highest current health champion
-- game_object, lowest max health champion
-- game_object, highest max health champion

-- bool, has_boss -- true once finds 1 boss inside the list
-- game_object, closest boss
-- game_object, lowest current health boss
-- game_object, highest current health boss
-- game_object, lowest max health boss
-- game_object, highest max health boss

local function get_target_selector_data(source, list)
    local is_valid = false;

    local possible_targets_list = list;
    if #possible_targets_list == 0 then
        return
        { 
            is_valid = is_valid;
        }
    end;

    local closest_unit = {};
    local closest_unit_distance = math.huge;

    local lowest_current_health_unit = {};
    local lowest_current_health_unit_health = math.huge;

    local highest_current_health_unit = {};
    local highest_current_health_unit_health = 0.0;

    local lowest_max_health_unit = {};
    local lowest_max_health_unit_health = math.huge;

    local highest_max_health_unit = {};
    local highest_max_health_unit_health = 0.0;

    local has_elite = false;
    local closest_elite = {};
    local closest_elite_distance = math.huge;

    local lowest_current_health_elite = {};
    local lowest_current_health_elite_health = math.huge;

    local highest_current_health_elite = {};
    local highest_current_health_elite_health = 0.0;

    local lowest_max_health_elite = {};
    local lowest_max_health_elite_health = math.huge;

    local highest_max_health_elite = {};
    local highest_max_health_elite_health = 0.0;

    local has_champion = false;
    local closest_champion = {};
    local closest_champion_distance = math.huge;

    local lowest_current_health_champion = {};
    local lowest_current_health_champion_health = math.huge;

    local highest_current_health_champion = {};
    local highest_current_health_champion_health = 0.0;

    local lowest_max_health_champion = {};
    local lowest_max_health_champion_health = math.huge;

    local highest_max_health_champion = {};
    local highest_max_health_champion_health = 0.0;

    local has_boss = false;
    local closest_boss = {};
    local closest_boss_distance = math.huge;

    local lowest_current_health_boss = {};
    local lowest_current_health_boss_health = math.huge;

    local highest_current_health_boss = {};
    local highest_current_health_boss_health = 0.0;

    local lowest_max_health_boss = {};
    local lowest_max_health_boss_health = math.huge;

    local highest_max_health_boss = {};
    local highest_max_health_boss_health = 0.0;

    for _, unit in ipairs(possible_targets_list) do
        local unit_position = unit:get_position()
        local distance_sqr = unit_position:squared_dist_to_ignore_z(source)

        local max_health = unit:get_max_health()
        local current_health = unit:get_current_health()

        -- update units data
        if distance_sqr < closest_unit_distance then
            closest_unit = unit;
            closest_unit_distance = distance_sqr;
            is_valid = true;
        end

        if current_health < lowest_current_health_unit_health then
            lowest_current_health_unit = unit;
            lowest_current_health_unit_health = current_health;
        end

        if current_health > highest_current_health_unit_health then
            highest_current_health_unit = unit;
            highest_current_health_unit_health = current_health;
        end

        if max_health < lowest_max_health_unit_health then
            lowest_max_health_unit = unit;
            lowest_max_health_unit_health = max_health;
        end

        if max_health > highest_max_health_unit_health then
            highest_max_health_unit = unit;
            highest_max_health_unit_health = max_health;
        end

        -- update elites data
        local is_unit_elite = unit:is_elite();
        if is_unit_elite then
            has_elite = true;
            if distance_sqr < closest_elite_distance then
                closest_elite = unit;
                closest_elite_distance = distance_sqr;
            end

            if current_health < lowest_current_health_elite_health then
                lowest_current_health_elite = unit;
                lowest_current_health_elite_health = current_health;
            end

            if current_health > highest_current_health_elite_health then
                highest_current_health_elite = unit;
                highest_current_health_elite_health = current_health;
            end

            if max_health < lowest_max_health_elite_health then
                lowest_max_health_elite = unit;
                lowest_max_health_elite_health = max_health;
            end

            if max_health > highest_max_health_elite_health then
                highest_max_health_elite = unit;
                highest_max_health_elite_health = max_health;
            end
        end

        -- update champions data
        local is_unit_champion = unit:is_champion()
        if is_unit_champion then
            has_champion = true
            if distance_sqr < closest_champion_distance then
                closest_champion = unit;
                closest_champion_distance = distance_sqr;
            end

            if current_health < lowest_current_health_champion_health then
                lowest_current_health_champion = unit;
                lowest_current_health_champion_health = current_health;
            end

            if current_health > highest_current_health_champion_health then
                highest_current_health_champion = unit;
                highest_current_health_champion_health = current_health;
            end

            if max_health < lowest_max_health_champion_health then
                lowest_max_health_champion = unit;
                lowest_max_health_champion_health = max_health;
            end

            if max_health > highest_max_health_champion_health then
                highest_max_health_champion = unit;
                highest_max_health_champion_health = max_health;
            end
        end

        -- update bosses data
        local is_unit_boss = unit:is_boss();
        if is_unit_boss then
            has_boss = true;
            if distance_sqr < closest_boss_distance then
                closest_boss = unit;
                closest_boss_distance = distance_sqr;
            end

            if current_health < lowest_current_health_boss_health then
                lowest_current_health_boss = unit;
                lowest_current_health_boss_health = current_health;
            end

            if current_health > highest_current_health_boss_health then
                highest_current_health_boss = unit;
                highest_current_health_boss_health = current_health;
            end

            if max_health < lowest_max_health_boss_health then
                lowest_max_health_boss = unit;
                lowest_max_health_boss_health = max_health;
            end

            if max_health > highest_max_health_boss_health then
                highest_max_health_boss = unit;
                highest_max_health_boss_health = max_health;
            end
        end
    end

    return 
    {
        is_valid = is_valid,

        closest_unit = closest_unit,
        lowest_current_health_unit = lowest_current_health_unit,
        highest_current_health_unit = highest_current_health_unit,
        lowest_max_health_unit = lowest_max_health_unit,
        highest_max_health_unit = highest_max_health_unit,

        has_elite = has_elite,
        closest_elite = closest_elite,
        lowest_current_health_elite = lowest_current_health_elite,
        highest_current_health_elite = highest_current_health_elite,
        lowest_max_health_elite = lowest_max_health_elite,
        highest_max_health_elite = highest_max_health_elite,

        has_champion = has_champion,
        closest_champion = closest_champion,
        lowest_current_health_champion = lowest_current_health_champion,
        highest_current_health_champion = highest_current_health_champion,
        lowest_max_health_champion = lowest_max_health_champion,
        highest_max_health_champion = highest_max_health_champion,

        has_boss = has_boss,
        closest_boss = closest_boss,
        lowest_current_health_boss = lowest_current_health_boss,
        highest_current_health_boss = highest_current_health_boss,
        lowest_max_health_boss = lowest_max_health_boss,
        highest_max_health_boss = highest_max_health_boss,

        list = possible_targets_list
    }

end


-- return table:
-- hits_amount(int)
-- score(float)
-- main_target(gameobject)
-- victim_list(table game_object)
local function get_most_hits_rectangle(source, lenght, width)

    local data = target_selector.get_most_hits_target_rectangle_area_heavy(source, lenght, width);

    local is_valid = false;
    local hits_amount = data.n_hits;
    if hits_amount < 1 then
        return
        {
            is_valid = is_valid;
        }
    end

    local main_target = data.main_target;
    is_valid = hits_amount > 0 and main_target;
    return
    {
        is_valid = is_valid,
        hits_amount = hits_amount,
        main_target = main_target,
        victim_list = data.victim_list,
        score = data.score
    }
end


-- return table:
-- is_valid(bool)
-- hits_amount(int)
-- score(float)
-- main_target(gameobject)
-- victim_list(table game_object)
local function get_most_hits_circular(source, distance, radius)

    local data = target_selector.get_most_hits_target_circular_area_heavy(source, distance, radius);

    local is_valid = false;
    local hits_amount = data.n_hits;
    if hits_amount < 1 then
        return
        {
            is_valid = is_valid;
        }
    end

    local main_target = data.main_target;
    is_valid = hits_amount > 0 and main_target;
    return
    {
        is_valid = is_valid,
        hits_amount = hits_amount,
        main_target = main_target,
        victim_list = data.victim_list,
        score = data.score
    }
end


return
{
    get_target_list = get_target_list,
    get_target_selector_data = get_target_selector_data,

    get_most_hits_rectangle = get_most_hits_rectangle,
    get_most_hits_circular = get_most_hits_circular,
}