local my_utility = require("my_utility/my_utility")

local menu_elements_shadow_clone_base =
{
    tree_tab            = tree_node:new(1),
    main_boolean        = checkbox:new(true, get_hash(my_utility.plugin_label .. "shadow_clone_main_bool_base")),
}

local function menu()
    
    if menu_elements_shadow_clone_base.tree_tab:push("Shadow Clone")then
        menu_elements_shadow_clone_base.main_boolean:render("Enable Spell", "")
 
        menu_elements_shadow_clone_base.tree_tab:pop()
    end
end

local spell_id_shadow_clone = 357628;


local next_time_allowed_cast = 0.0;
local function logics(target)
    
    local menu_boolean = menu_elements_shadow_clone_base.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
                menu_boolean, 
                next_time_allowed_cast, 
                spell_id_shadow_clone);

    if not is_logic_allowed then
        return false;
    end;

    local player_local = get_local_player();
    
    local player_position = get_player_position();
    local target_position = target:get_position();

    if cast_spell.position(spell_id_shadow_clone, target_position, 1.5) then

        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + 0.5;

        console.print("Rouge, Casted Rain Of Arrows");
        return true;
    end;
            
    return false;
end


return 
{
    menu = menu,
    logics = logics,   
}