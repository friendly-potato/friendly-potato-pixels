extends Control

signal message_sent(text)

const SETUP_UTIL_PATH: String = "res://addons/friendly-potato-pixels/standalone/setup_util.gd"
const NEW_FILE_POPUP_PATH: String = "res://addons/friendly-potato-pixels/new_file_dialog.tscn"
const LAYER_PATH: String = "res://addons/friendly-potato-pixels/layer.tscn"

const INITIAL_CANVAS_SCALE: float = 10.0
const ZOOM_INCREMENT := Vector2(0.4, 0.4)

const MAX_ALPHA: int = 255

const DEFAULT_LAYER_COLOR := Color.white
const DEFAULT_LAYER_CANVAS_SIZE := Vector2(32, 32)

var plugin: Node
var undo_redo

var toolbar: Node
var menu_bar: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()
var save_util = load("res://addons/friendly-potato-pixels/save_util.gd").new()

onready var viewport_container: ViewportContainer = $ViewportContainer
onready var viewport: Viewport = $ViewportContainer/Viewport
onready var canvas: Node2D = $ViewportContainer/Viewport/Canvas
onready var cells: TileMap = $ViewportContainer/Viewport/Canvas/Cells

onready var layers: Node2D = $ViewportContainer/Viewport/Canvas/Layers
var current_layer: Node2D

# The thing actually being drawn to
var image: Image

# Control data
var move_canvas := false
var is_drawing := false
var clicks_to_ignore: int = 0

# Art data
var last_pixel_pos := Vector2(-1, -1)
var primary_color
var secondary_color := Color.white

var brush: Reference = load("res://addons/friendly-potato-pixels/art_tools/pencil.gd").new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	"""
	Order of initialization is very important.
	
	Must follow:
		1. Plugin
		2. Wait for toolbar to instance
		3. Image
		4. Toolbar
		5. Menu bar
	"""
	if not Engine.editor_hint:
		var setup_util: Object = load(SETUP_UTIL_PATH).new()
		
		plugin = setup_util.create_dummy_plugin()
		add_child(plugin)
		
		plugin.main = self
		
		var tb_control: Control = setup_util.setup_toolbar_control()
		add_child(tb_control)
		
		toolbar = setup_util.create_toolbar()
		tb_control.add_child(toolbar)
		
		var mb_control: Control = setup_util.setup_menu_bar_control()
		add_child(mb_control)
		
		menu_bar = setup_util.create_menu_bar()
		mb_control.add_child(menu_bar)
		
		setup_util.free()
	
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_on_screen_resized()
	
	undo_redo = plugin.get_undo_redo()
	
	# When starting as a plugin, prevent race condition on startup
	while toolbar == null and menu_bar == null:
		yield(get_tree(), "idle_frame")
	
	# This order is intentional so we can access the image data before locking it for drawing
	var img := Image.new()
	img.load("res://icon.png")
	
	current_layer = _create_layer([img.get_data(), img.get_size()])
	layers.add_child(current_layer)
	_setup()
	
	logger.info("Friendly Potato Pixels started")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if clicks_to_ignore > 0:
					clicks_to_ignore -= 1
				else:
					is_drawing = event.pressed
					_blit()
			BUTTON_RIGHT:
				pass
			BUTTON_MIDDLE:
				move_canvas = event.pressed
			BUTTON_WHEEL_UP:
				viewport.canvas_transform.x *= 1.1
				viewport.canvas_transform.y *= 1.1
			BUTTON_WHEEL_DOWN:
				viewport.canvas_transform.x /= 1.1
				viewport.canvas_transform.y /= 1.1
				
	elif event is InputEventMouseMotion:
		if move_canvas:
			viewport.canvas_transform = viewport.canvas_transform.translated(Vector2(event.relative.x, event.relative.y) / viewport.canvas_transform.get_scale())
		if is_drawing:
			_blit()

func _exit_tree() -> void:
	if not Engine.editor_hint:
		plugin.queue_free()
	
	logger.info("Friendly Potato Pixels going away")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_screen_resized() -> void:
	viewport.canvas_transform.origin = viewport.size / 2
	viewport.canvas_transform.x *= INITIAL_CANVAS_SCALE
	viewport.canvas_transform.y *= INITIAL_CANVAS_SCALE

