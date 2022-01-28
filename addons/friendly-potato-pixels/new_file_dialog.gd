extends WindowDialog

signal confirmed(canvas_size)

onready var canvas_x: LineEdit = $VBoxContainer/CanvasSize/VBoxContainer/CanvasX/LineEdit
onready var canvas_y: LineEdit = $VBoxContainer/CanvasSize/VBoxContainer/CanvasY/LineEdit

onready var accept_button: Button = $VBoxContainer/ConfirmButtons/Accept
onready var cancel_button: Button = $VBoxContainer/ConfirmButtons/Cancel

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	canvas_x.connect("text_changed", self, "_on_canvas_size_changed")
	canvas_y.connect("text_changed", self, "_on_canvas_size_changed")
	
	accept_button.connect("pressed", self, "_on_accept_pressed")
	
	cancel_button.connect("pressed", self, "_on_hide")
	connect("hide", self, "_on_hide")
	connect("popup_hide", self, "_on_hide")
	
	popup_centered_ratio(0.5)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_canvas_size_changed(text: String) -> void:
	accept_button.disabled = not text.is_valid_float()

func _on_accept_pressed() -> void:
	emit_signal("confirmed", Vector2(float(canvas_x.text), float(canvas_y.text)))
	queue_free()

func _on_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
