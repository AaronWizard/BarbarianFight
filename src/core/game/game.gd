class_name Game
extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

var _player: Actor
var _current_map: Map

@onready var _turn_clock := $TurnClock as TurnClock


func _ready() -> void:
	_init_player()
	_load_initial_map()

	_turn_clock.run()


func _init_player() -> void:
	_player = player_actor_scene.instantiate() as Actor
	@warning_ignore("return_value_discarded")
	_player.player_turn_started.connect(_on_player_turn_started)


func _load_initial_map() -> void:
	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)


func _load_map(map: Map, start_cell: Vector2i) -> void:
	add_child(map)
	_current_map = map

	_current_map.set_turn_clock(_turn_clock)
	_current_map.add_actor(_player, start_cell)


func _on_player_turn_started() -> void:
	print("player turn started")
