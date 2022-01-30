tool
extends EditorPlugin

const PLUGIN_NAME := "Pixels"
const TOOLBAR_NAME := "Toolbar"

var logger

var main: Control
var toolbar: Control
var menu_bar: Control

var file_system: Tree
var toolbar_parent: TabContainer

func _enter_tree():
	logger = load("res://addons/friendly-potato-pixels/logger.gd").new()
	logger.setup(self)
	
	menu_bar = load("res://addons/friendly-potato-pixels/menu_bar.tscn").instance()
	inject_tool(menu_bar)
	menu_bar.plugin = self
	
	toolbar = load("res://addons/friendly-potato-pixels/toolbar.tscn").instance()
	inject_tool(toolbar)
	toolbar.plugin = self
	
	main = load("res://addons/friendly-potato-pixels/main.tscn").instance()
	inject_tool(main)
	main.plugin = self
	
	main.toolbar = toolbar
	main.menu_bar = menu_bar
	
	add_control_to_bottom_panel(menu_bar, PLUGIN_NAME)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, toolbar)
	get_editor_interface().get_editor_viewport().add_child(main)
	
	make_visible(false)
	
	for c0 in get_editor_interface().get_file_system_dock().get_children():
		if c0 is VSplitContainer:
			for c1 in c0.get_children():
				if c1 is Tree:
					file_system = c1
					file_system.connect("multi_selected", self, "_on_file_system_multi_selected")
	
	toolbar_parent = toolbar.get_parent()

func _exit_tree():
	if main != null:
		get_editor_interface().get_editor_viewport().remove_child(main)
		main.queue_free()
	if toolbar != null:
		remove_control_from_docks(toolbar)
		toolbar.queue_free()
	if menu_bar != null:
		remove_control_from_bottom_panel(menu_bar)
		menu_bar.queue_free()
	if file_system != null:
		file_system.disconnect("multi_selected", self, "_on_file_system_multi_selected")

func save_external_data():
	if main.save_item() != OK:
		logger.error("Unable to save image")

func enable_plugin():
	get_editor_interface().set_main_screen_editor(PLUGIN_NAME)
	make_bottom_panel_item_visible(menu_bar)
	for i in toolbar_parent.get_tab_count():
		if toolbar_parent.get_tab_title(i) == TOOLBAR_NAME:
			toolbar_parent.current_tab = i
			break

func _on_file_system_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	if not selected:
		return
	
	main.open_item("%s/%s" % [
		ProjectSettings.globalize_path(get_editor_interface().get_selected_path()),
		item.get_text(column)])

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
	return PLUGIN_NAME

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("CanvasLayer", "EditorIcons")

func inject_tool(node: Node) -> void:
	"""
	Inject `tool` at the top of the plugin script
	"""
	var script: Script = node.get_script().duplicate()
	script.source_code = "tool\n%s" % script.source_code
	script.reload(false)
	node.set_script(script)
