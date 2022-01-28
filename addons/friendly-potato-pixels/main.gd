extends Control

signal message_sent(text)

const SETUP_UTIL_PATH: String = "res://addons/friendly-potato-pixels/standalone/setup_util.gd"
const NEW_FILE_POPUP_PATH: String = "res://addons/friendly-potato-pixels/new_file_dialog.tscn"

const INITIAL_CANVAS_SCALE: float = 10.0
const ZOOM_INCREMENT := Vector2(0.4, 0.4)

const MAX_ALPHA: int = 255

var plugin: Node
var undo_redo

var toolbar: Node
var menu_bar: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()
var save_util = load("res://addons/friendly-potato-pixels/save_util.gd").new()

onready var viewport_container: ViewportContainer = $ViewportContainer
onready var viewport: Viewport = $ViewportContainer/Viewport
onready var canvas: Node2D = $ViewportContainer/Viewport/Canvas
onready var sprite: Sprite = $ViewportContainer/Viewport/Canvas/Sprite
onready var cells: TileMap = $ViewportContainer/Viewport/Canvas/Cells

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
	image = sprite.texture.get_data().duplicate()
	_setup()
	image.lock()
	
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
				viewport_container.rect_scale += ZOOM_INCREMENT
			BUTTON_WHEEL_DOWN:
				viewport_container.rect_scale -= ZOOM_INCREMENT
	elif event is InputEventMouseMotion:
		if move_canvas:
			canvas.global_position += event.relative / viewport_container.rect_scale
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
	viewport_container.rect_pivot_offset = viewport.size / 2
	viewport_container.rect_scale = (INITIAL_CANVAS_SCALE * ZOOM_INCREMENT)
	
	canvas.global_position = viewport.size / 2

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
	image.unlock()
	image = i
	image.lock()
	
	var tex := ImageTexture.new()
	tex.create_from_image(image, 0)
	sprite.texture = tex
	
	_setup()

###############################################################################
# Private functions                                                           #
###############################################################################

func _setup() -> void:
	# Shift canvas children over since the sprite is intentionally not centered
	sprite.position = Vector2.ZERO
	
	sprite.position.x -= sprite.texture.get_width() / 2
	sprite.position.y -= sprite.texture.get_height() / 2
	cells.position = sprite.position
	
	toolbar.register_main(self)
	menu_bar.register_main(self)
	save_util.register_main(self)

func _blit() -> void:
	var pos: Vector2 = cells.world_to_map(cells.to_local(viewport.get_mouse_position() / viewport_container.rect_scale))
	if pos == last_pixel_pos:
		return
	last_pixel_pos = pos
		
	var blit: Object = brush.paint(pos, image)
	
	# TODO additional blit operations
	
	for vec in blit.position_data:
		var pix_color := image.get_pixelv(vec)
		
		image.set_pixelv(vec, pix_color.blend(primary_color))
	
	blit.free()
	
	var tex := ImageTexture.new()
	tex.create_from_image(image, 0)
	sprite.texture = tex

func _create_file_select() -> FileDialog:
	var r := FileDialog.new()
	
	return r

###############################################################################
# Public functions                                                            #
###############################################################################

func open_item(path: String) -> void:
	save_util.open_item(path)

func save_item() -> void:
	save_util.save_image()
