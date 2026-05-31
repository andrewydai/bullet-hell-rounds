extends Area2D

## A single poolable bullet managed by BulletSpawner.
## Call activate() to fire it; it deactivates itself when it exits the screen.

var is_active: bool = false

var _direction: Vector2 = Vector2.RIGHT
var _speed: float = 300.0

## How far past the screen edge a bullet travels before being returned to the pool.
const OFF_SCREEN_MARGIN: float = 60.0

func _ready() -> void:
	# Layer 3 (bit value 4), detects players on layer 1
	collision_layer = 4
	collision_mask  = 1
	body_entered.connect(_on_body_entered)
	_setup_collision_shape()
	_create_placeholder_sprite()
	deactivate()

func _process(delta: float) -> void:
	position += _direction * _speed * delta
	if _is_outside_screen():
		deactivate()

## Pulls a bullet out of the pool and sets it in motion.
func activate(start_position: Vector2, direction: Vector2, speed: float = 300.0) -> void:
	position    = start_position
	_direction  = direction.normalized()
	_speed      = speed
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
func _create_placeholder_sprite() -> void:
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	var center := Vector2(6.0, 6.0)
	for x in range(12):
		for y in range(12):
			if Vector2(x, y).distance_to(center) <= 5.0:
				image.set_pixel(x, y, Color(1.0, 0.85, 0.0))
	$Sprite2D.texture = ImageTexture.create_from_image(image)
