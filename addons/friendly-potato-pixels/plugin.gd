tool
extends EditorPlugin

var main: Control

func _enter_tree():
	main = load("res://addons/friendly-potato-pixels/main.tscn").instance()
	
	# Inject `tool` at the top of the plugin script
	var script: Script = main.get_script().duplicate()
	script.source_code = "tool\n%s" % script.source_code
	script.reload(false)
	main.set_script(script)
	
	main.plugin = self
	
	get_editor_interface().get_editor_viewport().add_child(main)
	make_visible(false)

func _exit_tree():
	if main != null:
		main.queue_free()

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
