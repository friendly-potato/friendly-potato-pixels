extends Reference

enum ActionType {
	NONE = 0,
	BLIT,
	TRANSFORM
}

var main: Node

# An action can only contain one data type
# This is how we know how to undo an action
# Should not be manually set
var type: int = ActionType.NONE

# Stores 1 to many blits
var blit_data := [] # Blit

# Stores exactly 1 transform
class TransformData:
	var _canvas_size := Vector2.ZERO
	var _initial := PoolByteArray([])
	var _new := PoolByteArray([])

	func _init(c: Vector2, i: PoolByteArray, n: PoolByteArray) -> void:
		_canvas_size = c
		_initial = i
		_new = n

var transform_data: TransformData

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func add_blit(blit: Reference) -> void:
	if type == ActionType.NONE:
		type = ActionType.BLIT
	elif type != ActionType.NONE and type != ActionType.BLIT:
		main.logger.error("Tried add blit when action type wasn't blit")
		return
	
	blit_data.append(blit)

func _add_transform_data(
		p_canvas_size: Vector2,
		initial_data: PoolByteArray,
		new_data: PoolByteArray) -> void:
	if type == ActionType.NONE:
		type = ActionType.TRANSFORM
	elif type != ActionType.NONE:
		main.logger.error("Tried to add transform data for invalid action type")
		return
	
	transform_data = TransformData.new(p_canvas_size, initial_data, new_data)
