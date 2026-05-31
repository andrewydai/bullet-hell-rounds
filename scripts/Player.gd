extends CharacterBody2D

## A player character. Instantiate twice in GameWorld with player_index 0 and 1.
## Player 0 → WASD + Space (or Joypad 0)
## Player 1 → Arrow keys + Enter (or Joypad 1)

@export var player_index: int = 0
@export var movement_speed: float = 200.0

## Half the sprite's pixel dimensions; used to clamp the player inside the screen.
const PLAYER_HALF_SIZE: float = 16.0

var _is_alive: bool = true

func _ready() -> void:
	# Layer 1 = players; mask layer 4 = obstacles (physics collision only)
	collision_layer = 1
	collision_mask = 8

	_setup_collision_shape()
	_create_placeholder_sprite()
	_apply_player_color()

func _physics_process(_delta: float) -> void:
	if not _is_alive:
		return
	velocity = _read_movement_input() * movement_speed
	move_and_slide()
	_clamp_position_to_screen()

## Reads this player's directional actions and returns a normalized movement vector.
func _read_movement_input() -> Vector2:
	var direction := Vector2(
		Input.get_axis("p%d_move_left" % player_index, "p%d_move_right" % player_index),
		Input.get_axis("p%d_move_up"   % player_index, "p%d_move_down"  % player_index)
	)
	return direction.normalized() if direction.length_squared() > 0.0 else Vector2.ZERO

## Keeps the player inside the visible screen area.
func _clamp_position_to_screen() -> void:
	var screen_size := get_viewport_rect().size
	position.x = clamp(position.x, PLAYER_HALF_SIZE, screen_size.x - PLAYER_HALF_SIZE)
	position.y = clamp(position.y, PLAYER_HALF_SIZE, screen_size.y - PLAYER_HALF_SIZE)

## Tints the player node to visually distinguish the two players.
func _apply_player_color() -> void:
	modulate = Color(0.4, 0.6, 1.0) if player_index == 0 else Color(1.0, 0.4, 0.4)

## Builds a 32×32 rectangle collision shape at runtime.
func _setup_collision_shape() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(28.0, 28.0)
	$CollisionShape2D.shape = shape

## Creates a solid white 32×32 texture at runtime as a placeholder for future pixel art.
## Replace $Sprite2D.texture with a real texture when assets are ready.
func _create_placeholder_sprite() -> void:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	$Sprite2D.texture = ImageTexture.create_from_image(image)

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
