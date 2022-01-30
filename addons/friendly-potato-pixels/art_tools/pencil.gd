extends "res://addons/friendly-potato-pixels/art_tools/base_brush.gd"

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	pass

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func paint(pos: Vector2, image: Image) -> Reference:
	var r: Reference = BLIT.new()
	
	if size == 1:
		if _is_valid_pos(pos.x, pos.y, image.get_width() - 1, image.get_height() - 1):
			r.position_data.append(pos)
	elif size % 2 == 0: # Offset to bottom right hand corner
		var half_size := size / 2
		
		var top_left := -Vector2(half_size, half_size)
		_fill_square(top_left + pos, r.position_data, image.get_width() - 1, image.get_height() - 1)
	else: # No offset
		var half_floored_size := floor(size / 2)
		
		var top_left := -Vector2(half_floored_size, half_floored_size)
		_fill_square(top_left + pos, r.position_data, image.get_width() - 1, image.get_height() - 1)
	
	return r
