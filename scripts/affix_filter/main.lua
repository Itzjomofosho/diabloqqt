local my_utility = require("my_utility/my_utility")
local menu = require("menu");

local menu_elements = {
    main_tree = tree_node:new(0),
    affix_input = input_text:new(get_hash("test")),
    affix_sliders = {}, 
    affixes_combo_box = combo_box:new(0, get_hash(my_utility.plugin_label .. "affixes_c_box")),
    common_checkbox = {},
    all_affix_checkbox = {},
    class_specific_checkbox = {},
    affix_color_picker = colorpicker:new(get_hash(my_utility.plugin_label .. "affix_color_idk"), ImVec4:new(255, 255, 0, 255)),
    search_color_picker = colorpicker:new(get_hash(my_utility.plugin_label .. "search_color_idk"), ImVec4:new(0, 255, 255, 255)),
    position_submenu = tree_node:new(1),
    slot_offset_x_slider = slider_int:new(0, 150, 49, get_hash(my_utility.plugin_label .. "slot_offset_x")),
    slot_offset_y_slider = slider_int:new(0, 150, 76, get_hash(my_utility.plugin_label .. "slot_offset_y")),
    box_size_checkbox = checkbox:new(true, get_hash(my_utility.plugin_label .. "box_size_checkbox")),
    box_space_slider = slider_float:new(0, 1.0, 0.1, get_hash(my_utility.plugin_label .. "box_size_slider")),
    box_height_slider = slider_int:new(0, 100, 76, get_hash(my_utility.plugin_label .. "box_height_slider")),
    box_width_slider = slider_int:new(0, 100, 50, get_hash(my_utility.plugin_label .. "box_width_slider")),

}

local all_affixes =
{"DamageReduction_Burning", "Damage_to_Frozen", "Dodge", "Damage",
"DamageReductionClose", "Resource_MaxMana", "Life", "CoreStats_All",
"Elite_Kill_Damage", "Damage_to_Slowed", "Damage_to_Near", "Damage_to_Far",
"Damage_to_CCd", "CoreStat_Willpower", "CoreStat_Intelligence",
"Armor", "Lucky_Hit_Resource", "Dodge_Malee", "Damage_CracklingEnergy", "Damage_to_Chilled",
"CritDamage", "Lucky_Hit_Heal_Life", "LifeRegen", "CD_reduction", "Damage_to_Trapped",
"Execute", "Damage_to_Dazed", "CritDmage_With_Imbued", "Resource_Cost_Reduction_Rouge_Lesser",
"CDR_Imbues", "Damage_to_low_life", "Dodge_Gives_Damage", "CoreStat_StrenghtPercent", "DamageReductioninjured", "Damage_Weapon_DualWield",
"CoreStat_All_Weapon", "CC_Duration_Reduction", "Dodge_Gives_AttackSpeed" }
for _, affix in ipairs(all_affixes) do
    menu_elements.all_affix_checkbox[affix] = checkbox:new(true, get_hash("affix_class_checkbox" .. affix))
    menu_elements.affix_sliders[affix] = slider_int:new(0, 100, 0, get_hash("slider_affix_class_" .. affix))
end


local affixes_class = {"CoreStat_All_Weapon", "CC_Duration_Reduction", "Dodge_Gives_AttackSpeed", "Resource_Cost_Reduction_Rouge_Lesser", "CritDmage_With_Imbued", "Execute", "Damage_to_Frozen", "Damage_to_Trapped", "CDR_Imbues",}
for _, affix in ipairs(affixes_class) do
    menu_elements.class_specific_checkbox[affix] = checkbox:new(true, get_hash("affix_class_checkbox" .. affix))
    menu_elements.affix_sliders[affix] = slider_int:new(0, 100, 0, get_hash("slider_affix_class_" .. affix))
end

local affixes_common = {"CoreStats_All", "CD_reduction ",  "Life", "CoreStat_Intelligence", "CoreStat_Willpower", "Armor", "CritDamage", "LifeRegen", "CoreStat_StrenghtPercent", "Dodge", "Lucky_Hit_Resource", }
for _, affix in ipairs(affixes_common) do
    menu_elements.common_checkbox[affix] = checkbox:new(true, get_hash("affix_common_checkbox" .. affix))
    menu_elements.affix_sliders[affix] = slider_int:new(0, 100, 0, get_hash("slider_affix_common_" .. affix))
