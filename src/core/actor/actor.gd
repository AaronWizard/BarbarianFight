@tool
class_name Actor
extends TileObject

## An actor.
##
## An actor. An actor has stats and can take turns.

@export var definition: ActorDefinition
## The scene for the actor's [Brain].
@export var brain_scene: PackedScene

@onready var _sprite := $ActorSprite as ActorSprite
@onready var _turn_taker := $TurnTaker as TurnTaker

var _brain: Brain

var _turn_clock: TurnClock


func _ready() -> void:
	if not Engine.is_editor_hint():
		if brain_scene:
			var brain := brain_scene.instantiate() as Brain
			set_brain(brain)


## Sets the actor's brain. The brain is added to the actor as a child node.
func set_brain(brain: Brain) -> void:
	_brain = brain
	add_child(_brain)
	_brain.set_actor(self)


## Sets the actor's turn clock.
func set_turn_clock(clock: TurnClock) -> void:
	if _turn_clock and (_turn_clock != clock):
		_turn_clock.remove_turn_taker(_turn_taker)

	_turn_clock = clock
	_turn_clock.add_turn_taker(_turn_taker)


func _tile_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.tile_size = tile_size


func _cell_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.cell_size = cell_size


func _on_turn_taker_turn_started() -> void:
	var action_speed := TurnConstants.ACTION_WAIT_SPEED # Null action is wait

	print("Actor: %s starting turn" % name,)
	if _brain:
		@warning_ignore("redundant_await")
		var action := await _brain.get_action()
		if action:
			action_speed = action.get_action_speed()
			@warning_ignore("redundant_await")
			await action.run()
	print("Actor: %s finished turn" % name)

	_turn_taker.end_turn(action_speed)
