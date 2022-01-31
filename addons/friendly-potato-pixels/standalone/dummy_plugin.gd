extends Node

var main: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

var _editor_interface
var _undo_redo

func _init() -> void:
	logger.setup(self)

func _input(event: InputEvent) -> void:
	# Plugins can hook into the editor's built-in save functionality
	# We can't, so we have to poll for the expected input
	if (event is InputEventKey and event.pressed):
		if event.control:
			if event.shift and event.scancode == KEY_Z:
				_undo_redo.redo()
			else:
				match event.scancode:
					KEY_S:
						main.handle_error(main.save_image())
					KEY_Z:
						_undo_redo.undo()
					KEY_Y:
						_undo_redo.redo()

func inject_tool(_node: Node) -> void:
	"""
	An empty function that mocks the editor-only functionality of adding `tool` to the
	top of all SceneTree scripts when loaded as a plugin
	"""
	pass

func cleanup() -> void:
	if _editor_interface != null:
		_editor_interface.cleanup()
		_editor_interface.free()
	if _undo_redo != null:
		_undo_redo.cleanup()
		_undo_redo.free()

# TODO I don't remember why I made this Object and not reference q.q
class Dummy extends Object:
	var main: Node

	var logger
	
	func _init(n: Node, p_logger) -> void:
		main = n
		logger = p_logger
	
	func cleanup() -> void:
		for i in get_property_list():
			if not i.name in ["Object", "script", "Script Variables", "main"]:
				var prop = get(i.name)
				match typeof(prop):
					TYPE_OBJECT:
						_try_free_object(prop)
					TYPE_ARRAY:
						for j in prop:
							match typeof(j):
								TYPE_OBJECT:
									_try_free_object(j)
								TYPE_ARRAY:
									_try_cleanup_array(j)
								TYPE_DICTIONARY:
									_try_cleanup_dictionary(j)
								_:
									# It's a primitive, do nothing
									pass
	
	func _try_free_object(obj: Object) -> void:
		"""
		Check to see if the object is something that should be manually freed. Objects and nodes
		are things that should be manually freed. References, which exist between Objects and
		nodes, should not be freed.
		
		Explodes if an engine primitive is passed.
		"""
		if obj is Reference:
			return
		if obj.has_method("free"):
			obj.free()
	
	func _try_cleanup_array(arr: Array) -> void:
		"""
		Runs through the array and recursively tries to free all eligible objects
		"""
		for i in arr:
			match typeof(i):
				TYPE_OBJECT:
					_try_free_object(i)
				TYPE_ARRAY:
					_try_cleanup_array(i)
				TYPE_DICTIONARY:
					_try_cleanup_dictionary(i)
				_:
					# It's a primitive, do nothing
					pass
	
	func _try_cleanup_dictionary(dict: Dictionary) -> void:
		"""
		Runs the the dictionary's keys/values and recursively tries to free all eligble objects
		"""
		for key in dict.keys():
			var val = dict[key]
			for i in [key, val]:
				match typeof(i):
					TYPE_OBJECT:
						_try_free_object(i)
					TYPE_ARRAY:
						_try_cleanup_array(i)
					TYPE_DICTIONARY:
						_try_cleanup_dictionary(i)
					_:
						# It's a primitive, do nothing
						pass

class DummyEditorInterface extends Dummy:
	func _init(n: Node, logger).(n, logger) -> void:
		pass
	
	func get_editor_viewport():
		"""
		Instead of providing the actual editor viewport, just give back the main scene.
		
		It's not exactly the same functionality, but it's close enough. Main should only be
		calling this to instance popups anyways.
		"""
		return main

func get_editor_interface():
	if _editor_interface == null:
		_editor_interface = DummyEditorInterface.new(main, logger)
	return _editor_interface

class DummyUndoRedo extends Dummy:
	"""
	This isn't really a dummy since this actually implements undo/redo functionality.
	"""

	class ActionDatum:
		var action_name := ""

		var do_obj: WeakRef
		var do_method_name: String
		var do_method_data

		var undo_obj: WeakRef
		var undo_method_name: String
		var undo_method_data

	var action_data_pointer: int = -1
	var action_data := []

	var current_action: ActionDatum
	
	func _init(n: Node, logger).(n, logger) -> void:
		pass
	
	func create_action(text: String, _merge_mode: int = 0) -> void:
		current_action = ActionDatum.new()
		current_action.action_name = text
	
	func add_do_method(object: Object, method_name: String, param = null) -> void:
		current_action.do_obj = weakref(object)
		current_action.do_method_name = method_name
		current_action.do_method_data = param
	
	func add_undo_method(object: Object, method_name: String, param = null) -> void:
		current_action.undo_obj = weakref(object)
		current_action.undo_method_name = method_name
		current_action.undo_method_data = param
	
	func add_do_property(object: Object, property: String, value) -> void:
		# TODO stub
		pass
	
	func add_undo_property(object: Object, property: String, value) -> void:
		# TODO stub
		pass
	
	func commit_action() -> void:
		logger.debug(current_action.action_name)

		current_action.do_obj.get_ref().call(
			current_action.do_method_name,
			current_action.do_method_data
		)
		
		while action_data.size() - 1 > action_data_pointer:
			action_data.pop_back()

		action_data.append(current_action)
		action_data_pointer += 1
		print(action_data_pointer)

	func undo() -> void:
		if action_data.empty():
			return
		action_data[action_data_pointer].undo_obj.get_ref().call(
			action_data[action_data_pointer].undo_method_name,
			action_data[action_data_pointer].undo_method_data
		)
		action_data_pointer -= 1
		print(action_data_pointer)
		if action_data_pointer < -1:
			action_data_pointer = -1
			print("aborting, resetting to %d" % action_data_pointer)
			return

	func redo() -> void:
		action_data_pointer += 1
		print(action_data_pointer)
		if action_data_pointer > action_data.size() - 1:
			action_data_pointer = action_data.size() - 1
			print("aborting, resetting to %d" % action_data_pointer)
			return
		action_data[action_data_pointer].do_obj.get_ref().call(
			action_data[action_data_pointer].do_method_name,
			action_data[action_data_pointer].do_method_data
		)

func get_undo_redo():
	if _undo_redo == null:
		_undo_redo = DummyUndoRedo.new(main, logger)
	return _undo_redo
