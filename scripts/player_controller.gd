extends Node3D

## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Player Controller Order of Operations
##  1. Collect Frame Input
##  2. Pre Process Movement
##  3. Apply Movement
##  4. Collect Player State
##  5. Process Abilities
##  6. Post Actor Processes
##  7. Camera Control
## 

signal on_player_input_frame(frame_input: PlayerFrameInput)

@export var actor: PlayerActor
@export var camera: Lakitu

func _physics_process(delta: float) -> void:
	#region Collect Frame Inputs
	var frame_input := PlayerFrameInput.capture(Engine.get_physics_frames())
	on_player_input_frame.emit(frame_input)
	#endregion
	
	#region Pre Process Movement, Apply Movement, and Collect Player State
	var state: PlayerActorState = actor.pre_process_input_and_collect_state(frame_input, delta)
	#endregion


	#region Process Abilities
	var abilities: Array[Ability] = []
	abilities.assign(get_parent().find_children("*", "Ability", true, false))
	
	for ability in abilities:
		ability.process_input(state, delta)
	#endregion

	#region Post Actor Processes
	actor.post_process_input(frame_input, delta)
	#endregion
	
	#region Camera Control
	var cam_left = Input.is_action_just_pressed("camera_left")
	var cam_right = Input.is_action_just_pressed("camera_right")
	
	if cam_left:
		print("move left")
		camera.player_rotate_camera(-1.0/6 * PI)
	elif cam_right:
		camera.player_rotate_camera(1.0/6 * PI)
	#endregion
