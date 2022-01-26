extends Object

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func create_dummy_plugin() -> Node:
	return load("res://addons/friendly-potato-pixels/standalone/dummy_plugin.gd").new()

func setup_toolbar_control() -> Control:
	var control := Control.new()
	control.anchor_left = 0.75
	control.anchor_right = 1.0
	control.anchor_top = 0.0
	control.anchor_bottom = 1.0
	control.margin_top = 7
	control.margin_bottom = -7
	control.margin_left = 7
	control.margin_right = -7
	
	return control

func create_toolbar() -> Control:
	return load("res://addons/friendly-potato-pixels/toolbar.tscn").instance()

func setup_menu_bar_control() -> Control:
	var control := Control.new()
	
	control.anchor_left = 0.0
	control.anchor_right = 1.0
	control.anchor_top = 0.8
	control.anchor_bottom = 1.0
	control.margin_top = 7
	control.margin_bottom = -7
	control.margin_left = 7
	control.margin_right = -7
	
	return control

func create_menu_bar() -> Control:
	return load("res://addons/friendly-potato-pixels/menu_bar.tscn").instance()
