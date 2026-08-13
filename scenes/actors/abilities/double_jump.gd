class_name DoubleJump
extends Ability

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(_state: PlayerActor.State, _delta: float) -> void:
	super.process_input(_state, _delta)
	
	if _state.is_on_floor and _state.frame_input.consume_jump_press():
		print("Double JUMPING!")
		actor.velocity.y = actor.JUMP_VELOCITY * 2
		
