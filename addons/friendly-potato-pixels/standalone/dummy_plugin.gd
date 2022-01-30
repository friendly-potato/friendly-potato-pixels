extends Node

var main: Node

var logger = load("res://addons/friendly-potato-pixels/logger.gd").new()

func _init() -> void:
	logger.setup(self)

func _input(event: InputEvent) -> void:
	# Plugins can hook into the editor's built-in save functionality
	# We can't, so we have to poll for the expected input
	if event is InputEventKey:
		if (event.control == true and event.scancode == KEY_S and event.pressed):
			if main.save_item() != OK:
				logger.error("Unable to save image")

class Dummy extends Object:
	var main: Node
	
	func _init(n: Node) -> void:
		main = n
	
	func cleanup() -> void:
		for i in get_property_list():
			if not i.name in ["Object", "script", "Script Variables"]:
				if i.has_method("free"):
					i.free()

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
	return DummyEditorInterface.new(main)

class DummyUndoRedo extends Dummy:
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
	return DummyUndoRedo.new(main)

func inject_tool(_node: Node) -> void:
	# Intentionally do nothing
	pass
