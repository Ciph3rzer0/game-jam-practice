class_name PlayerActor
extends CharacterBody3D
signal on_player_state_frame(frame_state: PlayerActorState)

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

@export var show_debug_vectors := true

@onready var anim: AnimationPlayer = get_node("mario/AnimationPlayer") as AnimationPlayer
@onready var velocity_debug := DebugVector.new()
@onready var input_debug := DebugVector.new()

var current_state: PlayerActorState = PlayerActorState.new()

func _ready() -> void:
	assert(anim != null)
	velocity_debug.color = Color.RED
	input_debug.color = Color.CYAN
	
	await get_tree().process_frame
	get_tree().root.add_child(velocity_debug)
	get_tree().root.add_child(input_debug)
	
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## This Actor is controlled by PlayerController
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Player Controller Order of Operations
##  1. [      ] Collect Frame Input
##  2. [ self ] Pre Process Movement
##  3. [      ] Apply Movement
##  4. [ self ] Collect Player State
##  5. [      ] Process Abilities
##  6. [ self ] Post Actor Processes
##  7. [      ] Camera Control
## 

# ----------------------------------------
# Called **1st** in player_controller
# ----------------------------------------
# 1. Get mario's input vector
# 2. Calculate turn angle
# 3. Calculate turn speed reduction
# 4. Modify current_speed based on target_speed
#
func pre_process_input_and_collect_state(frame_input: PlayerFrameInput, delta: float) -> PlayerActorState:
	#region Pre Process Movement
	var movement_input_3d = get_movement_vector(frame_input.movement_stick_input)
	var stick_activation_percent = frame_input.movement_stick_input.length()
	var CURRENT_MAX_SPEED: float = get_max_speed()

	apply_acceleration(stick_activation_percent, CURRENT_MAX_SPEED, delta)
	apply_turning(movement_input_3d, delta)
	apply_acceleration_to_velocity(CURRENT_MAX_SPEED, frame_input.is_move_input_neutral)
	apply_look_at()
	apply_gravity(frame_input.jump_held)
	#endregion
	
	#region Debug
	if show_debug_vectors:
		velocity_debug.draw(global_position + Vector3.UP * 0.1, velocity * VEC3_XZ, (velocity * VEC3_XZ).length() / MAX_MOVE_SPEED * 2)
		input_debug.draw(global_position + Vector3.UP * 0.2, movement_input_3d, movement_input_3d.length())
	#endregion
	
	#region Apply Movement
	move_and_slide()
	#endregion

	#region Collect Player State
	current_state =  PlayerActorState.capture(self, current_state, frame_input, delta)
	on_player_state_frame.emit(current_state)
	return current_state
	#endregion

# ----------------------------------------
# Called **3rd** in player_controller
# ----------------------------------------
func post_process_input(frame_input: PlayerFrameInput, delta: float) -> void:
	var horizontal = velocity * VEC3_XZ
	
	var CURRENT_MAX_SPEED: float
	
	if current_state.is_crawling:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED / 4.0
	else:
		CURRENT_MAX_SPEED = MAX_MOVE_SPEED
	
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

##
## Get 3D Movement Vector from 2D input and camera transform
func get_movement_vector(move_vector_2d: Vector2) -> Vector3:
	var move_vector := Vector3(move_vector_2d.x, 0, move_vector_2d.y)
	
	# Translate movement based on camera view
	var camera = get_viewport().get_camera_3d()
	move_vector = move_vector.rotated(Vector3.UP, camera.global_rotation.y)
	return move_vector

##
## Get max speed based on actor state
func get_max_speed() -> float:
	if current_state.is_crawling:
		return MAX_MOVE_SPEED / 2.0
	else:
		return MAX_MOVE_SPEED

##
## Apply acceleration to actor
func apply_acceleration(acceleration_percent: float, max_speed: float, delta: float):
	# Target Speed is determined by distance analog stick is pressed
	current_state.target_horizontal_speed = acceleration_percent * max_speed
	# Get current horizontal speed
	current_state.horizontal_speed = (velocity * VEC3_XZ).length()
	
	var speed_diff := current_state.target_horizontal_speed - current_state.horizontal_speed
	var speed_change := clampf(absf(speed_diff), 0.0, ACCELERATION * delta) * signf(speed_diff)
	current_state.horizontal_speed += speed_change

##
## Apply turning to actor
func apply_turning(move_vector: Vector3, delta: float):
	if move_vector.is_zero_approx():
		return
	
	var multi = clampf((1.0 - current_state.horizontal_speed / MAX_MOVE_SPEED) * LOW_SPEED_TURN_MULTI, 1, LOW_SPEED_TURN_MULTI)

	var target_turn_angle = Transform3D().looking_at(move_vector, Vector3.UP).basis.get_euler().y
	var old_rotation = current_state.current_rotation
	current_state.current_rotation = rotate_toward(current_state.current_rotation, target_turn_angle, TURN_SPEED * multi * PI * delta)
	#print(TURN_SPEED, "  -  ", TURN_SPEED * multi, " :: ", multi)
	
	var rotation_amount = abs(old_rotation-current_state.current_rotation)
	var velocity_lost = min(rad_to_deg(rotation_amount), TURN_SPEED) * delta * SPEED_LOSS_WHILE_MOVING_MULTI
	current_state.horizontal_speed -= velocity_lost	

##
## Apply acceleration to velocity
func apply_acceleration_to_velocity(max_speed: float, is_move_input_neutral: bool):
	var horizontal := velocity * VEC3_XZ
	var direction := Vector3.FORWARD.rotated(Vector3.UP, current_state.current_rotation) if not is_move_input_neutral else horizontal.normalized()
	if not direction.is_zero_approx():
		velocity.x = direction.x * current_state.horizontal_speed
		velocity.z = direction.z * current_state.horizontal_speed
	
	# var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	#print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, velocity.length(), max_speed, move_accel.length()])
	
	horizontal = velocity * VEC3_XZ
	if horizontal.length() > max_speed:
		horizontal = horizontal.normalized() * max_speed
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	elif is_move_input_neutral and horizontal.length() < 6.0 / 60:
		velocity.x = 0
		velocity.z = 0

##
## Apply correct angle to actor
func apply_look_at():
	var look_at_target = velocity
	look_at_target.y = 0
	look_at_target += global_position
	
	if !global_position.is_equal_approx(look_at_target):
		
		# if !move_vector.is_zero_approx() and current_state.is_skidding:
		# 	# SKIDDING IS HARD TODO
		# 	look_at(global_position + Vector3(frame_input.move_vector.x, 0, frame_input.move_vector.y), Vector3.UP)
		look_at(look_at_target, Vector3.UP)

##
## Apply gravity to actor
func apply_gravity(is_jump_held: bool):
	var gravity_to_apply: float
	
	if velocity.y > 0:
		gravity_to_apply = GRAVITY_ACCEL
		if is_jump_held:
			gravity_to_apply *= GRAVITY_MULTI_HOLDING_JUMP
	else:
		gravity_to_apply += GRAVITY_ACCEL * GRAVITY_MULTI_FALLING
	
	# Apply Gravity
	velocity.y -= gravity_to_apply
