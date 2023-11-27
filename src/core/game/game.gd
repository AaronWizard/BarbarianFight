class_name Game
extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

var _player: Actor
var _current_map: Map


func _ready() -> void:
	_player = player_actor_scene.instantiate() as Actor

	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)


func _load_map(map: Map, start_cell: Vector2i) -> void:
	add_child(map)
	_current_map = map

	_current_map.add_actor(_player, start_cell)
