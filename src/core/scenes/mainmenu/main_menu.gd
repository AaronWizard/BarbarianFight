extends Scene

@export var game_scene: PackedScene

@onready var _screen_fade := $ScreenFade as ScreenFade


func _ready() -> void:
	_screen_fade.fade_in()


func _on_start_pressed() -> void:
	await _screen_fade.fade_out()

	var game := game_scene.instantiate() as Scene
	switch_scene.emit(game)
