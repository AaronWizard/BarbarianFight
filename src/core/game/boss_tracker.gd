class_name BossTracker
extends Node

## Class for keeping track of the current boss.
##
## Class for keeping track of the current boss. Used for showing and hiding the
## boss stamina bar.
## - A boss is first tracked when the player actor has line-of-sight to it.
## - When a boss goes out of line-of-sight, it continues to be tracked until a
##   set number of turns pass.
##   - If the player actor has line-of-sight to another boss, the other boss
##     gets tracked.
## - If more than one boss is present, the boss being tracked is whoever was
##   last attacked by the player actor.
## - If the currently tracked boss dies and another boss is present, the other
##   boss gets tracked.


## An actor is being tracked as the boss.
signal boss_tracked(boss: Actor)

## No actor is being tracked as the boss.
signal boss_untracked


# If the tracked boss is not visible to the player, the number of turns that may
# pass until the boss is untracked.
const _BOSS_HIDDEN_TURNS_MAX := 3


## The player actor. Used for checking which bosses are visible.
var player: Actor = null


var _current_boss: Actor = null
# The number of turns that have passed since the tracked boss went out of the
# player's line of sight.
var _boss_hidden_turns := 0


func reset() -> void:
	_unset_boss()
	boss_untracked.emit()


## Check for bosses visible to [param player_actor].
func check_for_visible_boss() -> void:
	_check_if_boss_still_visible()
	if not _current_boss:
		# Will signal if boss tracked or untracked.
		_find_new_visible_boss()


func _check_if_boss_still_visible() -> void:
	if _current_boss:
		if BossTracker._player_can_see_boss(player, _current_boss):
			_boss_hidden_turns = 0
		else:
			assert(_boss_hidden_turns < _BOSS_HIDDEN_TURNS_MAX)
			_boss_hidden_turns += 1
			if _boss_hidden_turns == _BOSS_HIDDEN_TURNS_MAX:
				_unset_boss()


func _find_new_visible_boss() -> void:
	assert(not _current_boss)

	for actor in player.map.actor_map.actors:
		if (actor != player) and actor.is_boss \
				and BossTracker._player_can_see_boss(player, actor):
			_set_boss(actor)
			boss_tracked.emit(_current_boss)
			break

	if not _current_boss:
		boss_untracked.emit()


func _set_boss(new_boss: Actor) -> void:
	_current_boss = new_boss
	@warning_ignore("return_value_discarded")
	_current_boss.stamina.died.connect(_on_boss_died)
	_boss_hidden_turns = 0


func _unset_boss() -> void:
	if _current_boss:
		_current_boss.stamina.died.disconnect(_on_boss_died)
		_current_boss = null


func _on_boss_died() -> void:
	_unset_boss()
	_find_new_visible_boss()


# TODO: Use FOV or LOS check.
static func _player_can_see_boss(_player: Actor, _boss: Actor) -> bool:
	return true
