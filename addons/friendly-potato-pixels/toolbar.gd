extends Control

signal brush_size_changed(value)

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

const MIN_BRUSH_SIZE: int = 1
var max_brush_size: int = 1

const DEFAULT_COLOR := Color.black

var plugin: Node

onready var pencil: Button = $PanelContainer/VBoxContainer/HBoxContainer/Left/Pencil
onready var smart_brush: Button = $PanelContainer/VBoxContainer/HBoxContainer/Right/SmartBrush

onready var size_line_edit: LineEdit = $PanelContainer/VBoxContainer/SizeContainer/HBoxContainer/LineEdit
onready var size_h_slider: HSlider = $PanelContainer/VBoxContainer/SizeContainer/HSlider

onready var color_picker: ColorPicker = $PanelContainer/VBoxContainer/ColorPicker

var is_registered := false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	logger.setup(self)
	
	size_h_slider.min_value = MIN_BRUSH_SIZE
	size_line_edit.connect("text_changed", self, "_on_size_line_edit_text_changed")
	size_h_slider.connect("value_changed", self, "_on_size_h_slider_value_changed")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_size_line_edit_text_changed(text: String) -> void:
	if not text.is_valid_float():
		return
	
	var new_val := int(text)
	if (new_val < MIN_BRUSH_SIZE or new_val > max_brush_size):
		return
	
	size_h_slider.value = new_val
	emit_signal("brush_size_changed", new_val)

func _on_size_h_slider_value_changed(value: float) -> void:
	var new_val := int(floor(value))
	
	size_line_edit.text = str(new_val)
	emit_signal("brush_size_changed", new_val)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(n: Node) -> void:
	if not is_registered:
		pencil.connect("pressed", n, "_on_pencil_pressed")
		smart_brush.connect("pressed", n, "_on_smart_brush_pressed")
		
		connect("brush_size_changed", n, "_on_brush_size_changed")
		
		color_picker.connect("color_changed", n, "_on_color_changed")
		color_picker.get_child(1).get_child(1).connect("pressed", n, "_on_color_dropper_pressed")
		
		is_registered = true
	
#	max_brush_size = max(n.image.get_width(), n.image.get_height())
	max_brush_size = max(n.current_layer.base_image.get_width(), n.current_layer.base_image.get_height())
	size_h_slider.max_value = max_brush_size
	_on_size_h_slider_value_changed(1.0)
	
	color_picker.color = DEFAULT_COLOR
	color_picker.emit_signal("color_changed", DEFAULT_COLOR)
