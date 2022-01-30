extends WindowDialog

signal confirmed(data)

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

onready var accept_button: Button = $VBoxContainer/ConfirmButtons/Accept
onready var cancel_button: Button = $VBoxContainer/ConfirmButtons/Cancel

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	logger.setup(self)
	
	accept_button.connect("pressed", self, "_on_accept_pressed")
	
	cancel_button.connect("pressed", self, "_on_hide")
	connect("hide", self, "_on_hide")
	connect("popup_hide", self, "_on_hide")
	
	popup_centered_ratio(0.5)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_accept_pressed() -> void:
	emit_signal("confirmed", null)
	queue_free()

func _on_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
