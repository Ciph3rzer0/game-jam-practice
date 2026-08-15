extends Panel

func _on_player_on_player_state_frame(state: PlayerActorState) -> void:
	$Grounded.button_pressed = state.is_on_floor
	$Skidding.button_pressed = state.is_skidding
	$LastJump.text = "%4.2f" % state.last_jump
	$TimeOnFloor.text = "%4.2f" % state.time_on_floor
	$ConsecutiveJumps.text = "%d" % state.consecutive_jumps
