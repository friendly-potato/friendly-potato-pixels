extends "res://addons/friendly-potato-pixels/popups/base_dialog.gd"

onready var file_path_line_edit: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer/LineEdit
onready var file_path_browse_button: Button = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer/Browse

var dir := Directory.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	window_title = "Load File"
	
	file_path_line_edit.connect("text_changed", self, "_on_file_path_line_edit_text_changed")
	file_path_browse_button.connect("pressed", self, "_on_file_path_button_pressed")

	file_path_line_edit.text = main.save_path
	_on_file_path_line_edit_text_changed(file_path_line_edit.text)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_accept_pressed() -> void:
	emit_signal("confirmed", file_path_line_edit.text)
	_cleanup()

func _on_file_path_line_edit_text_changed(text: String) -> void:
	if text.is_abs_path():
		accept_button.disabled = not dir.file_exists(text)
	else:
		accept_button.disabled = true

func _on_file_path_button_pressed() -> void:
	_create_file_dialog(FileDialog.MODE_OPEN_FILE)

func _on_file_dialog_file_selected(text: String) -> void:
	file_path_line_edit.text = text
	_on_file_path_line_edit_text_changed(text)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
