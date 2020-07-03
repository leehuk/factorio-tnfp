data.raw["gui-style"].default["tnp_sl_frame"] = {
    type = "frame_style",
    parent = "frame",
    bottom_padding = 2
}

data.raw["gui-style"].default["tnp_sl_heading_flow"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    bottom_padding = 4,
    horizontally_stretchable = "on"
}

data.raw["gui-style"].default["tnp_sl_heading_filler"] = {
    type = "empty_widget_style",
    parent = "draggable_space_header",
    height = 24,
    natural_height = 24,
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

data.raw["gui-style"].default["tnp_sl_subheading_label"] = {
    type = "label_style",
    font = "default-bold",
    single_line = true,
    font_color = {1, 0.901961, 0.752941},
    horizontal_align = "left",
    vertical_align = "center"
}

data.raw["gui-style"].default["tnp_sl_empty_filler"] = {
    type = "empty_widget_style",
    height = 16,
    natural_height = 16,
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

data.raw["gui-style"].default["tnp_sl_subheading_flow"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    left_padding = 12,
    right_padding = 12,
    top_padding = 0,
    bottom_padding = 12,
    horizontal_spacing = 0
}

data.raw["gui-style"].default["tnp_sl_search_field"] = {
    type = "textbox_style",
    parent = "textbox",
    visible = true,
    height = 30,
    width = 332
}

data.raw["gui-style"].default["tnp_sl_list_scroll"] = {
    type = "scroll_pane_style",
    height = 350,
    width = 344
}   

data.raw["gui-style"].default["tnp_sl_list_table"] = {
    type = "table_style",
    vertical_spacing = 0
}

data.raw["gui-style"].default["tnp_stationlist_stationlistrow"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    visible = true,
    height = 28,
    maximal_width = 324,
    horizontal_spacing = 1,
    horizontally_squashable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_stationlistentry"] = {
    type = "button_style",
    parent = "button",
    horizontal_align = "left",
    height = 28,
    natural_width = 324,
    horizontally_squashable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_stationlistpin"] = {
    type = "button_style",
    parent = "button",
    horizontal_align = "center",
    vertical_align = "center",
    height = 28,
    width = 28,
    scalable = false,
    padding = 2,
    margin = 0
}

data.raw["gui-style"].default["tnp_stationlist_stationlistpinned"] = {
    type = "button_style",
    parent = "dark_button",
    horizontal_align = "center",
    vertical_align = "center",
    height = 28,
    width = 28,
    scalable = false,
    padding = 2,
    margin = 0
}

data.raw["gui-style"].default["tnp_stationlist_stationlisthome"] = {
    type = "button_style",
    parent = "dark_button",
    horizontal_align = "center",
    vertical_align = "center",
    height = 28,
    width = 28,
    scalable = false,
    padding = 2,
    margin = 0
}