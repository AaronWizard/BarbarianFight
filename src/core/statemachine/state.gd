@icon("res://assets/editor/icons/state.png")
class_name State
extends Node

## A state in a [StateMachine].


## Emitted when the state wants to transition to a different state.[br]
## [param data] contains arbitrary data accessed in [param new_state]'s
## [method State.enter] method.
signal state_change_requested(new_state: State, data: Dictionary)


## Called by the state machine when changing to this state.[br]
## [param data] contains arbitrary data.[br]
## Can be overriden.
func enter(_data := {}) -> void:
	pass


## Called by the state machine when changing to a different state.[br]
## Can be overriden.
func exit() -> void:
	pass


## Called by the state machine when receiving unhandled input events. Called
## during [method Node._unhandled_input].[br]
## Can be overriden.
func handle_input(_event: InputEvent) -> void:
	pass


## Called by the state machine on update.
func process(_delta: float) -> void:
	pass


## Emits [signal state_change_requested].
func request_state_change(new_state: State, data := {}) -> void:
	state_change_requested.emit(new_state, data)
