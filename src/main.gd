extends Node

@export var initial_scene: PackedScene


func _ready() -> void:
	var scene: Scene = initial_scene.instantiate()
	_switch_scene(scene)


func _switch_scene(new_scene: Scene) -> void:
	if get_child_count() > 0:
		assert(get_child_count() == 1)
		remove_child(get_child(0))

	assert(get_child_count() == 0)

	@warning_ignore("return_value_discarded")
	new_scene.scene_switch_requested.connect(_switch_scene)
	add_child(new_scene)
