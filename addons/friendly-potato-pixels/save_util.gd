extends Reference

signal image_loaded(image)

const VALID_EXTENSIONS := [
	"png",
	"jpg",
	"bmp",
	"webp",
	"tga"
]

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

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
	logger.setup(self)
	
	if clear_cache() != OK:
		printerr("Unable to clear cache on startup")

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

# TODO unused?
func _create_cache_folder(path: String) -> int:
	var dir := Directory.new()
	if not dir.dir_exists(path):
		if dir.make_dir(path) != OK:
			return main.ErrorCode.UNABLE_TO_CREATE_CACHE_DIRECTORY
	return OK

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(n: Node) -> void:
	if not is_registered:
		main = n
		# warning-ignore:return_value_discarded
		connect("image_loaded", n, "_on_image_loaded")
		
		is_registered = true

func save_input_event(event: InputEvent) -> int:
	# TODO Prevents race condition, there's a better solution I think
	if main != null and not main.visible:
		return OK
	if not event is InputEventKey:
		return OK
	
	if (event.control == true and event.scancode == KEY_S and event.pressed):
		return save_image()
	
	return OK

func open_image(text: String) -> int:
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
				logger.error("Unable to save png to cache %s" % cache_path)
				return r
		
		last_file_path = current_file_path
		current_file_path = text
		
		emit_signal("image_loaded", [image])
	
	return r

func open_cached_image() -> int:
	var image := Image.new()
	
	var path := "%s/%s" % [cache_path, current_file_path.get_file()]
	if image.load(path) != OK:
		logger.error("Unable to open cached image for reading at path %s" % path)
		return main.ErrorCode.UNABLE_TO_OPEN_CACHED_IMAGE
	
	emit_signal("image_loaded", image)
	
	return OK

func save_image(current: bool = true) -> int:
	var path := current_file_path if current else last_file_path
	if path.empty():
		return main.ErrorCode.SAVE_FILE_DOES_NOT_EXIST
	
	var file_name := path.get_file()
	
	logger.info("Saving file at path %s" % path)
	
	main.image().unlock()
	
	if main.image().save_png(path) != OK:
		logger.error("Unable to save png at path %s" % path)
		main.image().lock() # Relock the image anyways
		return main.ErrorCode.UNABLE_TO_SAVE_IMAGE
	
	main.image().lock()
	
	logger.info("Successfully saved file at path %s" % path)
	
	return OK

func clear_cache() -> int:
	var dir := Directory.new()
	if not dir.dir_exists(cache_path):
		return dir.make_dir(cache_path)
	
	if dir.open(cache_path) != OK:
		return main.ErrorCode.UNABLE_TO_OPEN_CACHED_IMAGE
	
	if dir.list_dir_begin(true, false) != OK:
		return main.ErrorCode.UNABLE_TO_ITERATE_OVER_CACHE
	
	var files_to_delete := []
	
	var file_name: String = dir.get_next()
	while file_name != "":
		files_to_delete.append(file_name)
		file_name = dir.get_next()
	
	for f in files_to_delete:
		if dir.remove("%s/%s" % [cache_path, f]) != OK:
			return main.ErrorCode.UNABLE_TO_REMOVE_CACHE_ITEM
	
	return OK
