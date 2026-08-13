extends Control

func _on_player_controller_on_player_input_frame(frame_input: PlayerFrameInput) -> void:
	$Jump.button_pressed = frame_input.jump_held
	$Crouch.button_pressed = frame_input.crouch_held
