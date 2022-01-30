extends WindowDialog

signal confirmed(data)

const POPUP_SIZE_RATIO: float = 0.5

var main: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

onready var accept_button: Button = $VBoxContainer/ConfirmButtons/Accept
onready var cancel_button: Button = $VBoxContainer/ConfirmButtons/Cancel

var file_dialog: FileDialog

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	logger.setup(self)
	
	# warning-ignore:return_value_discarded
	accept_button.connect("pressed", self, "_on_accept_pressed")
	
	# warning-ignore:return_value_discarded
	cancel_button.connect("pressed", self, "_on_hide")
	# warning-ignore:return_value_discarded
	connect("hide", self, "_on_hide")
	# warning-ignore:return_value_discarded
	connect("popup_hide", self, "_on_hide")
	
	popup_centered_ratio(POPUP_SIZE_RATIO)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_accept_pressed() -> void:
	logger.error("Not yet implemented")
	_cleanup()

func _on_hide() -> void:
	_cleanup()

#region File dialog

func _on_file_dialog_file_selected(_text: String) -> void:
	logger.error("Not yet implemented")

func _on_file_dialog_hide() -> void:
	file_dialog.queue_free()

#endregion

###############################################################################
# Private functions                                                           #
###############################################################################

func _cleanup() -> void:
	"""
	Wrapper for subclasses to further implement if there are other resources to cleanup
	"""
	queue_free()

func _create_file_dialog(fd_mode: int) -> void:
	if fd_mode != FileDialog.MODE_OPEN_FILE and fd_mode != FileDialog.MODE_SAVE_FILE:
		logger.error("Unrecognized FileDialog mode %d" % fd_mode)
		return
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = fd_mode
	if fd_mode == FileDialog.MODE_SAVE_FILE:
		file_dialog.add_filter("*.png; PNG Images")
	file_dialog.current_dir = main.save_path
	
	# warning-ignore:return_value_discarded
	file_dialog.connect("file_selected", self, "_on_file_dialog_file_selected")
	# warning-ignore:return_value_discarded
	file_dialog.connect("dir_selected", self, "_on_file_dialog_file_selected")
	# warning-ignore:return_value_discarded
	file_dialog.connect("popup_hide", self, "_on_file_dialog_hide")
	# warning-ignore:return_value_discarded
	file_dialog.connect("hide", self, "_on_file_dialog_hide")
	
	add_child(file_dialog)
	file_dialog.popup_centered_ratio(POPUP_SIZE_RATIO)

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(n: Node) -> void:
	main = n
