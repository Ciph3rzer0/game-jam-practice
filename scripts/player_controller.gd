extends Node3D

signal on_player_input_frame(frame_input: PlayerFrameInput)

@export var actor: PlayerActor
@export var camera: Lakitu

func _physics_process(delta: float) -> void:
	var frame_input := PlayerFrameInput.capture(Engine.get_physics_frames())
	on_player_input_frame.emit(frame_input)
	
	# Pre Process Movement
	actor.pre_process_input(frame_input, delta)
	
	var state: PlayerActor.State = actor.collect_state(frame_input, delta)
	
	# Process Abilities
	var abilities: Array[Ability] = []
	abilities.assign(get_parent().find_children("*", "Ability", true, false))
	
	for ability in abilities:
		ability.process_input(state, delta)
	
	# Actor Processes
	actor.post_process_input(frame_input, delta)
	
	
	actor.move_and_slide()
	
	#region Camera Control
	var cam_left = Input.is_action_just_pressed("camera_left")
	var cam_right = Input.is_action_just_pressed("camera_right")
	
	if cam_left:
		print("move left")
		camera.player_rotate_camera(-1/6 * PI)
	elif cam_right:
		camera.player_rotate_camera(1/6 * PI)
	
	#endregion
