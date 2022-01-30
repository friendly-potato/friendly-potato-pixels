extends Object

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	logger.setup(self)

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

func create_toolbar() -> Control:
	var r: Control = load("res://addons/friendly-potato-pixels/toolbar.tscn").instance()
	
	r.anchor_left = 0.75
	r.anchor_right = 1.0
	r.anchor_top = 0.0
	r.anchor_bottom = 1.0
	
	r.margin_top = 7
	r.margin_bottom = -7
	r.margin_left = 7
	r.margin_right = -7
	
	return r

func create_menu_bar() -> Control:
	var r: Control = load("res://addons/friendly-potato-pixels/menu_bar.tscn").instance()
	
	r.anchor_left = 0.0
	r.anchor_right = 0.75
	r.anchor_top = 0.8
	r.anchor_bottom = 1.0
	
	r.margin_top = 7
	r.margin_bottom = -7
	r.margin_left = 7
	r.margin_right = -7
	
	return r
