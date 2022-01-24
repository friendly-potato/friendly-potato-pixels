extends Control

var plugin: Node

onready var pencil: Button = $PanelContainer/VBoxContainer/HBoxContainer/Left/Pencil
onready var smart_brush: Button = $PanelContainer/VBoxContainer/HBoxContainer/Right/SmartBrush

onready var color_picker: ColorPicker = $PanelContainer/VBoxContainer/ColorPicker

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

func register_main(node: Node) -> void:
	pencil.connect("pressed", node, "_on_pencil_pressed")
	smart_brush.connect("pressed", node, "_on_smart_brush_pressed")
	
	color_picker.connect("color_changed", node, "_on_color_changed")
	color_picker.get_child(1).get_child(1).connect("pressed", node, "_on_color_dropper_pressed")
