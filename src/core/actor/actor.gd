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


## The actor's current map.
var map: Map:
	get:
		return _map


## The actor's [ActorSprite].
var sprite: ActorSprite:
	get:
		return _sprite


@onready var _sprite := $ActorSprite as ActorSprite
@onready var _turn_taker := $TurnTaker as TurnTaker

var _map: Map
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


## Set's the actor's map. Not meant to be used directly. Use Map.add_actor and
## Map.remove_actor.
func set_map(new_map: Map) -> void:
	if _map and (self in _map.actor_map.actors):
		push_error("Actor '%s' not removed from map '%s' using " \
				+ "Map.remove_actor" % [self, _map])
	elif new_map and (self not in new_map.actor_map.actors):
		push_error("Actor '%s' not added to map '%s' using Map.add_actor" \
				% [self, new_map])
	else:
		_map = new_map


## Sets the actor's turn clock.
func set_turn_clock(clock: TurnClock) -> void:
	if _turn_clock and (_turn_clock != clock):
		_turn_clock.remove_turn_taker(_turn_taker)

	_turn_clock = clock
	if _turn_clock:
		_turn_clock.add_turn_taker(_turn_taker)


## Runs [param action] and ends the actor's turn.
func do_turn_action(action: TurnAction) -> void:
	if not _turn_taker.turn_running:
		push_error("Actor turn not running")
	else:
		# Null action is wait
		var action_speed := TurnConstants.ACTION_WAIT_SPEED

		if action:
			action_speed = action.get_action_speed()

			if action.wait_for_map_anims() and map.animations_playing:
				await map.animations_finished

			@warning_ignore("redundant_await")
			await action.run()

		_turn_taker.end_turn(action_speed)


## Move to [param target_cell] with an animation.[br]
## Assumes [param target_cell] is adjacent to the actor's origin_cell.
func move_step(target_cell: Vector2i) -> void:
	var direction := target_cell - origin_cell
	origin_cell = target_cell
	await _sprite.move_step(direction)


func _tile_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.tile_size = tile_size


func _cell_size_changed(_old_size: Vector2i) -> void:
	if _sprite:
		_sprite.cell_size = cell_size


func _on_turn_taker_turn_started() -> void:
	if sprite.animation_playing:
		await sprite.animation_finished

	if player_controlled:
		player_turn_started.emit()
	elif _ai:
		var action := _ai.get_action()
		await do_turn_action(action)
	else:
		_turn_taker.end_turn(TurnConstants.ACTION_WAIT_SPEED)