# Toolbar

func _on_pencil_pressed() -> void:
	pass

func _on_smart_brush_pressed() -> void:
	pass

func _on_brush_size_changed(value: int) -> void:
	brush.size = value

func _on_color_changed(color: Color) -> void:
	primary_color = color

func _on_color_dropper_pressed() -> void:
	clicks_to_ignore += 1
	is_drawing = false

# Menu bar

func _on_new_pressed() -> void:
	var popup = load(NEW_FILE_POPUP_PATH).instance()
	plugin.inject_tool(popup)
	
	popup.connect("confirmed", self, "_on_new_file_confirmed")
	
	plugin.get_editor_interface().get_editor_viewport().add_child(popup)

func _on_new_file_confirmed(canvas_size: Vector2) -> void:
	var img := Image.new()
	img.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.white)
	
	_on_image_loaded(img)

func _on_save_pressed() -> void:
	save_item()

func _on_save_as_pressed() -> void:
	logger.error("Not yet implemented")

func _on_load_pressed() -> void:
	logger.error("Not yet implemented")

func _on_revert_pressed() -> void:
	save_util.open_cached_image()

func _on_image_loaded(i: Image) -> void:
	for layer in layers.get_children():
		layer.queue_free()
	
	current_layer = _create_layer([i.get_data()])
	layers.add_child(current_layer)
	
	_setup()

###############################################################################
# Private functions                                                           #
###############################################################################

func _setup() -> void:
	# Shift canvas children over since the sprite is intentionally not centered
	layers.position = Vector2.ZERO
	
	layers.position.x -= float(current_layer.base_sprite.texture.get_width()) / 2
	layers.position.y -= float(current_layer.base_sprite.texture.get_height()) / 2
	cells.position = layers.position
	
	toolbar.register_main(self)
	menu_bar.register_main(self)
	save_util.register_main(self)

func _blit() -> void:
	var can_val = (viewport.get_mouse_position() - (viewport.size / 2) + ((viewport.size / 2) - viewport.canvas_transform.origin)) / viewport.canvas_transform.get_scale()
	var pos: Vector2 = cells.world_to_map(cells.to_local(can_val))
	if pos == last_pixel_pos:
		return
	last_pixel_pos = pos
	
	var blit: Object = brush.paint(pos, current_layer.base_image)
	
	# TODO additional blit operations
	
	for vec in blit.position_data:
		var pix_color: Color = current_layer.base_image.get_pixelv(vec)
		
		current_layer.base_image.set_pixelv(vec, pix_color.blend(primary_color))
	
	blit.free()
	
	var tex := ImageTexture.new()
	tex.create_from_image(current_layer.base_image, 0)
	current_layer.base_sprite.texture = tex

func _create_file_select() -> FileDialog:
	var r := FileDialog.new()
	
	# TODO
	logger.trace("stubbed")
	
	return r

func _create_layer(data: Array = []) -> Node2D:
	var layer: Node2D = load(LAYER_PATH).instance()
	plugin.inject_tool(layer)
	
	var initial_color := DEFAULT_LAYER_COLOR
	var initial_canvas_size := DEFAULT_LAYER_CANVAS_SIZE
	var initial_image: Image
	var initial_image_data
	
	if not data.empty():
		for d in data:
			match typeof(d):
				TYPE_COLOR:
					initial_color = d
				TYPE_VECTOR2:
					initial_canvas_size = d
				TYPE_RAW_ARRAY:
					initial_image_data = d
				_:
					logger.error("Unrecognized param for layer: %s" % str(d))
		
	# We have image data so create an input image for the layer
	# Don't check for initial canvas size since that should always be provided
	# If it's not, then I'm not sure what's going to happen
	if initial_image_data != null:
		initial_image = Image.new()
		initial_image.create_from_data(initial_canvas_size.x, initial_canvas_size.y,
				false, Image.FORMAT_RGBA8, initial_image_data)
		layer.input_image = initial_image
	else:
		layer.input_canvas_size = initial_canvas_size
		layer.input_color = initial_color
	
	return layer

###############################################################################
# Public functions                                                            #
###############################################################################

func open_item(path: String) -> void:
	save_util.open_item(path)

func save_item() -> void:
	save_util.save_image()
