extends Node3D

signal 	on_player_input_frame(frame_input: PlayerFrameInput)

@export var actor: CharacterBody3D

func _physics_process(delta: float) -> void:
	var frame_input := PlayerFrameInput.capture(Engine.get_physics_frames())
	on_player_input_frame.emit(frame_input)
	actor.apply_input(frame_input, delta)
	actor.move_and_slide()
