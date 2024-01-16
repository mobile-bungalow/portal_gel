extends Node3D

class_name Particle;

# Define global variables for child nodes
var mesh_instance3d: MeshInstance3D
var area_3d: Area3D
# for proximity checks for the closest blobs
var collision_shape_3d: CollisionShape3D


@export var radius: float = 0.1;
@export var seed: float = 0.2;


func get_radius() -> float: 
	return radius

# Called when the node enters the scene tree for the first time.
func _ready():
	# Reference the child nodes using get_node
	radius += randf_range(-0.03, 0.03);
	seed = randf_range(0, 100.0);
	mesh_instance3d = $MeshInstance3D
	mesh_instance3d.set_instance_shader_parameter("seed", seed)
	area_3d = $Area3D
	collision_shape_3d = $Area3D/CollisionShape3D
	area_3d.connect("body_entered", _on_area_body_entered)

# Function to set instance shader uniforms based on three points
func set_shader_uniforms(p1: Vector4, p2: Vector4, p3: Vector4, s1: float, s2: float, s3: float):
	# Assuming there is a shader material on the MeshInstance3D
	# Set the shader uniforms for points p1, p2, and p3
	mesh_instance3d.set_instance_shader_parameter("p1", p1)
	mesh_instance3d.set_instance_shader_parameter("p2", p2)
	mesh_instance3d.set_instance_shader_parameter("p3", p3)
	mesh_instance3d.set_instance_shader_parameter("seed1", s1)
	mesh_instance3d.set_instance_shader_parameter("seed2", s2)
	mesh_instance3d.set_instance_shader_parameter("seed3", s3)


func _process(delta):
	get_node("CollisionShape3D").shape.radius = radius
	mesh_instance3d.set_instance_shader_parameter("radius", radius)
	# Check for other Particle instances inside the Area3D
	var particles_inside: Array = area_3d.get_overlapping_areas()
	var closest_points: Array = []
	var seeds : Array = []
	# Find the three closest points if there are other particles
	particles_inside.sort_custom(_compare_distance)

	# Get the three closest points
	for i in range(0,particles_inside.size()):
		if (particles_inside[i].get_parent() is Particle):
			var pos: Vector3 = particles_inside[i].global_transform.origin
			var rad: float = particles_inside[i].get_parent().radius
			var seed: float = particles_inside[i].get_parent().seed
			closest_points.append(Vector4(pos[0], pos[1], pos[2], rad))
			seeds.append(seed)

	if (particles_inside.size() < 3):
		for i in range(particles_inside.size(),3):
			closest_points.append(Vector4(-100, -100, -100, 0.1))
			seeds.append(0)

	# Call set_shader_uniforms with the three closest points
	set_shader_uniforms(closest_points[0], closest_points[1], closest_points[2], seeds[0], seeds[1], seeds[2])

# Custom comparison function for sorting particles based on distance
func _compare_distance(a: Object, b: Object) -> int:
	var distance_a: float = self.transform.origin.distance_to(a.transform.origin)
	var distance_b: float = self.transform.origin.distance_to(b.transform.origin)
	
	if distance_a < distance_b:
		return -1
	elif distance_a > distance_b:
		return 1
	else:
		return 0



func _on_area_body_entered(body):
	if body.is_in_group("breaks_fluid"):
		queue_free()
					
