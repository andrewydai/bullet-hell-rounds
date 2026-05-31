extends Node2D

## Continuously spawns bullets from random screen edges using an object pool.
## Pooling avoids per-spawn instantiation overhead and establishes the pattern
## for more complex bullet hell patterns in later stages.

@export var bullet_pool_size: int = 30
@export var spawn_interval_seconds: float = 0.4
@export var bullet_speed: float = 280.0

## Slight angular variance applied to each bullet's direction to avoid perfect
## horizontal/vertical shots that would never threaten one side of the screen.
const DIRECTION_DRIFT: float = 0.25

const BULLET_SCENE_PATH: String = "res://scenes/Bullet.tscn"

var _bullet_pool: Array = []
var _spawn_timer: float = 0.0
var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	_initialize_bullet_pool()

func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval_seconds:
		_spawn_timer = 0.0
		_try_spawn_bullet()

## Pre-instantiates all pool bullets as children of this node in a deactivated state.
func _initialize_bullet_pool() -> void:
	var bullet_scene: PackedScene = load(BULLET_SCENE_PATH)
	for _i in range(bullet_pool_size):
		var bullet: Area2D = bullet_scene.instantiate()
		add_child(bullet)
		_bullet_pool.append(bullet)

## Grabs an inactive bullet and fires it from a randomly chosen screen edge.
func _try_spawn_bullet() -> void:
	var bullet = _get_inactive_bullet()
	if bullet == null:
		return  # pool exhausted; this spawn tick is skipped
	var spawn_data := _pick_random_edge_spawn()
	bullet.activate(spawn_data.position, spawn_data.direction, bullet_speed)

## Returns the first inactive pool bullet, or null if all are currently in flight.
func _get_inactive_bullet():
	for bullet in _bullet_pool:
		if not bullet.is_active:
			return bullet
	return null

## Picks one of the four screen edges at random and returns a spawn position
## just outside that edge plus an inward direction with slight angular drift.
func _pick_random_edge_spawn() -> Dictionary:
	var edge: int = randi() % 4
	var spawn_pos: Vector2
	var direction: Vector2

	match edge:
		0:  # top edge → travels downward
			spawn_pos = Vector2(randf_range(0.0, _screen_size.x), -20.0)
			direction = Vector2(randf_range(-DIRECTION_DRIFT, DIRECTION_DRIFT), 1.0).normalized()
		1:  # right edge → travels leftward
			spawn_pos = Vector2(_screen_size.x + 20.0, randf_range(0.0, _screen_size.y))
			direction = Vector2(-1.0, randf_range(-DIRECTION_DRIFT, DIRECTION_DRIFT)).normalized()
		2:  # bottom edge → travels upward
			spawn_pos = Vector2(randf_range(0.0, _screen_size.x), _screen_size.y + 20.0)
			direction = Vector2(randf_range(-DIRECTION_DRIFT, DIRECTION_DRIFT), -1.0).normalized()
		_:  # left edge → travels rightward
			spawn_pos = Vector2(-20.0, randf_range(0.0, _screen_size.y))
			direction = Vector2(1.0, randf_range(-DIRECTION_DRIFT, DIRECTION_DRIFT)).normalized()

	return {"position": spawn_pos, "direction": direction}
