class_name PlayerActor
extends CharacterBody3D

signal on_player_state_frame(frame_state: PlayerActor.State)

@export var MAX_MOVE_SPEED := 8.0
@export var ACCELERATION := 12.0
@export var DRAG_ACCEL := 4.0
@export var JUMP_VELOCITY := 15.0
@export var GRAVITY_ACCEL := 2.0
@export var JUMP_CHAIN_WINDOW := 0.4

const PROGRESS_CHARS = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

@onready var anim: AnimationPlayer = get_node("mario/AnimationPlayer") as AnimationPlayer

var current_state: PlayerActor.State = State.new()

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
	
	# Calculate acceleration
	var move_accel : Vector3
	if zero_move_input:
		# Drag Force
		move_accel = -velocity * (Vector3.ONE - Vector3.UP) * DRAG_ACCEL
	else:
		# Move Force
		move_accel = move_vector * ACCELERATION
	
	# Apply acceleration to velocity
	velocity += (move_accel) * delta
	
	var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	#print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, velocity.length(), MAX_MOVE_SPEED, move_accel.length()])
	
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if horizontal.length() > MAX_MOVE_SPEED:
		horizontal = horizontal.normalized() * MAX_MOVE_SPEED
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	elif zero_move_input and horizontal.length() < 6.0 / 60:
		velocity.x = 0
		velocity.z = 0
	
	# Look at direction
	var look_at_target = velocity
	look_at_target.y = 0
	look_at_target += global_position
	
	if !global_position.is_equal_approx(look_at_target):
		look_at(look_at_target, Vector3.UP)
	
	var gravity_to_apply := 0.0
	
	if velocity.y < 0:
		gravity_to_apply += GRAVITY_ACCEL
	else:
		gravity_to_apply += GRAVITY_ACCEL * 1.5
	
	# Apply Gravity
	if frame_input.jump_held:
		gravity_to_apply -= GRAVITY_ACCEL * 0.5
	
	velocity.y -= gravity_to_apply
	
	if is_on_floor():
		if horizontal.is_zero_approx():
			anim.speed_scale = 1
			anim.play(&"idle")
		elif velocity.length() < MAX_MOVE_SPEED * 0.2:
			anim.speed_scale = (velocity.length() / MAX_MOVE_SPEED) * 3
			anim.play(&"tiptoe")
		elif velocity.length() < MAX_MOVE_SPEED * 0.7:
			anim.speed_scale = (velocity.length() / MAX_MOVE_SPEED) * 3
			anim.play(&"walk")
		else:
			anim.speed_scale = (velocity.length() / MAX_MOVE_SPEED) * 0.9
			anim.play(&"run")
	
	move_and_slide()

func post_process_input(frame_input: PlayerFrameInput, delta: float) -> void:
	pass

class State extends RefCounted:
	var frame_input: PlayerFrameInput
	var is_on_floor: bool
	var is_on_wall: bool
	var is_on_ceiling: bool

	# Mario skids if moving opposite of velocity
	#var skid_direction: Vector2
	var is_skidding: bool

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

		if dot_val < -0.95:
			#print("Pointing in the opposite direction!")
			state.is_skidding = true
		
		#endregion ### END FRAME INPUT PROCESSING ###
		
		return state
