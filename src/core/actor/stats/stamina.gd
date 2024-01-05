class_name Stamina
extends Node

## Keeps track of an entity's current stamina.
##
## Keeps track of an entity's current stamina. When it runs out of stamina the
## entity has "died".

## Emitted when the current stamina has changed. A negative [param delta] is
## damage, a positive [param delta] is healing.
signal stamina_changed(delta: int)

## Emitted when the maximum stamina has changed.
signal max_stamina_changed(old_max: int)


## Emitted when the stamina is zero or less.
signal died


## The maximum stamina. The current stamina is always less than or equal to the
## maximum stamina.
var max_stamina: int:
	set(value):
		var old_max := max_stamina

		max_stamina = value
		current_stamina = maxi(current_stamina, max_stamina)

		if max_stamina != old_max:
			max_stamina_changed.emit(old_max)


## The current stamina.
var current_stamina: int:
	set(value):
		var old_current := current_stamina
		current_stamina = mini(value, max_stamina)
		if current_stamina != old_current:
			stamina_changed.emit(current_stamina - old_current)

			if not is_alive:
				died.emit()


## True if the entity still has stamina, false otherwise.
var is_alive: bool:
	get:
		return current_stamina > 0


func heal_full() -> void:
	current_stamina = max_stamina
