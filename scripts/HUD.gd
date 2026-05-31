extends CanvasLayer

## Heads-up display overlay rendered above the game world.
## Stage 1: connects to player_died and prints a message.
## Stage 2+: will render powerup state, a game-over screen, etc.

func _ready() -> void:
	GameEvents.player_died.connect(_on_player_died)

func _on_player_died(player_index: int) -> void:
	print("HUD: Player %d died" % player_index)
	# TODO Stage 2: show game-over overlay and expose a restart button
