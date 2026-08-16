class_name DebugVector
extends Node3D

@export var color := Color.RED
@export var thickness := 0.05       # shaft radius
@export var arrow_head := true
@export var head_radius := 0.15
@export var head_length := 0.3

var _shaft: MeshInstance3D
var _head: MeshInstance3D

func _init() -> void:
	_shaft = MeshInstance3D.new()
	_shaft.mesh = CylinderMesh.new()
	add_child(_shaft)

	_head = MeshInstance3D.new()
	_head.mesh = CylinderMesh.new()
	add_child(_head)

func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	_shaft.material_override = material
	_head.material_override = material
	visible = false

func draw(origin: Vector3, direction: Vector3, length := 2.0) -> void:
	if direction.is_zero_approx():
		visible = false
		return
	visible = true
	global_position = origin

	var dir := direction.normalized()
	# Quaternion's arc constructor has a known engine bug for exact antiparallel
	# input (Up -> Down gives a wrong result), which a straight-down velocity
	# vector will hit constantly. Handle it explicitly instead of trusting it.
	if dir.dot(Vector3.UP) < -0.9999:
		global_transform.basis = Basis(Vector3.RIGHT, PI)
	else:
		global_transform.basis = Basis(Quaternion(Vector3.UP, dir))

	var shaft_length: float = max(length - head_length, 0.01) if arrow_head else length

	var shaft_mesh: CylinderMesh = _shaft.mesh
	shaft_mesh.top_radius = thickness
	shaft_mesh.bottom_radius = thickness
	shaft_mesh.height = shaft_length
	_shaft.position = Vector3(0, shaft_length * 0.5, 0)

	_head.visible = arrow_head
	if arrow_head:
		var head_mesh: CylinderMesh = _head.mesh
		head_mesh.top_radius = 0.0
		head_mesh.bottom_radius = head_radius
		head_mesh.height = head_length
		_head.position = Vector3(0, shaft_length + head_length * 0.5, 0)
