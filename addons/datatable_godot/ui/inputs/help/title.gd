@tool
extends Label

@onready var common: Node = %signals

# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(str("Datatable Documentation - Version ", common.plugin_version))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
