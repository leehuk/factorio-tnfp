data:extend({
    {
        name = "ptn-handle-request",
        type = "shortcut",
        action = "lua",
        associated_control_input = "ptn-handle-request",
        technology_to_unlock = "automated-rail-transportation",
        order = "p[ptn]-r[request]",
        localised_name = {
            "shortcut.ptn-handle-request"
        },
        icon = {
            filename = "__PlayerTrainNetwork__/graphics/icons/shortcut-ptn-32.png",
            priority = "extra-high-no-scale",
            size = 32,
            scale = 1,
            flags = {
                "icon"
            }
        },
        small_icon = {
            filename = "__PlayerTrainNetwork__/graphics/icons/shortcut-ptn-24.png",
            priority = "extra-high-no-scale",
            size = 24,
            scale = 1,
            flags = {
                "icon"
            }
        }
    }
})