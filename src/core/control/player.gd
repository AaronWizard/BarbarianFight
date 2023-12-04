class_name Player
extends Brain

## Selects actions for a player-controlled actor based on player input.

signal player_turn_started


func get_action() -> TurnAction:
	player_turn_started.emit()

	return null
