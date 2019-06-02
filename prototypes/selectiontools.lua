data:extend({
    {
        name = "tnp-railtool",
        type = "selection-tool",
        flags = {
            "hidden"
        },
        icon = "__TrainNetworkForPlayers__/graphics/icons/shortcut-tnprailtool-32.png",
        icon_size = 32,
        selection_color = {
            b = 1,
            g = 1,
            r = 1
          },
          alt_selection_color = {
            b = 1,
            g = 1,
            r = 1
          },
          selection_mode = {
              "buildable-type"
          },
          alt_selection_mode = {
              "nothing"
          },
          selection_cursor_box_type = "entity",
          alt_selection_cursor_box_type = "not-allowed",
          entity_filters = {
              "straight-rail"
          },
          alt_entity_filters = {
          },
          entity_type_filters = {
              "straight-rail",
              "train-stop"
          },
          alt_entity_type_filters = {
          },
          entity_filter_mode = "whitelist",
          alt_entity_filter_mode = "whitelist",
          stackable = false,
          stack_size = 1,
          show_in_library = false
    }
})