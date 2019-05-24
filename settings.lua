data:extend({
    {
        name = "tnp-message-level",
        type = "string-setting",
        setting_type = "runtime-global",
        order = "a[message]-a[level]",
        default_value = "detailed",
        allowed_values = {
            "core",
            "standard",
            "detailed"
        }
    },
    {
        name = "tnp-message-target",
        type = "string-setting",
        setting_type = "runtime-global",
        order = "a[message]-b[target]",
        default_value = "mixed standard",
        allowed_values = {
            "mixed core",
            "mixed standard",
            "console",
            "flying text"
        }
    },
    {
        name = "tnp-train-search-radius",
        type = "int-setting",
        setting_type = "runtime-per-user",
        order = "a[search]-r[radius]",
        default_value = 32,
        minimum_value = 1,
        maximum_value = 64
    },
    {
        name = "tnp-train-arrival-behaviour",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "f[train]-f[arrival]-a[behaviour]",
        default_value = "manual",
        allowed_values = {
            "manual"
        }
    }
})