class_name PlayerState
extends RefCounted

var move_vector_3d: Vector3
var is_on_floor: Vector3
var wall_contact: Vector3

# Mario skids if moving opposite of velocity
var skid_direction: Vector2

static func capture(input_frame: PlayerFrameInput, current_tick: int) -> PlayerState:
	var state := PlayerState.new()
	
	state.move_vector_3d = Vector3(state.input_vector.x, 0, state.input_vector.y)
	
	
	
	#var input := PlayerFrameInput.new()
	#input.move_vector = Input.get_vector("pc_backward", "pc_forward", "pc_left", "pc_right", 0.2)
	#input.jump_pressed = Input.is_action_just_pressed("pc_jump")
	#input.jump_held = Input.is_action_pressed("pc_jump")
	#input.crouch_pressed = Input.is_action_just_pressed("pc_crouch")
	#input.crouch_held = Input.is_action_pressed("pc_crouch")
	#input.tick = current_tick
	return state
