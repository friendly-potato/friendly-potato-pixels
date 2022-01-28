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

const CACHE_FOLDER_NAME := "FriendlyPotatoPixels"
var cache_path := "%s/%s" % [OS.get_cache_dir(), CACHE_FOLDER_NAME]

var last_file_path := ""
var current_file_path := ""

var is_registered := false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	if clear_cache() != OK:
		printerr("Unable to clear cache on startup")

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

# TODO unused?
static func _create_cache_folder(path: String) -> int:
	var dir := Directory.new()
	if not dir.dir_exists(path):
		return dir.make_dir(path)
	return OK

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(n: Node) -> void:
	if not is_registered:
		main = n
		connect("image_loaded", n, "_on_image_loaded")
		
		is_registered = true

func save_input_event(event: InputEvent) -> int:
	var r: int = OK
	# TODO Prevents race condition, there's a better solution I think
	if main != null and not main.visible:
		return r
	if not event is InputEventKey:
		return r
	
	if (event.control == true and event.scancode == KEY_S and event.pressed):
		r = save_image()
	
	return r

func open_item(text: String) -> int:
	"""
	Opens an image for drawing. Stores the original in the cache if it's not already cached.
	
	Checks the image extension to make sure it can actually be opened. Updates the last/current
	file paths implicitly.
	
	Returns:
		OK if the image was successfully loaded
		Some error code otherwise
	"""
	var r: int = OK
	if text.get_extension().to_lower() in VALID_EXTENSIONS:
		var image := Image.new()
		
		r = image.load(text)
		if r != OK:
			main.logger.error("Unable to open image for reading at path %s" % text)
			return r
		
		var dir := Directory.new()
		var file_name := text.get_file()
		if not dir.file_exists("%s/%s" % [cache_path, file_name]):
			r = image.save_png("%s/%s" % [cache_path, file_name])
			# Prevent user from destructively editing an image without a backup
			if r != OK:
				main.logger.error("Unable to save png to cache %s" % cache_path)
				return r
		
		last_file_path = current_file_path
		current_file_path = text
		
		emit_signal("image_loaded", image)
	
	return r

func open_cached_image() -> int:
	var r: int = OK
	var image := Image.new()
	
	var path := "%s/%s" % [cache_path, current_file_path.get_file()]
	r = image.load(path)
	if r != OK:
		main.logger.error("Unable to open cached image for reading at path %s" % path)
		return r
	
	emit_signal("image_loaded", image)
	
	return r

func save_image(current: bool = true) -> int:
	var r: int = OK
	
	var path := current_file_path if current else last_file_path
	if path.empty():
		return r
	
	var file_name := path.get_file()
	
	main.logger.info("Saving file at path %s" % path)
	
	main.image.unlock()
	
	r = main.image.save_png(path)
	if r != OK:
		main.logger.error("Unable to save png at path %s" % path)
		main.image.lock()
		return r
	
	main.image.lock()
	
	main.logger.info("Successfully saved file at path %s" % path)
	
	return r

func clear_cache() -> int:
	var dir := Directory.new()
	if not dir.dir_exists(cache_path):
		return dir.make_dir(cache_path)
	
	var r: int = OK
	
	r = dir.open(cache_path)
	if r != OK:
		return r
	
	r = dir.list_dir_begin(true, false)
	if r != OK:
		return r
	
	var files_to_delete := []
	
	var file_name: String = dir.get_next()
	while file_name != "":
		files_to_delete.append(file_name)
		file_name = dir.get_next()
	
	for f in files_to_delete:
		r = dir.remove("%s/%s" % [cache_path, f])
		if r != OK:
			return r
	
	return r
