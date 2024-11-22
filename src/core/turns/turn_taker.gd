class_name TurnTaker
extends Node

## An entity that takes turns.
##
## An entity that takes turns. Notifies observers when its turn has started and
## sends a [TurnAction] when its turn has ended.

## The turn taker's turn has started.
signal turn_started

## The turn taker's turn has finished with the given [TurnAction].
signal turn_finished(action: TurnAction)

## The turn taker has requested to be put first in the turn order.
signal first_turn_requested


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


## Ends the turn taker's turn with the given [TurnAction].
func end_turn(action: TurnAction) -> void:
	if not _turn_running:
		push_error("Turn not running")
	else:
		_turn_running = false
		turn_finished.emit(action)


## Set the turn taker to go first in the turn order.
func request_first_turn() -> void:
	first_turn_requested.emit()
