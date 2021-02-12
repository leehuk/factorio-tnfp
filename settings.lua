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
        name = "tnp-trainstop-mod-behaviour",
        type = "string-setting",
        setting_type = "runtime-global",
        order = "a[message]-b[target]",
        default_value = "safe",
        allowed_values = {
            "ignore",
            "safe",
            "standard"
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
        name = "tnp-train-arrival-path",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "b[train]-a[arrival]-a[path]",
        default_value = true
    },
    {
        name = "tnp-train-arrival-timeout",
        type = "int-setting",
        setting_type = "runtime-per-user",
        order = "b[train]-a[arrival]-b[timeout]",
        default_value = 60,
        minimum_value = 0,
        maximum_value = 300
    },
    {
        name = "tnp-train-boarding-behaviour",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "b[train]-b[boarding]-a[behaviour]",
        default_value = "stationselect",
        allowed_values = {
            "manual",
            "stationselect"
        }
    },
    {
        name = "tnp-train-boarding-timeout",
        type = "int-setting",
        setting_type = "runtime-per-user",
        order = "b[train]-b[boarding]-b[timeout]",
        default_value = 15,
        minimum_value = 0,
        maximum_value = 120
    },
    {
        name = "tnp-stationlist-view",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "c[stationlist]-a[view]",
        default_value = "all",
        allowed_values = {
            "train",
            "tnfp",
            "all"
        }
    },
    {
        name = "tnp-stationlist-focussearch",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "c[stationlist]-b[focussearch]",
        default_value = false
    },
    {
        name = "tnp-override-vanilla-wait",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "d[override]-a[vanillawait]",
        default_value = false
    }
})