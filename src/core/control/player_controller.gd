class_name PlayerController
extends ActorController

## A node for controlling player actors.
##
## A node for controlling player actors. On the actor's turn, waits for player
## input.

## The player actor's turn has started and is waiting for input.
signal player_turn_started(aoe: Array[Vector2i], attack_data: AttackData)

signal player_attack_reaction_started

# Private signals.
signal _turn_chosen(action: TurnAction)
signal _attack_reaction_chosen


func get_turn_action() -> TurnAction:
	player_turn_started.emit()

	@warning_ignore("unsafe_cast")
	var action := await _turn_chosen as TurnAction

	return action


func get_attack_reaction(aoe: Array[Vector2i], attack_data: AttackData) -> void:
	player_attack_reaction_started.emit(aoe, attack_data)
	await _attack_reaction_chosen


## Set the action for the player actor to do on its turn.
func do_player_action(action: TurnAction) -> void:
	_turn_chosen.emit(action)


func do_player_attack_reaction() -> void:
	_attack_reaction_chosen.emit()
