extends Reference

const BLIT: GDScript = preload("res://addons/friendly-potato-pixels/art_tools/blit.gd")

var size: int = 1

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

static func _is_valid_pos(x: int, y: int, w: int, h: int) -> bool:
	if (x < 0 or x > w or y < 0 or y > h):
		return false
	return true

func _fill_square(top_left: Vector2, positions: Array, max_w: int, max_h: int):
	var bot_right := Vector2(top_left.x + size - 1, top_left.y + size - 1)

	for x in range(top_left.x, bot_right.x + 1):
		for y in range(top_left.y, bot_right.y + 1):
			if not _is_valid_pos(x, y, max_w, max_h):
				continue
			positions.append(Vector2(x, y))

###############################################################################
# Public functions                                                            #
###############################################################################

func paint(_pos: Vector2, _image: Image) -> Object:
	var r: Object = BLIT.new()

	print("unreachable")
	
	return r
