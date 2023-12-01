class_name TurnConstants

## Constants and enums used by the turn system.
##
## Constants and enums used by the turn system. Defines the standard speed types
## and related time values.

## The minimum amount of initiative a turn taker must have before starting a
## turn.
const INITIATIVE_THRESHOLD = 60

## The possible base speeds for actors.
enum ActorSpeed {
	## Only possible with status effects.
	SLUGGISH,
	SLOW,
	MEDIUM,
	FAST,
	## Only possible with status effects.
	RAPID
}

## The possible speeds for actions.
enum ActionSpeed {
	SLOW,
	MEDIUM,
	FAST
}

const _actor_speed_values := {
	ActorSpeed.SLUGGISH: 1,
	ActorSpeed.SLOW: 2,
	ActorSpeed.MEDIUM: 3,
	ActorSpeed.FAST: 4,
	ActorSpeed.RAPID: 5,
}

const _action_speed_delays := {
	ActionSpeed.SLOW: 60,
	ActionSpeed.MEDIUM: 30,
	ActionSpeed.FAST: 20
}

## Speed of the wait action.
const ACTION_WAIT_SPEED := ActionSpeed.FAST


## How fast a speed type increases a turn taker's initiative.
static func actor_speed_charge(speed: ActorSpeed) -> int:
	return _actor_speed_values[speed]


## The initiative cost for an action's speed.
static func action_delay(speed: ActionSpeed) -> int:
	return _action_speed_delays[speed]