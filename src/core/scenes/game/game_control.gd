class_name GameControl
extends Node

var player_actor: Actor
var player_controller: PlayerController

var selected_ability: Ability
var initial_ability_target: Vector2i


func set_ability_data(ability: Ability, initial_target: Vector2i) -> void:
	selected_ability = ability
	initial_ability_target = initial_target


func clear_ability_data() -> void:
	selected_ability = null
	initial_ability_target = Vector2.ZERO
