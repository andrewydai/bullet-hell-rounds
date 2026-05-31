extends Node2D

## The rotating line that divides the screen and acts as an instant-kill zone.
## Rotates clockwise from the screen center like a clock hand.

@export var rotation_speed_degrees: float = 15.0

## Must exceed the screen diagonal (√(1280²+720²) ≈ 1468) to cover every angle.
const LINE_HALF_LENGTH: float = 800.0

func _ready() -> void:
	position = get_viewport_rect().size / 2.0
	_build_line_geometry()

	# Area2D on layer 2, detects bodies on layer 1 (players)
	$KillZone.collision_layer = 2
	$KillZone.collision_mask  = 1
	$KillZone.body_entered.connect(_on_kill_zone_body_entered)

func _process(delta: float) -> void:
	# Positive rotation in Godot is clockwise — correct for a clock-hand sweep
	rotation_degrees += rotation_speed_degrees * delta

## Sets up the Line2D visual and the RectangleShape2D kill zone at runtime.
## Both extend from the center along the local Y axis; rotation handles sweep direction.
func _build_line_geometry() -> void:
	var line_visual: Line2D = $Line2D
	line_visual.points = PackedVector2Array([
		Vector2(0.0, -LINE_HALF_LENGTH),
		Vector2(0.0,  LINE_HALF_LENGTH),
	])
	line_visual.width = 6.0
	line_visual.default_color = Color(1.0, 0.95, 0.0)  # bright yellow

	var kill_shape := RectangleShape2D.new()
	kill_shape.size = Vector2(8.0, LINE_HALF_LENGTH * 2.0)
	$KillZone/CollisionShape2D.shape = kill_shape

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
