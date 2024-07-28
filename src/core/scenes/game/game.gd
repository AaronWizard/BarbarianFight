extends Scene

@export var initial_map_scene: PackedScene
@export var player_start_marker: String

@export var player_actor_scene: PackedScene

@export_file("*.tscn") var game_over_scene_path: String

var _player_actor: Actor


var _current_map: Map:
	get:
		var result: Map = null
		if _map_container.get_child_count() > 0:
			assert(_map_container.get_child_count() == 1)
			result = _map_container.get_child(0) as Map
		return result


@onready var _map_container := $MapContainer
@onready var _target_display := $TargetDisplay as TargetDisplay

@onready var _turn_clock := $TurnClock as TurnClock
@onready var _boss_tracker := $BossTracker as BossTracker

@onready var _player_camera := $PlayerCamera as PlayerCamera
@onready var _game_gui := $GameGUI as GameGUI
@onready var _player_input := $PlayerInput as PlayerInput

@onready var _screen_fade := $ScreenFade as ScreenFade


func _ready() -> void:
	_init_player()
	_load_initial_map()

	await _screen_fade.fade_in()
	_turn_clock.run()


func _init_player() -> void:
	_player_actor = player_actor_scene.instantiate() as Actor

	@warning_ignore("return_value_discarded")
	_player_actor.player_turn_started.connect(_on_player_actor_turn_started)
	@warning_ignore("return_value_discarded")
	_player_actor.stamina.died.connect(_on_player_died)

	_boss_tracker.player = _player_actor
	_player_input.set_player_actor(_player_actor)

	_player_actor.sprite.remote_transform.remote_path \
			= _player_camera.get_path()


func _load_initial_map() -> void:
	var map := initial_map_scene.instantiate() as Map
	var start_cell := map.markers.get_marker(player_start_marker).origin_cell

	_load_map(map, start_cell)
	# Player node needs to be child of other node for this to work.
	_game_gui.set_player_actor(_player_actor)


func _load_map(map: Map, start_cell: Vector2i) -> void:
	_unload_map()
	_map_container.add_child(map)

	_current_map.set_turn_clock(_turn_clock)
	_current_map.add_actor(_player_actor, start_cell)

	_player_camera.set_bounds(_current_map.pixel_rect)


func _unload_map() -> void:
	if _current_map:
		_current_map.set_turn_clock(null)
		_current_map.remove_actor(_player_actor)

		var old_map := _current_map
		_map_container.remove_child(_current_map)
		old_map.free()


func _on_player_actor_turn_started() -> void:
	_boss_tracker.check_for_visible_boss()

	if _current_map.animations_playing:
		await _current_map.animations_finished
	_player_input.start_turn()


func _on_player_input_action_chosen(turn_action: TurnAction) -> void:
	_player_actor.do_turn_action(turn_action)


func _on_player_died() -> void:
	if _player_actor.sprite.animation_playing:
		await _player_actor.sprite.animation_finished

	_turn_clock.running = false
	await get_tree().create_timer(0.5).timeout # Dramatic pause!
	await _screen_fade.fade_out()

	switch_scene(game_over_scene_path)


func _on_boss_tracker_boss_tracked(boss: Actor) -> void:
	_game_gui.show_boss_bar(boss)


func _on_boss_tracker_boss_untracked() -> void:
	_game_gui.hide_boss_bar()


func _on_player_input_show_target_range(
		target_range: Array[Vector2i], valid_targets: Array[Vector2i],
		start_target_cell: Vector2i) -> void:
	_target_display.show_range(target_range, valid_targets, Square.new(start_target_cell, 1))


func _on_player_input_target_cell_changed(new_target_cell: Vector2i) -> void:
	_target_display.set_target(Square.new(new_target_cell, 1))


func _on_player_input_hide_target_range() -> void:
	_target_display.clear()
