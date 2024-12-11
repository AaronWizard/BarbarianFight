class_name PlayerWaitState
extends PlayerState

@export var boss_stamina: BossStamina
@export var player_movement_state: State


func enter() -> void:
	@warning_ignore("return_value_discarded")
	game_control.player_controller.player_turn_started.connect(
		_start_turn,
		ConnectFlags.CONNECT_ONE_SHOT
	)


func _start_turn() -> void:
	boss_stamina.check_for_visible_boss()

	if player_actor.map.animations_playing:
		await player_actor.map.animations_finished

	request_state_change(player_movement_state)
