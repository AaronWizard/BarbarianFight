class_name PlayerState
extends State

@export var game_control: GameControl


var player_actor: Actor:
	get:
		return game_control.player_actor
