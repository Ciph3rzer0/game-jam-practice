extends Node3D

@export var camera_target: PlayerActor

@export var CAMERA_HEIGHT := 4
@export var CAMERA_SPEED := 2.0
@export var ORBIT_SPEED := 1.0

func _physics_process(delta: float) -> void:
	if camera_target:
		
		var is_actor_moving_up: bool = camera_target.current_state.vertical_speed > 0
		var camera_target_offset_scale: float = 0 if is_actor_moving_up else 1
		var camera_target_offset = Vector3(0, CAMERA_HEIGHT, 0) * camera_target_offset_scale
		
		# LERP Camera *POSITION* towards target
		var target_pos = camera_target.global_position + camera_target_offset
		global_position = global_position.lerp(target_pos, CAMERA_SPEED * delta)
		%LakituCam.look_at(camera_target.global_position)
		
		# LERP Camera *ROTATION* towards target rotation
		var target_basis := camera_target.global_transform.basis.orthonormalized()
		global_transform.basis = global_transform.basis.orthonormalized().slerp(target_basis, ORBIT_SPEED * delta)
