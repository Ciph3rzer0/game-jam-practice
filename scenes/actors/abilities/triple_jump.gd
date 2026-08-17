class_name TripleJump
extends Ability

@export var JUMP_HEIGHT_MULTI := 1.5

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(_state: PlayerActorState, _delta: float) -> void:
	super.process_input(_state, _delta)
	
	if _state.is_on_floor and _state.consecutive_jumps >= 2 and _state.frame_input.consume_jump_press():
		_state.time_on_floor = 0
		_state.last_jump = 0.0
		_state.consecutive_jumps = 0
		actor.velocity.y = actor.JUMP_VELOCITY * JUMP_HEIGHT_MULTI
		
		# await get_tree().process_frame
		# actor.anim.speed_scale = 4
		# actor.anim.play(&"jump-combo-3-start")
		# await actor.anim.animation_finished
		# actor.anim.speed_scale = 1
		# actor.anim.play(&"jump-combo-3")
