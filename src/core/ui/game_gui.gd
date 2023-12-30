class_name GameGUI
extends CanvasLayer

@onready var _player_stamina := $PlayerStamina as PlayerStamina
@onready var _boss_stamina := $BossStamina as BossStamina


func set_player_actor(actor: Actor) -> void:
	_player_stamina.set_player(actor)


func show_boss_bar(boss: Actor) -> void:
	_boss_stamina.show_boss(boss)
	_boss_stamina.visible = true


func hide_boss_bar() -> void:
	_boss_stamina.visible = false
