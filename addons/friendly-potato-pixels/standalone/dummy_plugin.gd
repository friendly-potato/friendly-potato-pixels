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
			match event.scancode:
				KEY_S:
					main.handle_error(main.save_image())
				KEY_Z:
					_undo_redo

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
	
	func _init(n: Node) -> void:
		main = n
	
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
	func _init(n: Node).(n) -> void:
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
		_editor_interface = DummyEditorInterface.new(main)
	return _editor_interface

class DummyUndoRedo extends Dummy:
	"""
	This isn't really a dummy since this actually implements undo/redo functionality.
	"""
	
	func _init(n: Node).(n) -> void:
		pass
	
	func create_action(text: String, merge_mode: int) -> void:
		pass
	
	func add_do_method(object: Object, method_name: String, param_0 = null, param_1 = null, param_2 = null) -> void:
		"""
		The actual function signature takes varargs but GDscript does not support that. Thus, we
		cheat and just have optional params
		"""
		pass
	
	func add_undo_method(object: Object, method_name: String, param_0 = null, param_1 = null, param_2 = null) -> void:
		"""
		The actual function signature takes varargs but GDscript does not support that. Thus, we
		cheat and just have optional params
		"""
		pass
	
	func add_do_property(object: Object, property: String, value) -> void:
		pass
	
	func add_undo_property(object: Object, property: String, value) -> void:
		pass
	
	func commit_action() -> void:
		pass

func get_undo_redo():
	if _undo_redo == null:
		_undo_redo = DummyUndoRedo.new(main)
	return _undo_redo
