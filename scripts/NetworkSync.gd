extends RefCounted
class_name NetworkSync

static func serialize_fighter(fighter) -> Dictionary:
	return {
		"pid": fighter.player_id,
		"x": fighter.position.x,
		"y": fighter.position.y,
		"ax": fighter.aim.x,
		"ay": fighter.aim.y,
		"vx": fighter.velocity.x,
		"vy": fighter.velocity.y,
		"spirit": fighter.blade_spirit,
		"respawn": fighter.respawn_timer,
		"label": fighter.label,
		"team": fighter.team,
		"atk_flash": fighter.attack_flash,
		"throw_flash": fighter.throw_flash,
		"clash_flash": fighter.clash_flash,
		"shield_flash": fighter.shield_flash,
		"shield": fighter.shield_charges,
		"fire": fighter.fire_sickle_charges,
		"split": fighter.split_sickle_charges,
		"barrier": fighter.barrier_charges,
		"phase": fighter.phase_sprint_charges,
		"phase_active": fighter.phase_sprint_active,
		"throw_charge": fighter.throw_charge,
		"throw_charging": fighter.throw_charging,
		"harvest": fighter.harvest_timer,
		"harvest_phase": fighter.harvest_phase,
		"sprint": fighter.sprint_timer,
		"curse": fighter.curse_slow_timer,
		"orbit": fighter.orbit_ring_active,
		"orbit_spin": fighter.orbit_ring_spin,
		"stealth": fighter.invisibility_timer,
	}


static func apply_fighter_row(fighter, row: Dictionary) -> Dictionary:
	var server_pos := Vector2(row.get("x", fighter.position.x), row.get("y", fighter.position.y))
	var server_aim := Vector2(row.get("ax", fighter.aim.x), row.get("ay", fighter.aim.y))
	if server_aim.length_squared() > 0.01:
		server_aim = server_aim.normalized()
	else:
		server_aim = fighter.aim
	fighter.velocity = Vector2(row.get("vx", 0.0), row.get("vy", 0.0))
	fighter.blade_spirit = row.get("spirit", fighter.blade_spirit)
	fighter.respawn_timer = row.get("respawn", fighter.respawn_timer)
	fighter.label = row.get("label", fighter.label)
	fighter.team = row.get("team", fighter.team)
	fighter.attack_flash = row.get("atk_flash", fighter.attack_flash)
	fighter.throw_flash = row.get("throw_flash", fighter.throw_flash)
	fighter.clash_flash = row.get("clash_flash", fighter.clash_flash)
	fighter.shield_flash = row.get("shield_flash", fighter.shield_flash)
	fighter.shield_charges = row.get("shield", fighter.shield_charges)
	fighter.fire_sickle_charges = row.get("fire", fighter.fire_sickle_charges)
	fighter.split_sickle_charges = row.get("split", fighter.split_sickle_charges)
	fighter.barrier_charges = row.get("barrier", fighter.barrier_charges)
	fighter.phase_sprint_charges = row.get("phase", fighter.phase_sprint_charges)
	fighter.phase_sprint_active = row.get("phase_active", fighter.phase_sprint_active)
	fighter.throw_charge = row.get("throw_charge", fighter.throw_charge)
	fighter.throw_charging = row.get("throw_charging", fighter.throw_charging)
	fighter.harvest_timer = row.get("harvest", fighter.harvest_timer)
	fighter.harvest_phase = row.get("harvest_phase", fighter.harvest_phase)
	fighter.sprint_timer = row.get("sprint", fighter.sprint_timer)
	fighter.curse_slow_timer = row.get("curse", fighter.curse_slow_timer)
	fighter.orbit_ring_active = row.get("orbit", fighter.orbit_ring_active)
	fighter.orbit_ring_spin = row.get("orbit_spin", fighter.orbit_ring_spin)
	fighter.invisibility_timer = row.get("stealth", fighter.invisibility_timer)
	return {
		"position": server_pos,
		"aim": server_aim,
	}
