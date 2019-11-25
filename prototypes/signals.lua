data:extend({
    {
        type = "virtual-signal",
        name = "tnp-station",
        icon = "__TrainNetworkForPlayers__/graphics/icons/tnp-station.png",
        icon_size = 32,
        subgroup = "virtual-signal-special",
        order = "z[player-train-network]-a[station]"
    },
    {
        type = "virtual-signal",
        name = "tnp-station-home",
        icon = "__TrainNetworkForPlayers__/graphics/icons/tnp-homestation.png",
        icon_size = 32,
        subgroup = "virtual-signal-special",
        order = "z[player-train-network]-b[station-home]"
    }
})