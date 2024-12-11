class_name BossStamina
extends VBoxContainer

## Stamina bar for current boss.
##
## Stamina bar for current boss. Appears when a boss appears to a given player
## actor.[br]
## - A boss is first tracked when the player actor has line-of-sight to it.[br]
## - When a boss goes out of line-of-sight, it continues to be tracked until a
##   set number of turns pass.[br]
##   - If the player actor has line-of-sight to another boss, the other boss
##     gets tracked.[br]
## - If more than one boss is present, the boss being tracked is whoever was
##   last attacked by the player actor.[br]
## - If the currently tracked boss dies and another boss is present, the other
##   boss gets tracked.[br]

# If the tracked boss is not visible to the player, the number of turns that may
# pass until the boss is untracked.
const _BOSS_HIDDEN_TURNS_MAX := 3


## The player actor. Used for checking which bosses are visible.
var player: Actor = null:
	set(value):
		if player:
			player.added_to_new_map.disconnect(_on_player_change_map)
		player = value
		@warning_ignore("return_value_discarded")
		player.added_to_new_map.connect(_on_player_change_map)


var _current_boss: Actor = null
# The number of turns that have passed since the tracked boss went out of the
# player's line of sight.
var _boss_hidden_turns := 0


@onready var _boss_name := $MarginContainer/BossName as Label
@onready var _stamina_bar := $StaminaBar as ActorStamina


func _ready() -> void:
	visible = false


## Check for bosses visible to [param player_actor].
func check_for_visible_boss() -> void:
	_check_if_boss_still_visible()
	if not _current_boss:
		# Will signal if boss tracked or untracked.
		_find_new_visible_boss()


func _check_if_boss_still_visible() -> void:
	if _current_boss:
		if _player_can_see_boss(player, _current_boss):
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
				and _player_can_see_boss(player, actor):
			_set_boss(actor)
			_show_boss()
			break

	if not _current_boss:
		visible = false


func _set_boss(new_boss: Actor) -> void:
	_current_boss = new_boss
	@warning_ignore("return_value_discarded")
	_current_boss.removed_from_map.connect(_on_boss_died)
	_boss_hidden_turns = 0


func _unset_boss() -> void:
	if _current_boss:
		_current_boss.removed_from_map.disconnect(_on_boss_died)
		_current_boss = null


func _on_boss_died() -> void:
	_unset_boss()
	_find_new_visible_boss()


func _on_player_change_map() -> void:
	_unset_boss()
	_find_new_visible_boss()


# TODO: Use FOV or LOS check.
static func _player_can_see_boss(_player: Actor, _boss: Actor) -> bool:
	return true


func _show_boss() -> void:
	assert(_current_boss.actor_name and not _current_boss.actor_name.is_empty())
	assert(_current_boss.stamina.is_alive)

	_boss_name.text = _current_boss.actor_name
	_stamina_bar.set_actor(_current_boss)

	visible = true
