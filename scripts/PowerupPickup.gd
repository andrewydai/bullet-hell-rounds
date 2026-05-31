extends Area2D

## A pickable powerup that sits in the world until a player walks over it.
## Calls collect_powerup() on the player and frees itself on collection.

## Must match PowerupManager.PowerupType enum order.
enum Type { SHOOT, TRAP, TURRET }

@export var powerup_type: Type = Type.SHOOT

func _ready() -> void:
	# Layer 5 (bit value 16), detects players on layer 1
	collision_layer = 16
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_setup_collision_shape()
	_create_placeholder_sprite()

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_powerup"):
		body.collect_powerup(powerup_type)
		GameEvents.powerup_collected.emit(body.player_index, powerup_type)
		queue_free()

## Circle shape slightly smaller than the visual so collection feels fair.
func _setup_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	$CollisionShape2D.shape = shape

## Bright green square placeholder — easy to distinguish from yellow bullets.
func _create_placeholder_sprite() -> void:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 1.0, 0.4))
	$Sprite2D.texture = ImageTexture.create_from_image(image)
