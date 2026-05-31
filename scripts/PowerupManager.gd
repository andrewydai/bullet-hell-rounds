extends Node

## Manages powerup pickup spawning and zone-based distribution across the screen.
## Each pickup is non-stackable; collection assigns it to one player first-come first-served.
## Stage 1: stub — correct structure established, logic deferred to Stage 2.

enum PowerupType { SHOOT, TRAP, TURRET }

@export var spawn_interval_seconds: float = 15.0
@export var max_active_pickups: int = 3

func _ready() -> void:
	GameEvents.powerup_collected.connect(_on_powerup_collected)
	# TODO Stage 2: divide screen into spawn zones, start spawn timer

## Handles a player collecting a pickup. Assigns the powerup and starts its timer.
func _on_powerup_collected(player_index: int, _powerup_type: int) -> void:
	# TODO Stage 2: assign powerup to player, enforce non-stackable rule,
	#               start PowerupTimer, remove pickup from the world
	pass
