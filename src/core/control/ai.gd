class_name AI
extends Brain


func get_action() -> TurnAction:
	print("Running AI")
	await get_tree().create_timer(0.5).timeout
	return null
