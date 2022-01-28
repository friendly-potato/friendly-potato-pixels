extends Reference

signal image_loaded(image)

const VALID_EXTENSIONS := [
	"png",
	"jpg",
	"bmp",
	"webp",
	"tga"
]

var main: Node

var last_file_path: String = ""
var current_file_path: String = ""

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	pass

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

func _save_to_file() -> void:
	pass

func _save_to_cache() -> void:
	pass

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(n: Node) -> void:
	main = n
	connect("image_loaded", n, "_on_image_loaded")

func handle_save_input_event(event: InputEvent) -> void:
	if not main.visible:
		return
	if not event is InputEventKey:
		return
	
	if (event.control == true and event.scancode == KEY_S and event.pressed):
		handle_save_image()

func handle_open_item(text: String) -> void:
	if text.get_extension().to_lower() in VALID_EXTENSIONS:
		var image := Image.new()
		if image.load(text) != OK:
			main.logger.error("Unable to open image for reading at path %s" % text)
			return
		
		last_file_path = current_file_path
		current_file_path = text
		emit_signal("image_loaded", image)

func handle_save_image(current: bool = true) -> void:
	var path: String = current_file_path if current else last_file_path
	
	if path.empty():
		return
	
	main.logger.info("Saving file at path %s" % path)
	
	main.image.unlock()
	
	if main.image.save_png(path) != OK:
		main.logger.error("Unable to save png at path %s" % path)
		main.image.lock()
		return
	
	main.image.lock()
	
	main.logger.info("Successfully saved file at path %s" % path)
