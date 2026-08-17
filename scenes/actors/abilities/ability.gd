@abstract class_name Ability
extends Node

@onready var actor: PlayerActor = get_parent() as PlayerActor
@export var enabled := true

## Called once per physics tick, before actor.move_and_slide().
## Override to react to input and modify actor.velocity / state.
func process_input(_state: PlayerActorState, _delta: float) -> void:
	assert(_state.frame_input.tick == Engine.get_physics_frames(), "Processed wrong frame input")

### Called once per physics tick, after actor.move_and_slide().
### Override for abilities that care about the resulting collision state
### (e.g. wall-jump needs is_on_wall(), landing needs is_on_floor()).
#func process_after_move(frame_input: PlayerFrameInput, _delta: float) -> void:
	#pass
