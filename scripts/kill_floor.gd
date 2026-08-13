extends Area3D

@export var player: CharacterBody3D
@export var respawn_point: Node3D

var _reset_pending := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body != player or _reset_pending:
		return

	_reset_pending = true
	_reset_player.call_deferred()


func _reset_player() -> void:
	if is_instance_valid(player) and is_instance_valid(respawn_point):
		player.global_transform = respawn_point.global_transform
		player.velocity = Vector3.ZERO

	_reset_pending = false
