extends Node3D

@export var actor: CharacterBody3D
@export var MAX_MOVE_SPEED := 10
@export var ACCELERATION := 30
@export var DRAG_ACCEL := 6

const PROGRESS_CHARS = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("pc_backward", "pc_forward", "pc_left", "pc_right", 0.2)
	var move_vector := Vector3(input_vector.x, 0, input_vector.y)
	
	var move_accel : Vector3
	
	if input_vector.is_equal_approx(Vector2.ZERO):
		# Drag Force
		move_accel = -actor.velocity * DRAG_ACCEL
	else:
		# Move Force
		move_accel = move_vector * ACCELERATION
	
	actor.velocity += (move_accel) * delta
	
	var PREFIX = PROGRESS_CHARS[(Time.get_ticks_msec() / 100) % PROGRESS_CHARS.size()]
	
	print("%s SPEED: %5.2f / %d.  Move: %5.2f" % [PREFIX, actor.velocity.length(), MAX_MOVE_SPEED, move_accel.length()])
	
	var horizontal := Vector3(actor.velocity.x, 0, actor.velocity.z)
	if horizontal.length() > MAX_MOVE_SPEED:
		horizontal = horizontal.normalized() * MAX_MOVE_SPEED
		actor.velocity.x = horizontal.x
		actor.velocity.z = horizontal.z
	
	var look_at_target = actor.global_position + actor.velocity
	if !actor.global_position.is_equal_approx(look_at_target):
		actor.look_at(look_at_target, Vector3.UP)
	
	actor.move_and_slide()
