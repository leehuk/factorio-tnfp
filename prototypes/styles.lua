data.raw["gui-style"].default["tnp_stationselect"] = {
    type = "frame_style",
    parent = "frame",
    minimal_height = 420,
    minimal_width = 320,
    cell_padding = 5
}

data.raw["gui-style"].default["tnp_stationselect_top"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    visible = true,
    height = 25,
    width = 310,
}

data.raw["gui-style"].default["tnp_stationselect_topheading"] = {
    type = "label_style",
    font = "heading-1",
    single_line = true,
    horizontal_align = "left",
    vertical_align = "center",
    width = 286
}

data.raw["gui-style"].default["tnp_stationselect_topbutton"] = {
    type = "button_style",
    parent = "slot_button",
    horizontal_align = "right",
    vertical_align = "center",
    scalable = false,
    height = 24,
    width = 24
}

data.raw["gui-style"].default["tnp_stationselect_mainscroll"] = {
    type = "scroll_pane_style",
    height = 485,
    width = 310
}

data.raw["gui-style"].default["tnp_stationselect_table"] = {
    type = "table_style",
    vertical_spacing = 0
}

data.raw["gui-style"].default["tnp_stationselect_station"] = {
    type = "button_style",
    parent = "button",
    horizontal_align = "left",
    width = 290
}