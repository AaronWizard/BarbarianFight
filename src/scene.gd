class_name Scene
extends Node

## A single game scene.
##
## A single game scene. Can notify the root (main) node to switch the scene.

## A scene switch has been requested.
signal scene_switch_requested(new_scene: Scene)


## Switch to the scene whose file is at [param scene_path].[br]
## A string path is used to avoid possible circular dependencies between scenes.
func switch_scene(scene_path: String) -> void:
	var scene_file := load(scene_path) as PackedScene
	if not scene_file:
		push_error("'%s' is not a scene path" % scene_file)
	else:
		var scene := scene_file.instantiate() as Scene
		if not scene:
			push_error("Scene is not of type 'Scene'")
		else:
			scene_switch_requested.emit(scene)
