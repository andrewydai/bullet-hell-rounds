extends Node

## Global signal bus. All game systems communicate through here to stay decoupled.

signal player_died(player_index: int)
signal powerup_collected(player_index: int, powerup_type: int)
signal obstacle_placed(position: Vector2)
