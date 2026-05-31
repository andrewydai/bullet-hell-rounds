extends Node

## Global game state singleton. Holds the current game phase and registers
## all player input actions at startup so project.godot stays clean.

enum State { WAITING, PLAYING, GAME_OVER }

var current_state: State = State.WAITING

func _ready() -> void:
	_setup_input_map()

func transition_to(new_state: State) -> void:
	current_state = new_state

## Registers all player input actions programmatically.
## Player 0: WASD + Space + Joypad 0
## Player 1: Arrow keys + Enter + Joypad 1
func _setup_input_map() -> void:
	_register_key_and_joy_axis("p0_move_up",    KEY_W,     0, JOY_AXIS_LEFT_Y, -1.0)
	_register_key_and_joy_axis("p0_move_down",  KEY_S,     0, JOY_AXIS_LEFT_Y,  1.0)
	_register_key_and_joy_axis("p0_move_left",  KEY_A,     0, JOY_AXIS_LEFT_X, -1.0)
	_register_key_and_joy_axis("p0_move_right", KEY_D,     0, JOY_AXIS_LEFT_X,  1.0)
	_register_key_and_joy_button("p0_action",   KEY_SPACE, 0, JOY_BUTTON_A)
	_register_key_and_joy_axis("p1_move_up",    KEY_UP,    1, JOY_AXIS_LEFT_Y, -1.0)
	_register_key_and_joy_axis("p1_move_down",  KEY_DOWN,  1, JOY_AXIS_LEFT_Y,  1.0)
	_register_key_and_joy_axis("p1_move_left",  KEY_LEFT,  1, JOY_AXIS_LEFT_X, -1.0)
	_register_key_and_joy_axis("p1_move_right", KEY_RIGHT, 1, JOY_AXIS_LEFT_X,  1.0)
	_register_key_and_joy_button("p1_action",   KEY_ENTER, 1, JOY_BUTTON_A)

func _register_key_and_joy_axis(
	action: String,
	key: Key,
	joy_device: int,
	joy_axis: JoyAxis,
	axis_value: float
) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)

	var joy_event := InputEventJoypadMotion.new()
	joy_event.device = joy_device
	joy_event.axis = joy_axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action, joy_event)

func _register_key_and_joy_button(
	action: String,
	key: Key,
	joy_device: int,
	joy_button: JoyButton
) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)

	var joy_event := InputEventJoypadButton.new()
	joy_event.device = joy_device
	joy_event.button_index = joy_button
	InputMap.action_add_event(action, joy_event)
