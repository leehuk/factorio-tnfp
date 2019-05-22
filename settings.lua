data:extend({
    {
        name = "ptn-train-search-radius",
        type = "int-setting",
        setting_type = "runtime-per-user",
        order = "a[search]-r[radius]",
        default_value = 32,
        minimum_value = 1,
        maximum_value = 64
    },
    {
        name = "ptn-train-arrival-behaviour",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "f[train]-f[arrival]-a[behaviour]",
        default_value = "manual",
        allowed_values = {
            "manual"
        }
    }
})