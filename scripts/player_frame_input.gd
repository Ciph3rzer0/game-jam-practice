class_name PlayerFrameInput
extends RefCounted

var tick: int
var movement_stick_input: Vector2
var jump_pressed: bool
var jump_pressed_consumed: bool
var jump_held: bool
var jump_held_consumed: bool

var crouch_pressed: bool
var crouch_pressed_consumed: bool

var action_pressed: bool
var action_pressed_consumed: bool
var action_held: bool
var action_held_consumed: bool

var crouch_held: bool
var crouch_held_consumed: bool

static func capture(current_tick: int) -> PlayerFrameInput:
	var input := PlayerFrameInput.new()
	#input.movement_stick_input = Input.get_vector("pc_backward", "pc_forward", "pc_left", "pc_right", 0.2)
	## ****** input.movement_stick_input = Input.get_vector("pc_left", "pc_right", "pc_backward", "pc_forward", 0.2)
	input.movement_stick_input = Input.get_vector("pc_left", "pc_right", "pc_forward", "pc_backward", 0.2)
	input.jump_held = Input.is_action_pressed("pc_jump")
	input.jump_pressed = Input.is_action_just_pressed("pc_jump")
	input.crouch_pressed = Input.is_action_just_pressed("pc_crouch")
	input.crouch_held = Input.is_action_pressed("pc_crouch")
	input.action_pressed = Input.is_action_just_pressed("pc_action")
	input.action_held = Input.is_action_pressed("pc_action")
	input.tick = current_tick
	return input

func consume_jump_press() -> bool:
	if jump_pressed_consumed:
		return false
	
	jump_pressed_consumed = true
	
	return jump_pressed

func consume_jump_held() -> bool:
	if jump_held_consumed:
		return false
	
	jump_held_consumed = true
	
	return jump_held

func consume_crouch_press() -> bool:
	if crouch_pressed_consumed:
		return false
	
	crouch_pressed_consumed = true
	
	return crouch_pressed

func consume_crouch_held() -> bool:
	if crouch_held_consumed:
		return false
	
	crouch_held_consumed = true
	
	return crouch_held
