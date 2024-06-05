local utility = require("utility/local_utility")
local menu_elements =
{
    main_boolean        = checkbox.new(true, get_hash(utility.plugin_label .. "main_boolean")),
    main_tree           = tree_node.new(0),
}

return menu_elements;