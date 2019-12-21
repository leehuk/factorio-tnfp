data:extend({
    {
        name = "tnp-railtool",
        type = "selection-tool",
        flags = {
            "hidden"
        },
        icon = "__TrainNetworkForPlayers__/graphics/icons/railtool-32.png",
        icon_size = 32,
        selection_color = {
            b = 210,
            g = 210,
            r = 210
        },
        alt_selection_color = {
            b = 150,
            g = 150,
            r = 150
        },
        selection_mode = {
            "buildable-type"
        },
        alt_selection_mode = {
            "buildable-type"
        },
        selection_cursor_box_type = "entity",
        alt_selection_cursor_box_type = "entity",
        entity_filters = {
            "straight-rail"
        },
        alt_entity_filters = {
            "straight-rail"
        },
        entity_type_filters = {
            "straight-rail",
            "train-stop"
        },
        alt_entity_type_filters = {
            "straight-rail",
            "train-stop"
        },
        entity_filter_mode = "whitelist",
        alt_entity_filter_mode = "whitelist",
        stackable = false,
        stack_size = 1,
        show_in_library = false
    },
    {
        name = "tnp-railtool-supply",
        type = "selection-tool",
        flags = {
            "hidden"
        },
        icon = "__TrainNetworkForPlayers__/graphics/icons/railtool-32.png",
        icon_size = 32,
        selection_color = {
            b = 150,
            g = 150,
            r = 150
        },
        alt_selection_color = {
            b = 210,
            g = 210,
            r = 210
        },
        selection_mode = {
            "buildable-type"
        },
        alt_selection_mode = {
            "buildable-type"
        },
        selection_cursor_box_type = "entity",
        alt_selection_cursor_box_type = "entity",
        entity_filters = {
        },
        alt_entity_filters = {
        },
        entity_type_filters = {
            "train-stop"
        },
        alt_entity_type_filters = {
            "train-stop"
        },
        entity_filter_mode = "whitelist",
        alt_entity_filter_mode = "whitelist",
        stackable = false,
        stack_size = 1,
        show_in_library = false
    }
})