class_name GameGUI
extends CanvasLayer

@onready var _player_stamina := $PlayerStamina as PlayerStamina
@onready var _boss_stamina := $BossStamina as BossStamina


func set_player_actor(actor: Actor) -> void:
	_player_stamina.max_stamina = actor.stamina.max_stamina
	_player_stamina.current_stamina = actor.stamina.current_stamina

	@warning_ignore("return_value_discarded")
	actor.stamina.stamina_changed.connect(
			_on_player_actor_stamina_changed.bind(actor.stamina))
	@warning_ignore("return_value_discarded")
	actor.stamina.max_stamina_changed.connect(
			_on_player_actor_max_stamina_changed.bind(actor.stamina))


func _on_player_actor_stamina_changed(_delta: int, stamina: Stamina) -> void:
	_player_stamina.current_stamina = stamina.current_stamina


func _on_player_actor_max_stamina_changed(_old_max: int, stamina: Stamina) -> void:
	_player_stamina.max_stamina = stamina.max_stamina
