extends Control

var plugin: Node

onready var tree: Tree = $HSplitContainer/Tree

onready var messaging: Label = $HSplitContainer/Menu/Messaging

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
	node.logger.connect("on_log", self, "_on_message_sent")
