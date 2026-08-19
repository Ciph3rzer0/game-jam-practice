class_name Dive
extends Ability

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(state: PlayerActorState, delta: float) -> void:
	super.process_input(state, delta)
	
	if state.is_on_floor and state.horizontal_speed > 1.0 and state.frame_input.consume_action_press():
		var jump_vector = actor.DIVE_VELOCITY_VECTOR.rotated(Vector3.UP, state.current_rotation)
		actor.do_jump(jump_vector, &"dive", 0)
