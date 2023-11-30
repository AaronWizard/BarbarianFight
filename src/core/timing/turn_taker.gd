class_name TurnTaker
extends Node

## An entity that takes turns.
##
## An entity that takes turns. Notifies observers when its turn has started and
## ended.[br]
## [br]
## A TurnTaker has an initiative value that starts at zero then accumulates
## based on a speed value. When its initiative passes a threshold value the
## TurnTaker is ready to take a turn. Ending its turn requires delay value -
## representing how long its turn took - that is subtracted from the TurnTaker's
## initiative.[br]
## [br]
## Further reading on the method used for turn management:[br]
## - [url]https://www.roguebasin.com/index.php?title=Time_Systems#Energy_systems[/url][br]
## - [url]https://journal.stuffwithstuff.com/2014/07/15/a-turn-based-game-loop/[/url]

## The turn taker's turn has started.
signal turn_started

## The turn taker's turn has finished.
signal turn_finished


## A value representing how long until a turn taker can start a turn.[br]
## When this value is greater than or equal to INITIATIVE_THRESHOLD, the turn
## taker may start a turn.
var initiative: int:
	get:
		return _initiative


## True if the turn taker can start a turn, false otherwise.
var can_start_turn: bool:
	get:
		return _initiative >= TurnConstants.INITIATIVE_THRESHOLD


## How fast the turn taker is. Affects how fast its initiative increases as time
## passes.
var speed := TurnConstants.ActorSpeed.MEDIUM

## An arbitrary value used for breaking ties between turn takers when
## determining their order.
var rank := 1

var _initiative := 0


## Compares two turn takers to determine in what order they may start a turn if
## both are eligible for starting turns.[br]
## In order, the turn takers are compared by initiative, speed, then rank.
static func compare(a: TurnTaker, b: TurnTaker) -> bool:
	var result := a.initiative > b.initiative
	if not result and (a.initiative == b.initiative):
		result = TurnConstants.actor_speed_charge(a.speed) \
				> TurnConstants.actor_speed_charge(b.speed)
		if not result and (a.speed == b.speed):
			result = a.rank < b.rank
	return result


## Resets the turn taker's initiative to zero.
func reset_initiative() -> void:
	_initiative = 0


## Advances time for the turn taker.[br]
## The turn taker's initiative is increased by a value depending on its speed.
func advance_time() -> void:
	_initiative += TurnConstants.actor_speed_charge(speed)


## Starts the turn taker's turn.
func start_turn() -> void:
	turn_started.emit()


## Ends the turn taker's turn, reducing its initiative by a value depending on
## [param action_speed].
func end_turn(action_speed: TurnConstants.ActionSpeed) -> void:
	_initiative -= TurnConstants.action_delay(action_speed)
	turn_finished.emit()


func _to_string() -> String:
	return "TurnTaker(initiative: %d, speed: %d, rank: %d)" \
			% [_initiative, TurnConstants.actor_speed_charge(speed), rank]
