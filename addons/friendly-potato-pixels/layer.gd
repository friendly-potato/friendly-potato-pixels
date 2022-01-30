extends Node2D

const CLEAR_COLOR := Color(0.0, 0.0, 0.0, 0.0)

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

# A clear image we draw to first until we are finished drawing. The results
# are then batch drawn to the base_image. The new/old colors are stored for
# undo/redo
onready var predraw_sprite: Sprite = $PredrawSprite
var predraw_image: Image

# Main display and draw layer. The layer that's used when creating a
# composite image
onready var base_sprite: Sprite = $BaseSprite
var base_image: Image

# Used moving and placing the image. Like the predraw image except the commit
# timing depends on factors other than just releasing the draw button
onready var transform_sprite: Sprite = $TransformSprite
var transform_image: Image

var input_image: Image
var input_canvas_size: Vector2 # Never actually null
var input_color: Color # Never actually null

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	logger.setup(self)
	
	if input_image != null:
		base_image = input_image
	else:
		base_image = Image.new()
		base_image.create(input_canvas_size.x, input_canvas_size.y, false, Image.FORMAT_RGBA8)
		base_image.fill(input_color)
	
	base_sprite.texture = _create_texture(base_image)
	base_image.lock()

	predraw_image = base_image.duplicate()
	predraw_image.fill(CLEAR_COLOR)

	predraw_sprite.texture = _create_texture(predraw_image)
	predraw_image.lock()

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

static func _create_texture(img: Image) -> ImageTexture:
	var tex := ImageTexture.new()
	tex.create_from_image(img, 0)
	
	return tex

###############################################################################
# Public functions                                                            #
###############################################################################

func predraw_commit() -> void:
	pass

func transform_commit() -> void:
	pass
