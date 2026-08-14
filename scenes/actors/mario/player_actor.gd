class_name PlayerActor
extends CharacterBody3D
signal on_player_state_frame(frame_state: PlayerActor.State)

const VEC3_XZ := Vector3(1, 0, 1)
const PROGRESS_CHARS := ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
const SKIDDING_ANGLE := cos(deg_to_rad(160))

@export var MAX_MOVE_SPEED := 8.0
@export var ACCELERATION := 12.0
@export var DRAG_ACCEL := 4.0
@export var JUMP_VELOCITY := 15.0
@export var GRAVITY_ACCEL := 2.0
@export var GRAVITY_MULTI_FALLING := 1.5
@export var GRAVITY_MULTI_HOLDING_JUMP := 0.5
@export var JUMP_CHAIN_WINDOW := 0.4
@export var TURN_SPEED := 2.0 # half-rotations/sec
@export var LOW_SPEED_TURN_MULTI := 6
@export var SPEED_LOSS_WHILE_MOVING_MULTI := 2.0 

@onready var anim: AnimationPlayer = get_node("mario/AnimationPlayer") as AnimationPlayer

var current_state: PlayerActor.State = State.new()

var current_speed: float
var target_speed: float
var current_rotation: float
var target_rotation: float

func _ready() -> void:
	assert(anim != null)

func collect_state(frame_input: PlayerFrameInput, delta: float) -> State:
	current_state =  State.capture(self, current_state, frame_input, delta)
	on_player_state_frame.emit(current_state)
	return current_state

func pre_process_input(frame_input: PlayerFrameInput, delta: float) -> void:
	var move_vector := Vector3(frame_input.move_vector.x, 0, frame_input.move_vector.y)
	
	# Translate movement based on camera view
	var camera = get_viewport().get_camera_3d()
	move_vector = move_vector.rotated(Vector3.UP, camera.global_rotation.y)
	
	# Is the player not holding any direction?
	var zero_move_input = frame_input.move_vector.is_equal_approx(Vector2.ZERO)
	
	#region Calculate Max Speed
	var CURRENT_MAX_SPEED: float
	
	if current_state.is_crawling:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED / 4.0
	else:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED
	#endregion
	
	#region Acceleration
	# Target Speed is determined by distance analog stick is pressed
	target_speed = frame_input.move_vector.length() * CURRENT_MAX_SPEED
	# Get current horizontal speed
	current_speed = (velocity * VEC3_XZ).length()
	
	var speed_diff := target_speed - current_speed
	var speed_change := clampf(absf(speed_diff), 0.0, ACCELERATION * delta) * signf(speed_diff)
	current_speed += speed_change
	#endregion
	
	## Calculate acceleration
	#var move_accel : Vector3
	#if zero_move_input:
		## Drag Force
		#move_accel = -velocity * VEC3_XZ * DRAG_ACCEL
	#if current_state.is_skidding:
		## Drag Force
		#move_accel = -velocity * VEC3_XZ * DRAG_ACCEL * 2
	#else:
		## Move Force
		#move_accel = move_vector * ACCELERATION
	
	#region Turning
	if !move_vector.is_zero_approx():
		var multi = clampf((1.0 - current_speed / MAX_MOVE_SPEED) * LOW_SPEED_TURN_MULTI, 1, LOW_SPEED_TURN_MULTI)

		var target_turn_angle = Transform3D().looking_at(move_vector, Vector3.UP).basis.get_euler().y
		var old_rotation = current_rotation
		current_rotation = rotate_toward(current_rotation, target_turn_angle, TURN_SPEED * multi * PI * delta)
		print(TURN_SPEED, "  -  ", TURN_SPEED * multi, " :: ", multi)
		
		var rotation_amount = abs(old_rotation-current_rotation)
		var velocity_lost = min(rad_to_deg(rotation_amount), TURN_SPEED) * delta * SPEED_LOSS_WHILE_MOVING_MULTI
		current_speed -= velocity_lost
		
	#endregion
	
	# Apply acceleration to velocity
	var horizontal := velocity * VEC3_XZ
	var direction := Vector3.FORWARD.rotated(Vector3.UP, current_rotation) if not zero_move_input else horizontal.normalized()
	if not direction.is_zero_approx():
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	
	var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	#print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, velocity.length(), CURRENT_MAX_SPEED, move_accel.length()])
	
	horizontal = velocity * VEC3_XZ
	if horizontal.length() > CURRENT_MAX_SPEED:
		horizontal = horizontal.normalized() * CURRENT_MAX_SPEED
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	elif zero_move_input and horizontal.length() < 6.0 / 60:
		velocity.x = 0
		velocity.z = 0
	
	#region Look At
	var look_at_target = velocity
	look_at_target.y = 0
	look_at_target += global_position
	
	if !global_position.is_equal_approx(look_at_target):
		look_at(look_at_target, Vector3.UP)
	#endregion
	
	#region Gravity
	var gravity_to_apply: float
	
	if velocity.y > 0:
		gravity_to_apply = GRAVITY_ACCEL
		if frame_input.jump_held:
			gravity_to_apply *= GRAVITY_MULTI_HOLDING_JUMP
	else:
		gravity_to_apply += GRAVITY_ACCEL * GRAVITY_MULTI_FALLING
	
	# Apply Gravity
	velocity.y -= gravity_to_apply
	#endregion
	
	move_and_slide()

func post_process_input(frame_input: PlayerFrameInput, delta: float) -> void:
	var horizontal = velocity * VEC3_XZ
	
		#region Calculate Max Speed
	var CURRENT_MAX_SPEED: float
	
	if current_state.is_crawling:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED / 4.0
	else:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED
	#endregion
	
	if current_state.is_crouching:
		anim.speed_scale = 1
		anim.play(&"crouching")
	elif current_state.is_crawling:
		anim.speed_scale = 1
		anim.play(&"crawling")
	elif current_state.is_skidding:
		anim.speed_scale = 1
		anim.play(&"quick-turn")
	elif is_on_floor():
		if horizontal.is_zero_approx():
			anim.speed_scale = 1
			anim.play(&"idle")
		elif velocity.length() < CURRENT_MAX_SPEED * 0.2:
			anim.speed_scale = (velocity.length() / CURRENT_MAX_SPEED) * 3
			anim.play(&"tiptoe")
		elif velocity.length() < CURRENT_MAX_SPEED * 0.7:
			anim.speed_scale = (velocity.length() / CURRENT_MAX_SPEED) * 3
			anim.play(&"walk")
		else:
			anim.speed_scale = (velocity.length() / CURRENT_MAX_SPEED) * 0.9
			anim.play(&"run")
	

class State extends RefCounted:
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

	static func capture(player: PlayerActor, previous_state: PlayerActor.State, frame_input: PlayerFrameInput, delta: float) -> State:
		var state = State.new()
		
		state.vertical_speed = (player.velocity * Vector3(0, 1, 0)).length()
		state.horizontal_speed = (player.velocity * Vector3(1, 0, 1)).length()
		
		#region STATE CARRYOVER
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
		var dot_val = player_horizontal_velocity.normalized().dot(frame_input.move_vector.normalized())
		
		if state.is_on_floor and dot_val < SKIDDING_ANGLE:
			state.is_skidding = true
		
		if state.is_on_floor and frame_input.crouch_held:
			if is_zero_approx(state.horizontal_speed):
				state.is_crouching = true
			else:
				state.is_crawling = true
		
		#endregion ### END FRAME INPUT PROCESSING ###
		
		return state
