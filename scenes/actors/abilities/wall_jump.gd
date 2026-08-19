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
		
		var jump_vector = actor.JUMP_VELOCITY * JUMP_HEIGHT_MULTI * jump_dir
		actor.do_absolute_jump(jump_vector, &"wall-jump", 1)
