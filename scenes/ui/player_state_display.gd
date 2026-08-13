extends Panel

func _on_player_on_player_state_frame(frame_state: PlayerActor.State) -> void:
	$Grounded.button_pressed = frame_state.is_on_floor
	$Skidding.button_pressed = frame_state.is_skidding