end

local function class_specific()
    for _, affix in ipairs(affixes_class) do
        local checkbox = menu_elements.class_specific_checkbox[affix]
        local affix_slider = menu_elements.affix_sliders[affix]

        if checkbox then
            checkbox:render("Affix " .. affix:upper(), "Class Specific " .. affix .. " of item")

            if checkbox:get() and affix_slider then
                affix_slider:render("Slider for " .. affix, "", 2)
            end
        end
    end
end

local function common_affixes()
    for _, affix in ipairs(affixes_common) do
        local checkbox = menu_elements.common_checkbox[affix]
        local affix_slider = menu_elements.affix_sliders[affix]

        if checkbox then
            checkbox:render("Affix " .. affix:upper(), "Common Affixes " .. affix .. " of item")

            if checkbox:get() and affix_slider then
                affix_slider:render("Slider for " .. affix, "", 2)
            end
        end
    end
end

local function all_affixes_f()
    for _, affix in ipairs(all_affixes) do
        local checkbox = menu_elements.all_affix_checkbox[affix]
        local affix_slider = menu_elements.affix_sliders[affix]

        if checkbox then
            checkbox:render("Affix " .. affix:upper(), "All Affixes " .. affix .. " of item")

            if checkbox:get() and affix_slider then
                affix_slider:render("Slider for " .. affix, "", 2)
            end
        end
    end
end

local function render_menu()
    if not menu.main_tree:push("Affix Filter") then
        return
    end

    menu.main_boolean:render("Enable Affix Filter", "")

    if not menu.main_boolean:get() then
        menu.main_tree:pop()
        return
    end

    if menu_elements.main_tree:push("Drawing Position Adjustment") then
        menu_elements.box_space_slider:render("Spacing", "xd", 1)
        menu_elements.slot_offset_x_slider:render("Slot Offset X", "Adjust slot offset in X direction")
        menu_elements.slot_offset_y_slider:render("Slot Offset Y", "Adjust slot offset in Y direction")
        menu_elements.box_height_slider:render("Box Height Slider", "Adjust height of box")
        menu_elements.box_width_slider:render("Box Width Slider", "Adjust width of box")

        menu_elements.main_tree:pop() 
    end
    
    if menu_elements.main_tree:push("Affix Filter Selection") then
        menu_elements.affix_input:render("Filter Text", "Enter text to filter affix", true, "Go to", "Affix Text Filter")

        if menu.main_boolean:get() then
            menu_elements.affix_color_picker:render("Set Color For Affixes", "", true, "", "")
            menu_elements.search_color_picker:render("Set Color For Affixes That Dont Meet Roll %", "", true, "", "")
            local dropbox_options = {"Class Specific", "Common Affixes", "All Affixes"}
            menu_elements.affixes_combo_box:render("Affix Choose", dropbox_options, "")

            if menu_elements.affixes_combo_box:get() == 0 then
                class_specific()
            end

            if menu_elements.affixes_combo_box:get() == 1 then
                common_affixes()
             end

            if menu_elements.affixes_combo_box:get() == 2 then
                all_affixes_f()
            end
        end

        menu_elements.main_tree:pop()
    end

    menu.main_tree:pop()
end

local slot_width = menu_elements.slot_offset_x_slider:get()
local slot_height = menu_elements.slot_offset_y_slider:get()

local function get_affix_screen_position(item)
    local row = item:get_inventory_row()
    local col = item:get_inventory_column()

    local screen_width = get_screen_width()
    local screen_height = get_screen_height()

    local row_padding = 0.01 * (screen_height / screen_height)
    local width_padding = 0.01 * (screen_width / screen_width)
    local inventory_start_x = (screen_width * 0.6619)
    local inventory_start_y = screen_height * 0.670

    local slot_width = menu_elements.slot_offset_x_slider:get()
    local slot_height = menu_elements.slot_offset_y_slider:get()

    local space_between_items_x = menu_elements.box_space_slider:get() * (screen_width / screen_width)
    local space_between_items_y = 6.2 * (screen_height / screen_height)

    local adjusted_slot_width = slot_width + space_between_items_x
    local adjusted_slot_height = slot_height + space_between_items_y

    local box_width = menu_elements.box_width_slider:get()
    local box_height = menu_elements.box_height_slider:get()

    local margin_x = space_between_items_x / 2.5
    local margin_y = space_between_items_y / 2.5

    local x = inventory_start_x + col * (adjusted_slot_width + width_padding) + col * space_between_items_x + margin_x
    local y = inventory_start_y + row * (adjusted_slot_height + row_padding) + row * space_between_items_y + margin_y

    return x, y, box_width, box_height
