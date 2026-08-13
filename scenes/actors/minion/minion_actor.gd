class_name PlayerActor
extends CharacterBody3D

@export var MAX_MOVE_SPEED := 8.0
@export var ACCELERATION := 12.0
@export var DRAG_ACCEL := 4.0
@export var JUMP_VELOCITY := 15.0
@export var GRAVITY_ACCEL := 2.0

const PROGRESS_CHARS = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event:
		pass

func apply_input(frame_input: PlayerFrameInput, delta: float) -> void:
	var state = State.capture(self, frame_input, delta)
	var move_vector := Vector3(frame_input.move_vector.x, 0, frame_input.move_vector.y)
	
	# Calculate acceleration
	var move_accel : Vector3
	if frame_input.move_vector.is_equal_approx(Vector2.ZERO):
		# Drag Force
		move_accel = -velocity * DRAG_ACCEL
	else:
		# Move Force
		move_accel = move_vector * ACCELERATION
	
	# Apply acceleration to velocity
	velocity += (move_accel) * delta
	
	var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, velocity.length(), MAX_MOVE_SPEED, move_accel.length()])
	
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if horizontal.length() > MAX_MOVE_SPEED:
		horizontal = horizontal.normalized() * MAX_MOVE_SPEED
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	
	# Look at direction
	var look_at_target = velocity
	look_at_target.y = 0
	look_at_target += global_position
	
	if !global_position.is_equal_approx(look_at_target):
		look_at(look_at_target, Vector3.UP)
	
	# Apply Gravity
	velocity.y -= GRAVITY_ACCEL
	
	move_and_slide()

class State extends RefCounted:
	var is_on_floor: bool
	var is_on_wall: bool
	var is_on_ceiling: bool

	# Mario skids if moving opposite of velocity
	#var skid_direction: Vector2
	var is_skidding: bool

	static func capture(player: PlayerActor, frame_input: PlayerFrameInput, current_tick: int) -> State:
		var state = State.new()
		state.is_on_floor = player.is_on_floor()
		state.is_on_wall = player.is_on_wall()
		state.is_on_ceiling = player.is_on_ceiling()
		
		var player_horizontal_velocity = Vector2(player.velocity.x, player.velocity.z)
		
		# Normalize to get pure directions
		var dot_val = player_horizontal_velocity.normalized().dot(frame_input.move_vector.normalized())

		if dot_val < -0.95:
			print("Pointing in the opposite direction!")
			state.is_skidding = true
		
		#var input := PlayerFrameInput.new()
		#input.move_vector = Input.get_vector("pc_backward", "pc_forward", "pc_left", "pc_right", 0.2)
		#input.jump_pressed = Input.is_action_just_pressed("pc_jump")
		#input.jump_held = Input.is_action_pressed("pc_jump")
		#input.crouch_pressed = Input.is_action_just_pressed("pc_crouch")
		#input.crouch_held = Input.is_action_pressed("pc_crouch")
		#input.tick = current_tick
		return state
