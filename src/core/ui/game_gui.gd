class_name GameGUI
extends CanvasLayer

@onready var _player_stamina := $PlayerStamina as PlayerStamina
@onready var _boss_stamina := $BossStamina as BossStamina


func set_player_actor(actor: Actor) -> void:
	_player_stamina.set_player(actor)
