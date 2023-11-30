@tool
class_name Actor
extends TileObject

## An actor.
##
## An actor. An actor has stats and can take turns.

@export var definition: ActorDefinition

@onready var _sprite := $ActorSprite as ActorSprite
@onready var _turn_taker := $TurnTaker as TurnTaker

var _turn_clock: TurnClock


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
	print("%s starting turn [%s]" % [name, _turn_taker])
	await get_tree().create_timer(0.5).timeout
	print("\tTaking action [delay = %d]" \
			% TurnConstants.action_delay(TurnConstants.ActionSpeed.MEDIUM))
	_turn_taker.end_turn(TurnConstants.ActionSpeed.MEDIUM)
