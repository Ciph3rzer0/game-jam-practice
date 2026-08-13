extends Camera3D

@export var target: Node3D
@export_range(1.0, 12.0, 0.1) var distance := 3.8
@export_range(0.0, 4.0, 0.1) var target_height := 1.2
@export_range(0.0005, 0.02, 0.0005) var mouse_sensitivity := 0.003
@export_range(-80.0, 0.0, 1.0) var min_pitch_degrees := -20.0
@export_range(0.0, 85.0, 1.0) var max_pitch_degrees := 70.0

var _yaw := 0.0
var _pitch := deg_to_rad(30.0)
var _mouse_captured := false


func _ready() -> void:
	if target == null:
		target = get_parent_node_3d()

	if target == null:
		push_error("OrbitCamera needs a target Node3D.")
		set_process(false)
		set_process_unhandled_input(false)
		return

	# Keep the camera from inheriting the character's facing rotation.
	top_level = true
	_update_camera_position()


func _process(_delta: float) -> void:
	_update_camera_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_mouse_captured = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event.is_action_pressed("ui_cancel"):
		_mouse_captured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	if event is InputEventMouseMotion and _mouse_captured:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clampf(
			_pitch,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_mouse_captured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _update_camera_position() -> void:
	if not is_instance_valid(target):
		return

	var orbit_center := target.global_position + Vector3.UP * target_height
	var horizontal_distance := cos(_pitch) * distance
	var offset := Vector3(
		sin(_yaw) * horizontal_distance,
		sin(_pitch) * distance,
		cos(_yaw) * horizontal_distance
	)

	global_position = orbit_center + offset
	look_at(orbit_center, Vector3.UP)
