class_name Jump
extends Ability

@export var JUMP_HEIGHT_MULTI := 1.0

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(state: PlayerActorState, delta: float) -> void:
	super.process_input(state, delta)
	
	if state.is_on_floor and state.frame_input.consume_jump_press():
		var jump_vector = Vector3.UP * actor.JUMP_VELOCITY * JUMP_HEIGHT_MULTI
		actor.do_jump(jump_vector, &"jump-combo-1")
