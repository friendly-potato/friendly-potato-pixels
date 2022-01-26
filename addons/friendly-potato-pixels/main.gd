extends Control

const INITIAL_CANVAS_SCALE: float = 10.0
const ZOOM_INCREMENT := Vector2(0.4, 0.4)

var plugin: Node
var undo_redo

var toolbar: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

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
var primary_color := Color.black
var secondary_color := Color.white

var brush: Reference = load("res://addons/friendly-potato-pixels/art_tools/pencil.gd").new()
var brush_size: int = 0

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	if not Engine.editor_hint:
		var setup_util: Object = load("res://addons/friendly-potato-pixels/standalone/setup_util.gd").new()
		
		plugin = setup_util.create_dummy_plugin()
		
		var control: Control = setup_util.setup_toolbar_control()
		add_child(control)
		
		toolbar = setup_util.create_toolbar()
		control.add_child(toolbar)
		
		setup_util.free()
	
	undo_redo = plugin.get_undo_redo()
	
	# When starting as a plugin, prevent race condition on startup
	while toolbar == null:
		yield(get_tree(), "idle_frame")
	toolbar.register_main(self)
	
	# Zooming is handled by the viewport container, positioning is handled by the canvas
	viewport_container.rect_pivot_offset = viewport.size / 2
	viewport_container.rect_scale = (INITIAL_CANVAS_SCALE * ZOOM_INCREMENT)
	
	canvas.global_position = viewport.size / 2
	
	# Shift canvas children over since the sprite is intentionally not centered
	sprite.position.x -= sprite.texture.get_width() / 2
	sprite.position.y -= sprite.texture.get_height() / 2
	cells.position = sprite.position
	
	image = sprite.texture.get_data().duplicate()
	image.lock()
	
	logger.info("Friendly Potato Pixels started")

func _process(delta: float) -> void:
	if is_drawing:
		var pos: Vector2 = cells.world_to_map(cells.to_local(viewport.get_mouse_position() / viewport_container.rect_scale))
		if ((pos.x < 0 or pos.x >= image.get_width())
				or (pos.y < 0 or pos.y >= image.get_height())):
			return
		
		var blit: Reference = brush.paint(pos)
		# blit
		
		image.set_pixel(pos.x, pos.y, primary_color)
		for i in brush_size:
			image.set_pixel(pos.x + i + 1, pos.y + i + 1, primary_color)
			image.set_pixel(pos.x + i, pos.y + i + 1, primary_color)
			image.set_pixel(pos.x + i + 1, pos.y + i, primary_color)
		var tex := ImageTexture.new()
		tex.create_from_image(image, 0)
		sprite.texture = tex

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if clicks_to_ignore > 0:
					clicks_to_ignore -= 1
				# TODO tool switching done here
				else:
					is_drawing = event.pressed
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

func _exit_tree() -> void:
	if not Engine.editor_hint:
		plugin.queue_free()
	
	logger.info("Friendly Potato Pixels going away")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_pencil_pressed() -> void:
	pass

func _on_smart_brush_pressed() -> void:
	pass

func _on_color_changed(color: Color) -> void:
	primary_color = color

func _on_color_dropper_pressed() -> void:
	clicks_to_ignore += 1
	is_drawing = false

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
