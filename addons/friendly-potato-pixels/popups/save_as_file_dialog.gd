extends "res://addons/friendly-potato-pixels/popups/base_dialog.gd"

const PNG_FORMAT := "png"

onready var file_path_line_edit: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer/LineEdit
onready var file_path_browse_button: Button = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer/Browse

var dir := Directory.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	window_title = "Save as File"
	
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
		accept_button.disabled = not _is_png_format(text)
	else:
		accept_button.disabled = true

func _on_file_path_button_pressed() -> void:
	_create_file_dialog(FileDialog.MODE_SAVE_FILE)

func _on_file_dialog_file_selected(text: String) -> void:
	if not _is_png_format(text):
		text = "%s.%s" % [text, PNG_FORMAT]
	file_path_line_edit.text = text
	_on_file_path_line_edit_text_changed(text)

###############################################################################
# Private functions                                                           #
###############################################################################

func _is_png_format(text: String) -> bool:
	return text.get_extension().to_lower() == PNG_FORMAT

###############################################################################
# Public functions                                                            #
###############################################################################
