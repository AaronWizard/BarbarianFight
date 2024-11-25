@icon("res://assets/editor/icons/state_machine.png")
class_name StateMachine
extends Node

## A state machine with [State] objects as children.


@export var start_state: State

var _current_state: State


func _ready() -> void:
	change_state(start_state)


func _unhandled_input(event: InputEvent) -> void:
	_current_state.handle_input(event)


func _process(delta: float) -> void:
	_current_state.process(delta)


func change_state(new_state: State, data := {}) -> void:
	if _current_state:
		_current_state.state_change_requested.disconnect(change_state)
		_current_state.exit()

	_current_state = new_state
	@warning_ignore("return_value_discarded")
	_current_state.state_change_requested.connect(change_state)
	_current_state.enter(data)
