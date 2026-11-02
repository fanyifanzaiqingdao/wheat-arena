extends RefCounted
class_name FighterModel

class Fighter:
	var player_id := -1
	var peer_id := 0
	var team := 0
	var label := ""
	var position := Vector2.ZERO
	var spawn_position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var aim := Vector2.RIGHT
	var blade_spirit := 3
	var attack_cooldown := 0.0
	var attack_flash := 0.0
	var attack_active := 0.0
	var clash_flash := 0.0
	var clash_immunity := 0.0
	var throw_cooldown := 0.0
	var throw_flash := 0.0
	var throw_input_down := false
	var throw_charging := false
	var throw_charge := 0.0
	var sprint_timer := 0.0
	var sprint_cooldown := 0.0
	var phase_sprint_charges := 0
	var phase_sprint_active := false
	var teleport_cooldown := 0.0
	var shield_charges := 0
	var shield_flash := 0.0
	var fire_sickle_charges := 0
	var split_sickle_charges := 0
	var barrier_charges := 0
	var barrier_input_down := false
	var orbit_ring_active := false
	var orbit_ring_spin := 0.0
	var orbit_hit_cooldowns: Dictionary = {}
	var invisibility_timer := 0.0
	var respawn_timer := 0.0
	var ai := true
	var target_cell := Vector2i.ZERO
	var target_refresh := 0.0
	var harvest_timer := 0.0
	var harvest_phase := 0.0
	var curse_slow_timer := 0.0
	var anim_seed := 0.0
	var character_id := ""

class HarvestSpark:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var life := 0.0
	var max_life := 0.0
	var team := 0

class ThrownSickle:
	var owner: Fighter = null
	var position := Vector2.ZERO
	var direction := Vector2.RIGHT
	var returning := false
	var on_fire := false
	var spin := 0.0
	var distance := 0.0
	var charge_power := 0.5
	var speed := 380.0
	var max_range := 200.0
	var fire_tick := 0.0
	var ember_timer := 0.0
	var hit_targets: Array[Fighter] = []
	var burned_cells: Array[int] = []

class PowerUp:
	var kind := 0
	var position := Vector2.ZERO
	var bob_phase := 0.0

class TeleportPortal:
	var id := ""
	var position := Vector2.ZERO
	var link_id := ""
	var label := ""

class FireEmber:
	var position := Vector2.ZERO
	var velocity := Vector2.ZERO
	var life := 0.0
	var max_life := 0.0

class BarrierZone:
	var team := 0
	var owner_label := ""
	var position := Vector2.ZERO
	var life := 0.0
	var seal_timer := 0.0
	var pulse := 0.0
	var inside_allies: Array[Fighter] = []

class ClashEffect:
	var position := Vector2.ZERO
	var life := 0.0
	var max_life := 0.38

class FighterInterp:
	var from_pos := Vector2.ZERO
	var to_pos := Vector2.ZERO
	var from_aim := Vector2.RIGHT
	var to_aim := Vector2.RIGHT
	var elapsed := 0.0
	var correction := Vector2.ZERO
	var initialized := false

class WheatBlade:
	var cell := Vector2i.ZERO
	var offset := Vector2.ZERO
	var height := 18.0
	var width := 2.0
	var phase := 0.0
	var tint := 0.0
	var tuft := 0.0
