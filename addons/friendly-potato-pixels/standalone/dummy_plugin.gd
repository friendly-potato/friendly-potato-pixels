extends Node

var main: Node

func _exit_tree():
	pass

func _input(event: InputEvent) -> void:
	main.save_util.save_input_event(event)

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
		return main

func get_editor_interface():
	return DummyEditorInterface.new(main)

class DummyUndoRedo extends Dummy:
	func _init(n: Node).(n) -> void:
		pass

func get_undo_redo():
	return DummyUndoRedo.new(main)

func inject_tool(node: Node) -> void:
	# Intentionally do nothing
	pass
