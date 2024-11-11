class_name GameGUI
extends CanvasLayer

signal ability_cancelled

@onready var _player_stamina := $PlayerStamina as PlayerStamina
@onready var _ability_display := $AbilityDisplay as AbilityDisplay
@onready var _boss_stamina := $BossStamina as BossStamina


func _ready() -> void:
	_ability_display.visible = false
	_boss_stamina.visible = false


func set_player_actor(actor: Actor) -> void:
	_player_stamina.set_player(actor)


func show_ability(ability_name: String) -> void:
	_ability_display.set_ability_name(ability_name)
	_ability_display.visible = true


func hide_ability() -> void:
	_ability_display.visible = false


func show_boss_bar(boss: Actor) -> void:
	_boss_stamina.show_boss(boss)
	_boss_stamina.visible = true


func hide_boss_bar() -> void:
	_boss_stamina.visible = false


func _on_ability_display_cancelled() -> void:
	ability_cancelled.emit()
