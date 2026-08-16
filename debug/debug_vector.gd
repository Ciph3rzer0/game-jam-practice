class_name DebugVector
extends MeshInstance3D

@export var color := Color.RED
var _immediate_mesh := ImmediateMesh.new()

func _init() -> void:
	mesh = _immediate_mesh

func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material_override = material

func draw(origin: Vector3, direction: Vector3, length := 2.0) -> void:
	_immediate_mesh.clear_surfaces()
	if direction.is_zero_approx():
		return
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_immediate_mesh.surface_add_vertex(origin)
	_immediate_mesh.surface_add_vertex(origin + direction.normalized() * length)
	_immediate_mesh.surface_end()
