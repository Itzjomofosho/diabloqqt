local menu_elements = {
    main_tree = tree_node:new(0),
    filter_input = input_text:new(get_hash("item_filter_input")),
    rarity_checkboxes = {}
}

-- Initialize rarity checkboxes
local rarities = {"normal", "magic", "magic_2", "rare", "rare_2", "legendary", "unique", "set"}
for _, rarity in ipairs(rarities) do
    menu_elements.rarity_checkboxes[rarity] = checkbox:new(true, get_hash("rarity_checkbox_" .. rarity))
end

local function render_menu()
    if menu_elements.main_tree:push("Item Filter") then
        menu_elements.filter_input:render("Filter Text", "Enter text to filter items", true, "Goto Input", "Item Text Filter")

        for rarity, checkbox in pairs(menu_elements.rarity_checkboxes) do
            checkbox:render("Show " .. rarity:upper(), "Toggle to filter " .. rarity .. " items")
        end

        menu_elements.main_tree:pop()
    end
end

local row_padding = 5 -- padding height between rows
local width_padding = 8.72 -- padding width between columns

local screen_width = get_screen_width();
local screen_height = get_screen_height();
local inventory_start_x = (screen_width * 0.6625)
local inventory_start_y = screen_height * 0.671
local slot_width = 64.7
local slot_height = 102
local row_length = 11

-- Function to get the screen position of an inventory slot based on its row and column
local function get_slot_screen_position(item)
    local row = item:get_inventory_row()
    local col = item:get_inventory_column()
    
    local x = inventory_start_x + col * (slot_width + width_padding)
    local y = inventory_start_y + row * (slot_height + row_padding)
    return x, y
end

local function filter_items()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local inventory_items = local_player:get_inventory_items()
    if not inventory_items then
        return
    end

    local filter_text = menu_elements.filter_input:get()
    local lower_filter_text = string.lower(filter_text)

    for _, item in ipairs(inventory_items) do
        local item_name_1 = item:get_name()
        local item_name_2 = item:get_display_name()
        local item_name_3 = item:get_skin_name()

        local lower_item_name_1 = string.lower(item_name_1)
        local lower_item_name_2 = string.lower(item_name_2)
        local lower_item_name_3 = string.lower(item_name_3)

        local item_rarity = item:get_rarity()
        local item_rarity_index = item_rarity + 1
        local rarity_checkbox = menu_elements.rarity_checkboxes[rarities[item_rarity_index]]

        if rarity_checkbox then
            local rarity_allowed = rarity_checkbox:get()
            local name_matches = lower_filter_text == "" or string.find(lower_item_name_1, lower_filter_text) or string.find(lower_item_name_2, lower_filter_text) or string.find(lower_item_name_3, lower_filter_text)

            if rarity_allowed and name_matches then
                local x, y = get_slot_screen_position(item)
                graphics.rect(vec2:new(x, y), vec2:new(x + slot_width, y + slot_height), color_cyan(255), 5.0, 3.0)
            end
        end
    end
end


local function render_visuals()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local is_inventory_open = get_open_inventory_bag() == 0;
    if not is_inventory_open then
        return;
    end

    local hovered_item_data = get_hovered_item();
    local is_hovering_item = hovered_item_data:is_valid();
    if is_hovering_item then
        return;
    end

    filter_items()

end

-- Register the render callback
on_render_menu(render_menu)
on_render(render_visuals)

console.print("Lua Plugin - Inventory Filter - Version 0.6");