extends Area2D

## A pickable powerup that sits in the world until a player walks over it.
## Calls collect_powerup() on the player and frees itself on collection.

## Must stay in sync with PowerupManager.PowerupType and Player's POWERUP_* constants.
enum Type { SHOOT, icecream, TRAP, TURRET }

@export var powerup_type: Type = Type.SHOOT

func _ready() -> void:
	# Layer 5 (bit value 16), detects players on layer 1
	collision_layer = 16
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_setup_collision_shape()
	_create_sprite_for_type()

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_powerup"):
		body.collect_powerup(powerup_type)
		GameEvents.powerup_collected.emit(body.player_index, powerup_type)
		queue_free()

## Circle shape slightly smaller than the visual so collection feels fair.
func _setup_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = 13.0
	$CollisionShape2D.shape = shape

## Dispatches to the correct sprite builder based on the assigned powerup type.
func _create_sprite_for_type() -> void:
	match powerup_type:
		Type.SHOOT:  _create_shoot_sprite()
		Type.icecream: _create_icecream_sprite()
		_:           _create_generic_sprite()

## SHOOT icon: a cyan targeting ring with a white center dot.
## Reads as "precision shot" — single circle, clean crosshair feel.
func _create_shoot_sprite() -> void:
	var size := 28
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size / 2.0, size / 2.0)
	for x in range(size):
		for y in range(size):
			var dist := Vector2(x, y).distance_to(center)
			if dist >= 8.0 and dist <= 12.0:
				image.set_pixel(x, y, Color(0.0, 0.88, 1.0))    # cyan ring
			elif dist < 3.5:
				image.set_pixel(x, y, Color.WHITE)               # white center dot
	$Sprite2D.texture = ImageTexture.create_from_image(image)

## icecream icon: three orange dots fanning out to the right.
## Reads as "icecream fire" — clearly three projectiles, fanned layout.
func _create_icecream_sprite() -> void:
	var size := 28
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var dot_color := Color(1.0, 0.55, 0.05)
	# Center, upper, lower — fanning rightward from the pickup center
	var dot_positions: Array[Vector2] = [
		Vector2(13, 14),   # center bullet
		Vector2(18,  8),   # upper-right bullet
		Vector2(18, 20),   # lower-right bullet
	]
	for dot_pos in dot_positions:
		for x in range(size):
			for y in range(size):
				if Vector2(x, y).distance_to(dot_pos) <= 4.0:
					image.set_pixel(x, y, dot_color)
	$Sprite2D.texture = ImageTexture.create_from_image(image)

## Fallback for unimplemented types (TRAP, TURRET) — plain grey square.
func _create_generic_sprite() -> void:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.55, 0.55, 0.55))
	$Sprite2D.texture = ImageTexture.create_from_image(image)
