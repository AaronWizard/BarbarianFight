extends Scene

@export_file("*.tscn") var game_scene_path: String
@onready var _screen_fade := $ScreenFade as ScreenFade


func _ready() -> void:
	_screen_fade.fade_in()


func _on_start_pressed() -> void:
	await _screen_fade.fade_out()
	switch_scene(game_scene_path)


func _on_quit_pressed() -> void:
	await _screen_fade.fade_out()
	get_tree().quit()
