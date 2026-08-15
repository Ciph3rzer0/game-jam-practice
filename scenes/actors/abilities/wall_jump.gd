class_name WallJump
extends Ability

@export var JUMP_HEIGHT_MULTI := 1.0

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(state: PlayerActorState, delta: float) -> void:
	super.process_input(state, delta)
	
	if !state.is_on_floor and state.is_on_wall and state.frame_input.consume_jump_press():
		var wall_normal := actor.get_wall_normal()
		wall_normal.y = 0
		wall_normal = wall_normal.normalized()
		
		var jump_dir := (wall_normal + Vector3.UP).normalized()
		
		state.time_on_floor = 0
		state.last_jump = 0.0
		state.consecutive_jumps = 1
		actor.velocity = actor.JUMP_VELOCITY * JUMP_HEIGHT_MULTI * jump_dir
		
		await get_tree().process_frame
		actor.anim.speed_scale = 1
		actor.anim.play(&"wall-kick")
