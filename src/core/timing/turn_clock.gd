class_name TurnClock
extends Node

## The game's turn manager.
##
## The game's turn manager. Controls when entities take turns and in what order,
## and manages when entities are added to and removed from the turn order.[br]
## [br]
## Turn takers have speed and initiative. Between turns the initiative of every
## turn taker is increased by their speed, until at least one passes a certain
## threshold value. Turn takers with enough initiative get a turn.[br]
## [br]
## Further reading on the method used for turn management:[br]
## - [url]https://www.roguebasin.com/index.php?title=Time_Systems#Energy_systems[/url][br]
## - [url]https://journal.stuffwithstuff.com/2014/07/15/a-turn-based-game-loop/[/url]

var running := false

# The main set of turn takers.
var _turn_takers := {}
# The turn takers that can take a turn
var _ready_turn_takers: Array[TurnTaker] = []

# Turn takers waiting to be added.
var _turn_takers_to_add := {}
# Turn takers waiting to be removed.
var _turn_takers_to_remove := {}


## Adds a turn taker.
func add_turn_taker(turn_taker: TurnTaker) -> void:
	if _turn_takers.has(turn_taker):
		push_error("TurnTaker '%s' already in TurnClock" % turn_taker)
	@warning_ignore("return_value_discarded")
	_turn_takers_to_remove.erase(turn_taker)
	_turn_takers_to_add[turn_taker] = true


## Removes a turn taker.
func remove_turn_taker(turn_taker: TurnTaker) -> void:
	if not _turn_takers.has(turn_taker):
		push_error("TurnTaker '%s' not in TurnClock" % turn_taker)
	@warning_ignore("return_value_discarded")
	_turn_takers_to_add.erase(turn_taker)
	_turn_takers_to_remove[turn_taker] = true


func run() -> void:
	running = true
	_add_and_remove_turn_takers()

	while running:
		for t: TurnTaker in _turn_takers:
			t.advance_time()
			if t.can_start_turn:
				_ready_turn_takers.append(t)
		await _run_turns()


func _to_string() -> String:
	return "TurnClock( %s )" % ", ".join(_turn_takers.keys())


func _add_and_remove_turn_takers() -> void:
	for t: TurnTaker in _turn_takers_to_remove:
		@warning_ignore("return_value_discarded")
		_turn_takers.erase(t)
	_turn_takers_to_remove.clear()

	for t: TurnTaker in _turn_takers_to_add:
		t.reset_initiative()
		t.rank = _turn_takers.size()
		_turn_takers[t] = true
	_turn_takers_to_add.clear()


func _run_turns() -> void:
	_ready_turn_takers.sort_custom(TurnTaker.compare)
	while not _ready_turn_takers.is_empty():
		var next_turn := _ready_turn_takers[0]

		if not _turn_takers.has(next_turn):
			_ready_turn_takers.pop_front()
			continue

		next_turn.start_turn()
		if next_turn.turn_running:
			await next_turn.turn_finished

		_add_and_remove_turn_takers()

		if next_turn.can_start_turn:
			_ready_turn_takers.sort_custom(TurnTaker.compare)
		else:
			_ready_turn_takers.pop_front()
