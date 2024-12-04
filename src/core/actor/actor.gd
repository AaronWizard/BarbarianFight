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

## The name of the actor that can be displayed to the player.
@export var actor_name: String

## The actor's [ActorDefinition].
@export var definition: ActorDefinition

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


## The actor's turn taker. Controls when the actor gets a turn.
var turn_taker: TurnTaker:
	get:
		return $TurnTaker as TurnTaker


## The actor's current [ActorController].
var controller: ActorController:
	get:
		return _controller


var _map: Map

var _controller: ActorController


func _ready() -> void:
	if not Engine.is_editor_hint():
		if definition:
			stamina.max_stamina = definition.stamina
			stamina.heal_full()


## Set's the actor's map. Not meant to be used directly. Use
## [method Map.add_actor] and [method Map.remove_actor].
func set_map(new_map: Map) -> void:
	if _map and _map.is_ancestor_of(self):
		push_error("Actor not removed from map using Map.remove_actor")
	elif new_map and not new_map.is_ancestor_of(self):
		push_error("Actor not added to map using Map.add_actor")
	else:
		_map = new_map
		if _map:
			added_to_new_map.emit()
		else:
			removed_from_map.emit()


## Sets the actor's controller.
func set_controller(new_controller: ActorController) -> void:
	if _controller:
		remove_child(_controller)
		_controller.set_actor(null)

	_controller = new_controller

	if _controller:
		# Check whether or not controller is already a child due to being added
		# in the scene editor.
		if _controller.get_parent() != self:
			assert(_controller.controlled_actor != self)
			add_child(_controller)
		_controller.set_actor(self)


## Returns true if [param other_actor] is hostile to this actor, false
## otherwise.
func is_hostile(other_actor: Actor) -> bool:
	return (self != other_actor) and (faction != other_actor.faction)


## Move to [param target_cell] with a walk/step animation.[br]
## Assumes [param target_cell] is adjacent to the actor's origin_cell.
func move_step(target_cell: Vector2i) -> void:
	var target_vector := target_cell - origin_cell
	origin_cell = target_cell
	await sprite.move_step(target_vector)


## Makes the actor take damage from the given direction. If
## [param process_hit_or_death] is true, default hit animations are played and
## the actor is removed from its map if it's dead.
func take_damage(attack_data: AttackData, process_hit_or_death := true) -> void:
	stamina.current_stamina -= attack_data.attack_power

	if process_hit_or_death:
		var direction := attack_data.get_direction(rect)
		if stamina.is_alive:
			await sprite.hit(direction)
		else:
			await sprite.die(direction)
			if map:
				map.remove_actor(self)


func _tile_size_changed(_old_size: Vector2i) -> void:
	sprite.tile_size = tile_size


func _origin_cell_changed(old_cell: Vector2i) -> void:
	moved.emit(old_cell)


func _cell_size_changed(_old_size: int) -> void:
	sprite.cell_size = cell_size


func _on_turn_taker_turn_started() -> void:
	await sprite.wait_for_animation()

	var action: TurnAction = null
	if _controller:
		@warning_ignore("redundant_await")
		action = await _controller.get_turn_action()

	turn_taker.end_turn(action)
