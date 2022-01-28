extends Control

var plugin: Node

onready var tree: Tree = $HSplitContainer/Tree

onready var messaging: Label = $HSplitContainer/Menu/Messaging

onready var save_button: Button = $HSplitContainer/Menu/SaveButtons/Save
onready var save_as_button: Button = $HSplitContainer/Menu/SaveButtons/SaveAs
onready var load_button: Button = $HSplitContainer/Menu/Load
onready var revert_button: Button = $HSplitContainer/Menu/Revert

var is_registered := false

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	tree.connect("item_selected", self, "_on_item_selected")
	
	var root := tree.create_item()
	
	var general := tree.create_item(root)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_item_selected() -> void:
	var ti := tree.get_selected()

###############################################################################
# Private functions                                                           #
###############################################################################

func _on_message_sent(text: String) -> void:
	messaging.text = text

###############################################################################
# Public functions                                                            #
###############################################################################

func register_main(node: Node) -> void:
	if not is_registered:
		node.logger.connect("on_log", self, "_on_message_sent")
		
		save_button.connect("pressed", node, "_on_save_pressed")
		save_as_button.connect("pressed", node, "_on_save_as_pressed")
		load_button.connect("pressed", node, "_on_load_pressed")
		revert_button.connect("pressed", node, "_on_revert_pressed")
		
		is_registered = true
