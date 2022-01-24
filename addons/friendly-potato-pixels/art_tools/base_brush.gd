extends Reference

const BLIT: GDScript = preload("res://addons/friendly-potato-pixels/art_tools/blit.gd")

var size: int = 1

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

func paint(_pos: Vector2) -> Reference:
	var r := BLIT.new()
	
	return r
