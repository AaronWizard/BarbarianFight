class_name TurnTaker
extends Node

## An entity that takes turns.
##
## An entity that takes turns. Notifies observers when its turn has started and
## ended.

## The turn taker's turn has started.
signal turn_started

## The turn taker's turn has finished.
signal turn_finished


## True if the turn taker is still on its current turn.
var turn_running: bool:
	get:
		return _turn_running


var _turn_running := false


## Starts the turn taker's turn.
func start_turn() -> void:
	if _turn_running:
		push_error("Turn already running.")
	else:
		_turn_running = true
		turn_started.emit()


## Ends the turn taker's turn.
func end_turn() -> void:
	if not _turn_running:
		push_error("Turn not running")
	else:
		_turn_running = false
		turn_finished.emit()
