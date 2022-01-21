extends Node

func _exit_tree():
	pass

class Dummy extends Object:
	func cleanup() -> void:
		for i in get_property_list():
			if not i.name in ["Object", "script", "Script Variables"]:
				if i.has_method("free"):
					i.free()

class DummyEditorInterface extends Dummy:
	var editor_viewport := Control.new()
	
	func get_editor_viewport():
		return editor_viewport

func get_editor_interface():
	return DummyEditorInterface.new()

class DummyUndoRedo extends Dummy:
	pass

func get_undo_redo():
	return DummyUndoRedo.new()
