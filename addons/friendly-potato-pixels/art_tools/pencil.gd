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

func paint(pos: Vector2) -> Reference:
	var r: Reference = BLIT.new()
	
	if size == 0:
		r.data.append(pos)
	elif size % 2 == 0: # Offset to bottom right hand corner
		var top_left := Vector2(size / 2, size / 2)
		var top_right := Vector2(top_left.x + size - 1, top_left.y)
		var bot_left := Vector2(top_left.x, top_left.y + size - 1)
		var bot_right := Vector2(top_right.x, bot_left.y)
	else: # No offset
		pass
	
	return r
