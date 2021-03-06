extends "res://addons/friendly-potato-pixels/popups/base_dialog.gd"

onready var canvas_x: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/CanvasSize/VBoxContainer/CanvasX/LineEdit
onready var canvas_y: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/CanvasSize/VBoxContainer/CanvasY/LineEdit

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	window_title = "New File"
	
	# warning-ignore:return_value_discarded
	canvas_x.connect("text_changed", self, "_on_canvas_size_changed")
	# warning-ignore:return_value_discarded
	canvas_y.connect("text_changed", self, "_on_canvas_size_changed")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_canvas_size_changed(text: String) -> void:
	accept_button.disabled = not text.is_valid_float()

func _on_accept_pressed() -> void:
	emit_signal("confirmed", Vector2(float(canvas_x.text), float(canvas_y.text)))
	_cleanup()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
