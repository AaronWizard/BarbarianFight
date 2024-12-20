extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

@export_file("*.tscn") var game_over_scene_path: String

var _player_actor: Actor
var _player_controller: PlayerController

var _turn_clock: TurnClock


var _current_map: Map:
	get:
		var result: Map = null
		if _map_container.get_child_count() > 0:
			assert(_map_container.get_child_count() == 1)
			result = _map_container.get_child(0) as Map
		return result


@onready var _map_container := $MapContainer
@onready var _player_camera := $PlayerCamera as PlayerCamera
@onready var _game_control := $GameControl as GameControl

@onready var _player_stamina := $UI/PlayerStamina as PlayerStamina
@onready var _boss_stamina := $UI/BossStamina as BossStamina

@onready var _screen_fade := $ScreenFade as ScreenFade


#region Initialization

func _ready() -> void:
	_turn_clock = TurnClock.new()

	_init_player_actor()
	_init_player_controller()

	_load_initial_map()

	await _screen_fade.fade_in()
	_turn_clock.run()


func _init_player_actor() -> void:
	_player_actor = player_actor_scene.instantiate() as Actor

	_boss_stamina.player = _player_actor
	_player_actor.sprite.follow_with_camera(_player_camera)

	@warning_ignore("return_value_discarded")
	_player_actor.stamina.died.connect(_on_player_died)

	_game_control.player_actor = _player_actor


func _init_player_controller() -> void:
	_player_controller = PlayerController.new()
	_player_actor.set_controller(_player_controller)

	_game_control.player_controller = _player_controller


func _load_initial_map() -> void:
	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)

	# Player's stamina node needs to be loaded first, so we only do this after
	# the player is added to the map in _load_map.
	_player_stamina.set_player(_player_actor)

#endregion Initialization

#region Map loading

func _load_map(map: Map, start_cell: Vector2i) -> void:
	_unload_map()
	_map_container.add_child(map)

	_turn_clock.set_map(_current_map)

	_current_map.add_actor(_player_actor, start_cell)
	_player_actor.turn_taker.request_first_turn()

	_player_camera.set_bounds(_current_map.pixel_rect)


func _unload_map() -> void:
	if _current_map:
		_current_map.remove_actor(_player_actor)

		var old_map := _current_map
		_map_container.remove_child(_current_map)
		old_map.free()

#endregion Map loading


func _on_player_died() -> void:
	if _current_map.animations_playing:
		await _current_map.animations_finished

	_turn_clock.stop()
	await get_tree().create_timer(0.5).timeout # Dramatic pause!
	await _screen_fade.fade_out()

	switch_scene(game_over_scene_path)
