data.raw["gui-style"].default["tnp_stationlist_headingarea"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    bottom_padding = 4,
    horizontally_stretchable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_headingfiller"] = {
    type = "empty_widget_style",
    parent = "draggable_space_header",
    height = 24,
    natural_height = 24,
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_subheading"] = {
    type = "label_style",
    font = "default-bold",
    single_line = true,
    font_color = {1, 0.901961, 0.752941},
    horizontal_align = "left",
    vertical_align = "center"
}

data.raw["gui-style"].default["tnp_stationlist_arrivalbehfiller"] = {
    type = "empty_widget_style",
    height = 16,
    natural_height = 16,
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_stationtypearea"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    visible = true,
    height = 20,
    width = 332
}

data.raw["gui-style"].default["tnp_stationlist_stationtypetext"] = {
    type = "label_style",
    font = "default-bold",
    single_line = true,
    horizontal_align = "left",
    vertical_align = "center",
    cell_padding = 0,
    left_padding = 4
}

data.raw["gui-style"].default["tnp_stationlist_stationtypetable"] = {
    type = "table_style",
    vertical_spacing = 0,
    draw_vertical_lines = true,
    natural_width = 332,
    horizontally_squashable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_stationtyperadio"] = {
    type = "radiobutton_style",
    parent = "radiobutton",
    horizontally_stretchable = "on"
}

data.raw["gui-style"].default["tnp_stationlist_searcharea"] = {
    type = "vertical_flow_style",
    parent = "vertical_flow",
    visible = true,
    height = 34,
    width = 332,
    bottom_padding = 4
}

data.raw["gui-style"].default["tnp_stationlist_search"] = {
    type = "textbox_style",
    parent = "textbox",
    visible = true,
    height = 30,
    width = 332
}

data.raw["gui-style"].default["tnp_stationlist_stationlistscroll"] = {
    type = "scroll_pane_style",
    height = 404,
    width = 356,
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never"
}

data.raw["gui-style"].default["tnp_stationlist_stationlisttable"] = {
    type = "table_style",
    vertical_spacing = 0
}

data.raw["gui-style"].default["tnp_stationlist_stationlistrow"] = {
    type = "horizontal_flow_style",
    parent = "horizontal_flow",
    visible = true,
    height = 28,
    natural_width = 324,
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