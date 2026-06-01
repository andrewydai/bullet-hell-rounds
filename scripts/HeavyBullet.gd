extends Bullet

## A large, slow bullet fired in a 3-shot spread by the SPREAD powerup.
## Inherits all movement, pooling, and collision logic from Bullet.
## Only the size, speed default, and appearance are overridden.

const HEAVY_RADIUS: float = 14.0
const HEAVY_COLOR: Color  = Color(0.75, 0.1, 1.0)  # purple
const HEAVY_SPEED: float  = 130.0

## Override default speed so callers don't need to pass it explicitly.
func activate(start_position: Vector2, direction: Vector2, speed: float = HEAVY_SPEED) -> void:
	super.activate(start_position, direction, speed)

## Larger circle to match the bigger visual.
func _setup_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = HEAVY_RADIUS
	$CollisionShape2D.shape = shape

## Filled purple circle with a bright white core to sell the "heavy" feel.
func _create_placeholder_sprite() -> void:
	var diameter: int = int(HEAVY_RADIUS * 2.0)
	var image := Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var center := Vector2(HEAVY_RADIUS, HEAVY_RADIUS)
	for x in range(diameter):
		for y in range(diameter):
			var dist := Vector2(x, y).distance_to(center)
			if dist <= HEAVY_RADIUS - 1.0:
				# Lerp from pure purple at the edge to a bright white-purple core
				var t := 1.0 - (dist / HEAVY_RADIUS)
				image.set_pixel(x, y, HEAVY_COLOR.lerp(Color.WHITE, t * 0.5))
	$Sprite2D.texture = ImageTexture.create_from_image(image)
