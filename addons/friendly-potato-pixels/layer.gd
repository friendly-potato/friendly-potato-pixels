extends Node2D

# Main display and draw layer
onready var base_sprite: Sprite = $BaseSprite
var base_image: Image

# Used moving and placing the image
onready var transform_sprite: Sprite = $TransformSprite
var transform_image: Image

var input_image: Image
var input_canvas_size: Vector2 # Never actually null
var input_color: Color # Never actually null

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	if input_image != null:
		base_image = input_image
	else:
		base_image = Image.new()
		base_image.create(input_canvas_size.x, input_canvas_size.y, false, Image.FORMAT_RGBA8)
		base_image.fill(input_color)
	
	base_sprite.texture = _create_texture(base_image)
	base_image.lock()

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
