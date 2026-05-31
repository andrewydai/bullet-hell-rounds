extends Node2D

## Manages powerup pickup spawning and zone-based distribution across the screen.
## Each pickup is non-stackable; collection assigns it to one player first-come first-served.

enum PowerupType { SHOOT, TRAP, TURRET }

@export var spawn_interval_seconds: float = 15.0
@export var max_active_pickups: int = 3

## Inset from screen edges where pickups are allowed to appear.
const SPAWN_MARGIN: float = 100.0
const PICKUP_SCENE_PATH: String = "res://scenes/PowerupPickup.tscn"

var _spawn_timer: Timer
## Tracks live pickup nodes so we don't exceed max_active_pickups.
var _active_pickups: Array = []

func _ready() -> void:
	GameEvents.powerup_collected.connect(_on_powerup_collected)
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = spawn_interval_seconds
	_spawn_timer.timeout.connect(_spawn_pickup)
	add_child(_spawn_timer)
	_spawn_timer.start()

## Spawns a SHOOT pickup at a random screen position, respecting the active cap.
func _spawn_pickup() -> void:
	print("HERE")
	# Remove any pickups that were collected (queue_freed) since last spawn
	_active_pickups = _active_pickups.filter(func(p): return is_instance_valid(p))
	if _active_pickups.size() >= max_active_pickups:
		return

	var screen_size := get_viewport_rect().size
	var spawn_pos := Vector2(
		randf_range(SPAWN_MARGIN, screen_size.x - SPAWN_MARGIN),
		randf_range(SPAWN_MARGIN, screen_size.y - SPAWN_MARGIN)
	)
	var pickup: Node = (load(PICKUP_SCENE_PATH) as PackedScene).instantiate()
	# Add to GameWorld (parent) so the pickup has a position in the world
	get_parent().add_child(pickup)
	pickup.position = spawn_pos
	_active_pickups.append(pickup)

## The pickup frees itself on collection; we just prune the tracking array on next spawn.
func _on_powerup_collected(_player_index: int, _powerup_type: int) -> void:
	pass
