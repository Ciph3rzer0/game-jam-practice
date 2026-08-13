# player_frame_input.gd
class_name PlayerFrameInput
extends RefCounted

var move_vector: Vector2
var jump_pressed: bool
var jump_held: bool
var tick: int

static func capture(current_tick: int) -> PlayerFrameInput:
	var input := PlayerFrameInput.new()
	input.move_vector = Input.get_vector("pc_backward", "pc_forward", "pc_left", "pc_right", 0.2)
	input.jump_pressed = Input.is_action_just_pressed("pc_jump")
	input.jump_held = Input.is_action_pressed("pc_jump")
	input.tick = current_tick
	return input
