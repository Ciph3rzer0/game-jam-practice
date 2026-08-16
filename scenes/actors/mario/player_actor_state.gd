class_name PlayerActorState extends RefCounted
var frame_input: PlayerFrameInput
var is_on_floor: bool
var is_on_wall: bool
var is_on_ceiling: bool

# Mario skids if moving opposite of velocity
#var skid_direction: Vector2
var is_skidding: bool
var is_crawling: bool
var is_crouching: bool

var last_jump: float
var time_on_floor: float
var consecutive_jumps: int

var vertical_speed: float

var horizontal_speed: float
var target_horizontal_speed: float

var current_rotation: float
var target_rotation: float

static func capture(player: PlayerActor, previous_state: PlayerActorState, frame_input: PlayerFrameInput, delta: float) -> PlayerActorState:
	var state = PlayerActorState.new()
	
	state.vertical_speed = (player.velocity * Vector3(0, 1, 0)).length()
	state.horizontal_speed = (player.velocity * Vector3(1, 0, 1)).length()
	
	#region STATE CARRYOVER
	state.vertical_speed = previous_state.vertical_speed
	state.horizontal_speed = previous_state.horizontal_speed
	state.target_horizontal_speed = previous_state.target_horizontal_speed
	state.current_rotation = previous_state.current_rotation
	state.target_rotation = previous_state.target_rotation
	# LAST JUMP
	state.last_jump = previous_state.last_jump + delta
	
	# TIME ON FLOOR
	if previous_state.is_on_floor:
		state.time_on_floor += previous_state.time_on_floor + delta
	else:
		state.time_on_floor = 0
	
	# CONSECUTIVE JUMPS
	if state.time_on_floor >= player.JUMP_CHAIN_WINDOW:
		state.consecutive_jumps = 0
	else:
		state.consecutive_jumps = previous_state.consecutive_jumps
	
	#endregion ### END STATE CARRYOVER ###
	
	#region FRAME INPUT PROCESSING
	state.frame_input = frame_input
	state.is_on_floor = player.is_on_floor()
	state.is_on_wall = player.is_on_wall()
	state.is_on_ceiling = player.is_on_ceiling()
	
	var player_horizontal_velocity = Vector2(player.velocity.x, player.velocity.z)
	
	# Normalize to get pure directions
	var dot_val = player_horizontal_velocity.normalized().dot(frame_input.movement_stick_input.normalized())
	
	if state.is_on_floor and dot_val < PlayerActor.SKIDDING_ANGLE:
		state.is_skidding = true
	
	if state.is_on_floor and frame_input.crouch_held:
		if is_zero_approx(state.horizontal_speed):
			state.is_crouching = true
		else:
			state.is_crawling = true
	#endregion ### END FRAME INPUT PROCESSING ###
	
	return state
