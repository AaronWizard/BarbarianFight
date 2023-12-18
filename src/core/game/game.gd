class_name Game
extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

var _player_actor: Actor
var _current_map: Map

@onready var _turn_clock := $TurnClock as TurnClock
@onready var _player_camera := $PlayerCamera as PlayerCamera
@onready var _player_input := $PlayerInput as PlayerInput


func _ready() -> void:
	_player_input.enabled = false

	_init_player()
	_load_initial_map()

	_turn_clock.run()


func _init_player() -> void:
	_player_actor = player_actor_scene.instantiate() as Actor
	@warning_ignore("return_value_discarded")
	_player_actor.player_turn_started.connect(_on_player_actor_turn_started)

	_player_input.set_player_actor(_player_actor)


func _load_initial_map() -> void:
	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)


func _load_map(map: Map, start_cell: Vector2i) -> void:
	add_child(map)
	_current_map = map

	_current_map.set_turn_clock(_turn_clock)
	_current_map.add_actor(_player_actor, start_cell)

	_player_camera.set_bounds(_current_map.pixel_rect)
	_player_actor.sprite.remote_transform.remote_path \
			= _player_camera.get_path()


func _on_player_actor_turn_started() -> void:
	if _current_map.animations_playing:
		await _current_map.animations_finished
	_player_input.enabled = true


func _on_player_input_action_chosen(turn_action: TurnAction) -> void:
	_player_input.enabled = false
	_player_actor.do_turn_action(turn_action)
