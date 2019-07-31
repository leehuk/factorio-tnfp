data:extend({
    {
        name = "tnp-handle-request",
        type = "shortcut",
        action = "lua",
        associated_control_input = "tnp-handle-request",
        technology_to_unlock = "automated-rail-transportation",
        toggleable = true,
        order = "p[tnp]-r[request]",
        localised_name = {
            "shortcut.tnp-handle-request"
        },
        icon = {
            filename = "__TrainNetworkForPlayers__/graphics/icons/shortcut-tnp-32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {
                "icon"
            }
        },
        small_icon = {
            filename = "__TrainNetworkForPlayers__/graphics/icons/shortcut-tnp-24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {
                "icon"
            }
        }
    },
    {
        name = "tnp-handle-railtool",
        type = "shortcut",
        action = "lua",
        associated_control_input = "tnp-handle-railtool",
        technology_to_unlock = "automated-rail-transportation",
        toggleable = false,
        order = "p[tnp]-t[railtool]",
        localised_name = {
            "shortcut.tnp-handle-railtool"
        },
        icon = {
            filename = "__TrainNetworkForPlayers__/graphics/icons/railtool-32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {
                "icon"
            }
        },
        icon = {
            filename = "__TrainNetworkForPlayers__/graphics/icons/railtool-24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {
                "icon"
            }
        }
    }
})