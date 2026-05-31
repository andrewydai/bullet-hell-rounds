extends Node2D

## Manages all obstacles: a symmetric static set placed at match start,
## random mid-game spawns on a timer, and player-placed obstacles via powerups.
## Stage 1: stub — correct structure established, logic deferred to Stage 2.

@export var static_obstacle_count: int = 4
@export var dynamic_spawn_interval_seconds: float = 30.0

func _ready() -> void:
	pass  # TODO Stage 2: spawn symmetric static obstacles around the screen center

## Called by PowerupManager when a player activates a TRAP or OBSTACLE powerup.
func place_obstacle_at(world_position: Vector2) -> void:
	
	GameEvents.obstacle_placed.emit(world_position)
