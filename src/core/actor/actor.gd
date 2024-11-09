@tool
@icon("res://assets/editor/icons/actor.png")
class_name Actor
extends TileObject

## An actor.
##
## An actor. An actor has stats and can take turns.

## Emitted when the actor is added to a new map.
signal added_to_new_map

## Emitted when the actor is removed from its map.
signal removed_from_map

## Emitted when the actor's origin cell has changed.
signal moved(old_cell: Vector2i)

## Emitted when the actor's turn has started and the actor is set to be player
## controlled.
signal player_turn_started

## The name of the actor that can be displayed to the player.
@export var actor_name: String

## The actor's [ActorDefinition].
@export var definition: ActorDefinition
## The scene for the actor's [AI].
@export var ai_scene: PackedScene

## True if the actor is controlled by the player, false otherwise.
@export var player_controlled := false
## The actor's faction ID. Different factions are hostile to each other.
@export var faction := 0

## True if the boss bar should be visible when the player can see this actor,
## false otherwise.
@export var is_boss := false

## The actor's standard attack.
@export var attack_ability: Ability

## The actor's abilities.
@export var abilities: Array[Ability] = []


## The actor's current map.
var map: Map:
	get:
		return _map


## The actor's [ActorSprite].
var sprite: ActorSprite:
	get:
		return $ActorSprite as ActorSprite


## The actor's [Stamina].
var stamina: Stamina:
	get:
		return $Stamina as Stamina


## All of the actor's abilities, including its standard attack ability.
var all_abilities: Array[Ability]:
	get:
		var result: Array[Ability] = []
		if attack_ability:
			result.append(attack_ability)
		result.append_array(abilities)
		return result


@onready var _turn_taker := $TurnTaker as TurnTaker


var _map: Map
var _ai: AI

var _turn_clock: TurnClock


func _ready() -> void:
	if not Engine.is_editor_hint():
		_turn_taker.is_player_controlled = player_controlled

		if definition:
			stamina.max_stamina = definition.stamina
			stamina.heal_full()

		if ai_scene:
			var ai := ai_scene.instantiate() as AI
			set_ai(ai)


## Sets the actor's AI. The AI is added to the actor as a child node.
func set_ai(ai: AI) -> void:
	if _ai:
		remove_child(_ai)
		_ai.free()
	_ai = ai
	add_child(_ai)
	_ai.set_actor(self)


## Set's the actor's map. Not meant to be used directly. Use Map.add_actor and
## Map.remove_actor.
func set_map(new_map: Map) -> void:
	if _map and (self in _map.actor_map.actors):
		push_error("Actor not removed from map using Map.remove_actor")
	elif new_map and (self not in new_map.actor_map.actors):
		push_error("Actor not added to map using Map.add_actor")
	else:
		_map = new_map
		if _map:
			added_to_new_map.emit()
		else:
			removed_from_map.emit()


## Sets the actor's turn clock.
func set_turn_clock(clock: TurnClock) -> void:
	if _turn_clock and (_turn_clock != clock):
		_turn_clock.remove_turn_taker(_turn_taker)

	_turn_clock = clock
	if _turn_clock:
		_turn_clock.add_turn_taker(_turn_taker)


## Makes this actor go first in the turn order.
func make_go_first() -> void:
	if _turn_clock:
		_turn_clock.make_turn_taker_go_first(_turn_taker)
	else:
		push_warning("No turn clock is set")


## Returns true if [param other_actor] is hostile to this actor, false
## otherwise.
func is_hostile(other_actor: Actor) -> bool:
	return (self != other_actor) and (faction != other_actor.faction)


## Runs [param action] and ends the actor's turn.
func do_turn_action(action: TurnAction) -> void:
	if not _turn_taker.turn_running:
		push_error("Actor turn not running")
	else:
		if action:
			if action.wait_for_map_anims() and map.animations_playing:
				await map.animations_finished
			@warning_ignore("redundant_await")
			await action.run()
		_turn_taker.end_turn()


## Move to [param target_cell] with a walk/step animation.[br]
## Assumes [param target_cell] is adjacent to the actor's origin_cell.
func move_step(target_cell: Vector2i) -> void:
	var target_vector := target_cell - origin_cell
	origin_cell = target_cell
	await sprite.move_step(target_vector)


func _tile_size_changed(_old_size: Vector2i) -> void:
	sprite.tile_size = tile_size


func _origin_cell_changed(old_cell: Vector2i) -> void:
	moved.emit(old_cell)


func _cell_size_changed(_old_size: int) -> void:
	sprite.cell_size = cell_size


func _on_turn_taker_turn_started() -> void:
	await sprite.wait_for_animation()

	if player_controlled:
		player_turn_started.emit()
	elif _ai:
		var action := _ai.get_action()
		await do_turn_action(action)
	else:
		_turn_taker.end_turn()
