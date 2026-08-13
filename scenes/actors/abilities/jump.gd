class_name Jump
extends Ability

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(_state: PlayerActor.State, _delta: float) -> void:
	super.process_input(_state, _delta)
	
	if _state.is_on_floor and _state.frame_input.consume_jump_press():
		print("JUMPING!")
		_state.time_on_floor = 0
		_state.last_jump = 0.0
		_state.consecutive_jumps += 1
		actor.velocity.y = actor.JUMP_VELOCITY
