extends CharacterBody2D

## A player character. Instantiate twice in GameWorld with player_index 0 and 1.
## Player 0 → WASD + Space (or Joypad 0)
## Player 1 → Arrow keys + Enter (or Joypad 1)

@export var player_index: int = 0
@export var movement_speed: float = 200.0

## Half the sprite's pixel dimensions; used to clamp the player inside the screen.
const PLAYER_HALF_SIZE: float = 16.0

## Powerup type IDs — mirrors PowerupPickup.Type enum order.
const POWERUP_NONE: int   = -1
const POWERUP_SHOOT: int  =  0
const POWERUP_SPREAD: int =  1

const BULLET_SCENE: PackedScene       = preload("res://scenes/Bullet.tscn")
const HEAVY_BULLET_SCENE: PackedScene = preload("res://scenes/HeavyBullet.tscn")

## Spread angle offset in radians between each of the 3 spread bullets (~20°).
const SPREAD_ANGLE: float = 0.35

@export var shoot_cooldown_seconds: float = 0.25
@export var powerup_duration_seconds: float = 10.0

var _is_alive: bool = true
var _active_powerup: int = POWERUP_NONE
var _facing_direction: Vector2 = Vector2.RIGHT  # last snapped facing dir; used for shooting
var _powerup_timer: Timer
var _shoot_cooldown: float = 0.0


func _ready() -> void:
	# Layer 1 = players; mask layer 4 = obstacles (physics collision only)
	collision_layer = 1
	collision_mask = 8

	_powerup_timer = Timer.new()
	_powerup_timer.one_shot = true
	_powerup_timer.timeout.connect(_on_powerup_expired)
	add_child(_powerup_timer)

	_setup_collision_shape()
	_create_placeholder_sprite()
	_apply_player_color()

func _physics_process(delta: float) -> void:
	if not _is_alive:
		return
	if _shoot_cooldown > 0.0:
		_shoot_cooldown -= delta
	velocity = _read_movement_input() * movement_speed
	move_and_slide()
	_clamp_position_to_screen()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_alive:
		return
	if not event.is_action_pressed("p%d_action" % player_index):
		return
	match _active_powerup:
		POWERUP_SHOOT:  _try_shoot()
		POWERUP_SPREAD: _try_shoot_spread()

## Reads this player's directional actions and returns a normalized movement vector.
## Also rotates the sprite to face the nearest of the 8 cardinal/diagonal directions.
func _read_movement_input() -> Vector2:
	var direction := Vector2(
		Input.get_axis("p%d_move_left" % player_index, "p%d_move_right" % player_index),
		Input.get_axis("p%d_move_up"   % player_index, "p%d_move_down"  % player_index)
	)
	var result := direction.normalized() if direction.length_squared() > 0.0 else Vector2.ZERO
	if result != Vector2.ZERO:
		_face_direction(result)
	return result

## Snaps the sprite rotation to the nearest 45° step and stores the snapped direction
## vector so shooting always fires along a clean diagonal or cardinal direction.
func _face_direction(dir: Vector2) -> void:
	var snapped_angle: float = round(dir.angle() / (PI / 4.0)) * (PI / 4.0)
	$Sprite2D.rotation = snapped_angle + (PI / 2.0)
	_facing_direction = Vector2.from_angle(snapped_angle)

## Keeps the player inside the visible screen area.
func _clamp_position_to_screen() -> void:
	var screen_size := get_viewport_rect().size
	position.x = clamp(position.x, PLAYER_HALF_SIZE, screen_size.x - PLAYER_HALF_SIZE)
	position.y = clamp(position.y, PLAYER_HALF_SIZE, screen_size.y - PLAYER_HALF_SIZE)

## Tints the player node to visually distinguish the two players.
func _apply_player_color() -> void:
	pass
	#modulate = Color(0.4, 0.6, 1.0) if player_index == 0 else Color(1.0, 0.4, 0.4)

## Builds a 32×32 rectangle collision shape at runtime.
func _setup_collision_shape() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 28.0)
	$CollisionShape2D.shape = shape

## Creates a solid white 32×32 texture at runtime as a placeholder for future pixel art.
## Replace $Sprite2D.texture with a real texture when assets are ready.
func _create_placeholder_sprite() -> void:
	var offset := player_index * 16
	
	$Sprite2D.texture = $Sprite2D.texture.duplicate()
	$Sprite2D.texture.region = Rect2(offset, 16, 16, 16)
	
	$Sprite2D/GunSprite.texture = $Sprite2D/GunSprite.texture.duplicate()
	$Sprite2D/GunSprite.texture.region = Rect2(offset, 0, 16, 16)

## Called by PowerupPickup when this player walks over it.
func collect_powerup(powerup_type: int) -> void:
	if powerup_type == 0:
		$Sprite2D/GunSprite.show()
	_active_powerup = powerup_type
	_powerup_timer.start(powerup_duration_seconds)
	print("Player %d collected powerup %d" % [player_index, powerup_type])

## Fires one bullet from just in front of the player in the current facing direction.
## The bullet is added to GameWorld (parent) so it exists in world space.
func _try_shoot() -> void:
	if _shoot_cooldown > 0.0:
		return
	_shoot_cooldown = shoot_cooldown_seconds
	var bullet: Area2D = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	# Offset spawn point past the player's edge to avoid self-collision
	var spawn_pos := global_position + _facing_direction * (PLAYER_HALF_SIZE + 10.0)
	bullet.activate(spawn_pos, _facing_direction)

## Fires 3 heavy bullets in a fan: center, +SPREAD_ANGLE, and -SPREAD_ANGLE.
func _try_shoot_spread() -> void:
	if _shoot_cooldown > 0.0:
		return
	_shoot_cooldown = shoot_cooldown_seconds
	for angle_offset in [-SPREAD_ANGLE, 0.0, SPREAD_ANGLE]:
		var spread_dir := _facing_direction.rotated(angle_offset)
		var spawn_pos  := global_position + spread_dir * (PLAYER_HALF_SIZE + 10.0)
		var bullet: Area2D = HEAVY_BULLET_SCENE.instantiate()
		get_parent().add_child(bullet)
		bullet.activate(spawn_pos, spread_dir)

## Clears the active powerup when its 10-second window expires.
func _on_powerup_expired() -> void:
	$Sprite2D/GunSprite.hide()
	_active_powerup = POWERUP_NONE
	print("Player %d: powerup expired" % player_index)

## Kills this player: stops movement, emits the signal, and plays a flash effect.
func die() -> void:
	if not _is_alive:
		return  # guard against double-death (e.g. hit line and bullet simultaneously)
	_is_alive = false
	print("Player %d died!" % player_index)
	GameEvents.player_died.emit(player_index)
	_play_death_flash()

## Flashes the player's opacity three times to signal death without a full game-over screen.
func _play_death_flash() -> void:
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "modulate:a", 0.0, 0.08)
	tween.tween_property(self, "modulate:a", 1.0, 0.08)
