class_name Bullet
extends Area2D

## A single poolable bullet managed by BulletSpawner.
## Call activate() to fire it; it deactivates itself when it exits the screen.

var is_active: bool = false

var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 300.0
## How far past the screen edge a bullet travels before being returned to the pool.
const OFF_SCREEN_MARGIN: float = 60.0

var bullet_type: int

func _ready() -> void:
	# Layer 3 (bit value 4), detects players on layer 1
	bullet_type = randi_range(0,3)
	collision_layer = 4
	collision_mask  = 1
	body_entered.connect(_on_body_entered)
	_setup_collision_shape()
	_create_sprite()
	deactivate()

func _process(delta: float) -> void:
	position += _direction * _speed * delta
	if _is_outside_screen():
		deactivate()

## Pulls a bullet out of the pool and sets it in motion.
func activate(start_position: Vector2, direction: Vector2, speed: float = 300.0) -> void:
	position    = start_position
	_direction  = direction.normalized()
	rotation = _direction.angle() + (PI / 2)
	_speed      = speed
	if bullet_type >= 2:
		_speed *= 1.5
	is_active   = true
	visible     = true
	monitoring  = true
	set_process(true)

## Returns the bullet to the pool: invisible, no physics, no processing.
## monitoring uses set_deferred because Godot's physics lock prevents direct
## assignment inside a body_entered callback.
func deactivate() -> void:
	is_active  = false
	visible    = false
	set_deferred("monitoring", false)
	set_process(false)

func _is_outside_screen() -> bool:
	var s := get_viewport_rect().size
	return (
		position.x < -OFF_SCREEN_MARGIN
		or position.x > s.x + OFF_SCREEN_MARGIN
		or position.y < -OFF_SCREEN_MARGIN
		or position.y > s.y + OFF_SCREEN_MARGIN
	)

func _on_body_entered(body: Node) -> void:
	print(body)
	if not is_active:
		return  # deferred monitoring hasn't cleared yet; ignore phantom signals
	if body.has_method("die"):
		body.die()
	deactivate()

## Creates a small circle collision shape matching the bullet's visual size.
func _setup_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	$CollisionShape2D.shape = shape

## Creates a small yellow circle texture as a placeholder for future pixel art.
func _create_sprite() -> void:
	$Sprite2D.texture = $Sprite2D.texture.duplicate()
	if bullet_type == 0:
		$Sprite2D.texture.region = Rect2(32, 0, 16, 16)
	elif bullet_type == 1:
		$Sprite2D.texture.region = Rect2(48, 0, 16, 16)
	elif bullet_type == 2:
		$Sprite2D.texture.region = Rect2(32, 16, 16, 16)
	elif bullet_type == 3:
		$Sprite2D.texture.region = Rect2(48, 16, 16, 16)
		
