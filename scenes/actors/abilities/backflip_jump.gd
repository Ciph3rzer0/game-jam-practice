class_name BackflipJump
extends Ability

@export var JUMP_HEIGHT_MULTI := 2.0

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(state: PlayerActor.State, delta: float) -> void:
	super.process_input(state, delta)
	
	if state.is_on_floor and state.is_crouching and state.frame_input.consume_jump_press():
		state.time_on_floor = 0
		state.last_jump = 0.0
		state.consecutive_jumps += 1
		state.is_crouching = false
		state.is_crawling = false
		actor.velocity.y = actor.JUMP_VELOCITY * JUMP_HEIGHT_MULTI
		
		await get_tree().process_frame
		actor.anim.speed_scale = 1.5
		actor.anim.play(&"backflip")
