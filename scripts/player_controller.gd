extends Node3D

@export var actor: CharacterBody3D

func _physics_process(delta: float) -> void:
	var frame_input := PlayerFrameInput.capture(Engine.get_physics_frames())
	actor.apply_input(frame_input, delta)
	actor.move_and_slide()
