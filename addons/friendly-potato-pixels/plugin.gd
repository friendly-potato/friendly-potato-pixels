tool
extends EditorPlugin

var main: Control
var toolbar: Control

func _enter_tree():
	toolbar = load("res://addons/friendly-potato-pixels/toolbar.tscn").instance()
	_inject_tool(toolbar)
	toolbar.plugin = self
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, toolbar)
	
	main = load("res://addons/friendly-potato-pixels/main.tscn").instance()
	_inject_tool(main)
	main.plugin = self
	
	get_editor_interface().get_editor_viewport().add_child(main)
	
	main.toolbar = toolbar
	
	make_visible(false)

func _exit_tree():
	if main != null:
		main.queue_free()
	if toolbar != null:
		toolbar.queue_free()

func has_main_screen():
	return true

func make_visible(visible):
	if main != null:
		main.visible = visible
		main.set_process(visible)
		main.set_process_input(visible)
		main.set_process_internal(visible)
		main.set_process_unhandled_input(visible)
		main.set_process_unhandled_key_input(visible)

func get_plugin_name():
	return "Pixels"

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("CanvasLayer", "EditorIcons")

func _inject_tool(node: Node) -> void:
	"""
	Inject `tool` at the top of the plugin script
	"""
	var script: Script = node.get_script().duplicate()
	script.source_code = "tool\n%s" % script.source_code
	script.reload(false)
	node.set_script(script)
