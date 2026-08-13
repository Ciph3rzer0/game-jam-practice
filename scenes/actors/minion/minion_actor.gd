extends CharacterBody3D

@export var MAX_MOVE_SPEED := 8
@export var ACCELERATION := 12
@export var DRAG_ACCEL := 4

const PROGRESS_CHARS = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event:
		pass

func apply_input(frame_input: PlayerFrameInput, delta: float) -> void:
	var input_vector := frame_input.move_vector
	var move_vector := Vector3(input_vector.x, 0, input_vector.y)
	
	var move_accel : Vector3
	
	if input_vector.is_equal_approx(Vector2.ZERO):
		# Drag Force
		move_accel = -velocity * DRAG_ACCEL
	else:
		# Move Force
		move_accel = move_vector * ACCELERATION
	
	velocity += (move_accel) * delta
	
	var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	
	print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, velocity.length(), MAX_MOVE_SPEED, move_accel.length()])
	
	var horizontal := Vector3(velocity.x, 0, velocity.z)
	if horizontal.length() > MAX_MOVE_SPEED:
		horizontal = horizontal.normalized() * MAX_MOVE_SPEED
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	
	var look_at_target = global_position + velocity
	if !global_position.is_equal_approx(look_at_target):
		look_at(look_at_target, Vector3.UP)
	
	move_and_slide()
