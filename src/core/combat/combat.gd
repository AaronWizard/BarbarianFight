class_name Combat


static func attack_single_actor(target_actor: Actor, attack: Attack,
		animate_hit := true) -> void:
	var direction := Vector2i.ZERO
	if attack.has_source_rect:
		direction = TileGeometry.cardinal_dir_between_rects(
				attack.source_rect, target_actor.rect)

	target_actor.stamina.current_stamina -= attack.attack_power
	if animate_hit:
		await _play_hit_anim(target_actor, direction)


static func attack_aoe(attack: Attack, map: Map, aoe: Array[Vector2i],
		animate_hits := true) -> void:
	var hit_actors := map.actor_map.get_actors_in_aoe(aoe)

	for actor in hit_actors:
		attack_single_actor(actor, attack, animate_hits)

	if map.animations_playing:
		await map.animations_finished


static func _play_hit_anim(target_actor: Actor, direction: Vector2i) -> void:
	if direction != Vector2i.ZERO:
		await target_actor.sprite.anim_player.animate(
				StandardActorSpriteAnims.HIT, direction)
	else:
		await target_actor.sprite.anim_player.animate(
				StandardActorSpriteAnims.HIT_NO_DIRECTION, direction)
