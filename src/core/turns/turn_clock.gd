class_name TurnClock
extends Node

## The turn manager for a map.
##
## The turn manager for a map. Controls when actors take turns and in what
## order. Manages changes to the turn order when actors are added or removed.
## Runs turn actions when turns are taken.

var _current_map: Map
var _running := false

var _turn_takers: Array[TurnTaker] = []
var _turn_index := 0


## Clears the turn order and current map.
func clear() -> void:
	_running = false
	_turn_takers.clear()
	_turn_index = 0

	if _current_map:
		_current_map.actor_added.disconnect(_actor_added)
		_current_map.actor_removed.disconnect(_actor_removed)

		_current_map = null


## Sets the current map and starts managing the turn order of its actors.
func set_map(map: Map) -> void:
	clear()
	_current_map = map

	@warning_ignore("return_value_discarded")
	_current_map.actor_added.connect(_actor_added)
	@warning_ignore("return_value_discarded")
	_current_map.actor_removed.connect(_actor_removed)

	for actor in _current_map.actor_map.actors:
		_add_turn_taker(actor.turn_taker)


## Starts the turn loop.[br]
## Processes turns until [method stop] or [method clear] are called.
func run() -> void:
	_running = true

	while _running:
		var next_turn := _turn_takers[_turn_index]
		# Use call_deferred to make sure the turn_finished signal is caught.
		next_turn.start_turn.call_deferred()

		@warning_ignore("unsafe_cast")
		var action := await next_turn.turn_finished as TurnAction
		await _run_action(action)

		_turn_index = (_turn_index + 1) % _turn_takers.size()


## Stops the turn loop.
func stop() -> void:
	_running = false


func _run_action(action: TurnAction) -> void:
	if action:
		if action.wait_for_map_anims() and _current_map.animations_playing:
			await _current_map.animations_finished
		@warning_ignore("redundant_await")
		await action.run()


func _actor_added(actor: Actor) -> void:
	_add_turn_taker(actor.turn_taker)


func _actor_removed(actor: Actor) -> void:
	_remove_turn_taker(actor.turn_taker)


func _add_turn_taker(turn_taker: TurnTaker) -> void:
	assert(turn_taker not in _turn_takers)
	_turn_takers.append(turn_taker)

	@warning_ignore("return_value_discarded")
	turn_taker.first_turn_requested.connect(
		_make_turn_taker_go_first.bind(turn_taker))


func _remove_turn_taker(turn_taker: TurnTaker) -> void:
	assert(turn_taker in _turn_takers)
	var index := _turn_takers.find(turn_taker)
	_turn_takers.remove_at(index)
	if _turn_index > index:
		_turn_index -= 1
	turn_taker.first_turn_requested.disconnect(_make_turn_taker_go_first)


func _make_turn_taker_go_first(turn_taker: TurnTaker) -> void:
	assert(turn_taker in _turn_takers)
	_turn_takers.erase(turn_taker)
	_turn_takers.push_front(turn_taker)
