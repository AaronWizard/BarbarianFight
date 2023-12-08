@tool
class_name Actor
extends TileObject

## An actor.
##
## An actor. An actor has stats and can take turns.

## Emitted when the actor's turn has started and the actor is set to be player
## controlled.
signal player_turn_started

@export var definition: ActorDefinition
## The scene for the actor's [AI].
@export var ai_scene: PackedScene

## True if the actor is controlled by the player, false otherwise.
@export var player_controlled := false
## The actor's faction ID. Different factions are hostile to each other.
@export var faction := 0

@onready var _sprite := $ActorSprite as ActorSprite
@onready var _turn_taker := $TurnTaker as TurnTaker

var _ai: AI

var _turn_clock: TurnClock


func _ready() -> void:
	if not Engine.is_editor_hint():
		if ai_scene:
			var ai := ai_scene.instantiate() as AI
			set_ai(ai)


## Sets the actor's AI. The AI is added to the actor as a child node.
func set_ai(ai: AI) -> void:
	_ai = ai
	add_child(_ai)
	_ai.set_actor(self)


## Sets the actor's turn clock.
func set_turn_clock(clock: TurnClock) -> void:
	if _turn_clock and (_turn_clock != clock):
		_turn_clock.remove_turn_taker(_turn_taker)

	_turn_clock = clock
	_turn_clock.add_turn_taker(_turn_taker)


## Runs [param action] and ends the actor's turn.
func do_turn_action(action: TurnAction) -> void:
	if not _turn_taker.turn_running:
		push_error("Actor turn not running")

	var action_speed := TurnConstants.ACTION_WAIT_SPEED # Null action is wait

	if action:
		action_speed = action.get_action_speed()
		@warning_ignore("redundant_await")
		await action.run()

	_turn_taker.end_turn(action_speed)


func _tile_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.tile_size = tile_size


func _cell_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.cell_size = cell_size


func _on_turn_taker_turn_started() -> void:
	if player_controlled:
		player_turn_started.emit()
	elif _ai:
		var action := await _ai.get_action()
		do_turn_action(action)
	else:
		_turn_taker.end_turn(TurnConstants.ACTION_WAIT_SPEED)
