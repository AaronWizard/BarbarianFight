class_name Game
extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

var _player: Actor
var _current_map: Map

@onready var _turn_clock := $TurnClock as TurnClock


func _ready() -> void:
	_player = player_actor_scene.instantiate() as Actor
	_load_initial_map()

	_turn_clock.run()


func _load_initial_map() -> void:
	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)


func _load_map(map: Map, start_cell: Vector2i) -> void:
	add_child(map)
	_current_map = map

	_current_map.set_turn_clock(_turn_clock)
	_current_map.add_actor(_player, start_cell)