end

function calculate_percentage(current_value, min_value, max_value)
    if max_value == min_value then
        return 0
    end
    return ((current_value - min_value) / (max_value - min_value)) * 100
end

local function filter_affix()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local inventory_items = local_player:get_inventory_items()
    if not inventory_items then
        return
    end

    local filter_text = menu_elements.affix_input:get()
    local lower_filter_text = string.lower(filter_text)

    local checkbox_options = {
        menu_elements.class_specific_checkbox,
        menu_elements.common_checkbox,
        menu_elements.all_affix_checkbox
    }

    local combo_box_value = menu_elements.affixes_combo_box:get()
    local selected_color = menu_elements.search_color_picker:get()
    for _, item in ipairs(inventory_items) do
        local affixes = item:get_affixes()

        for _, affix in ipairs(affixes) do
            local affix_name = affix:get_name()
            local lower_affix_name = string.lower(affix_name)

            local affix_checkbox = checkbox_options[combo_box_value + 1][affix_name]
            local name_matches = lower_filter_text == "" or string.find(lower_affix_name, lower_filter_text)

            if affix_checkbox and affix_checkbox.get and affix_checkbox:get() and name_matches and combo_box_value then
                local x, y, box_width, box_height = get_affix_screen_position(item)
                graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), selected_color, 5.0, 3.0)
                break
            end
        end
    end
end


local function filter_affix_roll()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local inventory_items = local_player:get_inventory_items()
    if not inventory_items then
        return
    end

    local filter_text = menu_elements.affix_input:get()
    local lower_filter_text = string.lower(filter_text)

    local checkbox_options = {
        menu_elements.class_specific_checkbox,
        menu_elements.common_checkbox,
        menu_elements.all_affix_checkbox
    }

    local combo_box_value = menu_elements.affixes_combo_box:get()
    local selected_color = menu_elements.affix_color_picker:get()
    for _, item in ipairs(inventory_items) do
        local affixes = item:get_affixes()
        local item_matched = false

        for _, affix in ipairs(affixes) do
            local affix_name = affix:get_name()
            local affix_roll = affix:get_roll()
            local affix_roll_min = affix:get_roll_min()
            local affix_roll_max = affix:get_roll_max()
            local rolled = calculate_percentage(affix_roll, affix_roll_min, affix_roll_max)

            local affix_slider = menu_elements.affix_sliders[affix_name]
            local affix_checkbox = checkbox_options[combo_box_value + 1][affix_name]

            local name_matches = lower_filter_text == "" or string.find(string.lower(affix_name), lower_filter_text)

            if affix_slider and affix_checkbox and name_matches and affix_checkbox.get and affix_checkbox:get() then
                local slider_value = affix_slider:get()

                if rolled > slider_value then
                    item_matched = true
                    break
                end
            end
        end

        if item_matched then
            local x, y, box_width, box_height = get_affix_screen_position(item)
            graphics.rect(vec2:new(x, y), vec2:new(x + box_width, y + box_height), selected_color, 5.0, 3.5)
        end
    end
end

local function render_visuals()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local is_inventory_open = get_open_inventory_bag() == 0
    if not is_inventory_open then
        return
    end

    if not menu.main_boolean:get() then
        return
    end

    local inventory_items = local_player:get_inventory_items()
    if not inventory_items then
        return
    end

    filter_affix()
    filter_affix_roll()
end
-- Register the render callbacks
on_render_menu(render_menu)
on_render(render_visuals)

console.print("Lua Plugin - Affix Filter - Version 0.6")