class_name Jump
extends Ability

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(_frame_input: PlayerFrameInput, _delta: float) -> void:
	super.process_input(_frame_input, _delta)
	
	if _frame_input.jump_pressed:
		print("JUMPING!")
		actor.velocity.y = actor.JUMP_VELOCITY
