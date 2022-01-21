extends Control

const INITIAL_CANVAS_SCALE: float = 8.0

var plugin: Node
var undo_redo

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

onready var viewport: Viewport = $ViewportContainer/Viewport
onready var canvas: Node2D = $ViewportContainer/Viewport/Canvas
onready var sprite: Sprite = $ViewportContainer/Viewport/Canvas/Sprite
onready var cells: TileMap = $ViewportContainer/Viewport/Canvas/Cells

var image: Image

var move_canvas := false
var is_drawing := false
var clicks_to_ignore: int = 0

var primary_color := Color.black
var secondary_color := Color.white

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	if not Engine.editor_hint:
		plugin = load("res://addons/friendly-potato-pixels/dummy_plugin.gd").new()
	undo_redo = plugin.get_undo_redo()
	
	$Tools/VBoxContainer/ColorPicker.connect("color_changed", self, "_on_color_changed")
	$Tools/VBoxContainer/ColorPicker.get_child(1).get_child(1).connect("pressed", self, "_on_color_dropper_pressed")
	
	canvas.global_position = viewport.size / 2
	canvas.scale *= INITIAL_CANVAS_SCALE
	
	image = sprite.texture.get_data().duplicate()
	image.lock()
	
	logger.info("Friendly Potato Pixels started")

func _process(delta: float) -> void:
	if is_drawing:
		var pos: Vector2 = cells.world_to_map(cells.to_local(viewport.get_mouse_position()))
		# TODO this will break on images that aren't even height/width
		pos.x += image.get_width() / 2
		pos.y += image.get_height() / 2
		image.set_pixelv(pos, primary_color)
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
				canvas.scale *= 1.1
			BUTTON_WHEEL_DOWN:
				canvas.scale *= 0.9
	elif event is InputEventMouseMotion:
		if move_canvas:
			canvas.global_position += event.relative

func _exit_tree() -> void:
	if not Engine.editor_hint:
		plugin.queue_free()
	
	logger.info("Friendly Potato Pixels going away")

###############################################################################
# Connections                                                                 #
###############################################################################

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
