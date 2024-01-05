class_name TurnClock
extends Node

## The game's turn manager.
##
## The game's turn manager. Controls when entities take turns and in what order,
## and manages when entities are added to and removed from the turn order.

var running := false

# The main set of turn takers.
var _turn_takers: Array[TurnTaker] = []
# The current turn index.
var _turn_index := 0


## Adds a turn taker.
func add_turn_taker(turn_taker: TurnTaker) -> void:
	if turn_taker in _turn_takers:
		push_error("TurnTaker '%s' already in TurnClock" % turn_taker)
	else:
		_turn_takers.append(turn_taker)


## Removes a turn taker.
func remove_turn_taker(turn_taker: TurnTaker) -> void:
	if not turn_taker in _turn_takers:
		push_error("TurnTaker '%s' not in TurnClock" % turn_taker)
	else:
		var index := _turn_takers.find(turn_taker)
		_turn_takers.remove_at(index)
		if _turn_index > index:
			_turn_index -= 1


func run() -> void:
	running = true

	while running:
		var next_turn := _turn_takers[_turn_index]
		next_turn.start_turn()
		if next_turn.turn_running:
			await next_turn.turn_finished
		_turn_index = (_turn_index + 1) % _turn_takers.size()
