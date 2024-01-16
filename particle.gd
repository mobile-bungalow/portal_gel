extends Node3D

class_name Particle;

# Define global variables for child nodes
var mesh_instance3d: MeshInstance3D
var area_3d: Area3D
# for proximity checks for the closest blobs
var collision_shape_3d: CollisionShape3D

@export var radius: float = 0.3;
@export var seed: float = 0.2;

func get_radius() -> float: 
    return radius

func set_particle_image(image: ImageTexture):
    var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    mat.set_shader_parameter("particles", image)

func update_n_particles(n: int):
    var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    mat.set_shader_parameter("n_particles", n)


# Called when the node enters the scene tree for the first time.
func _ready():
    # Reference the child nodes using get_node
    radius += randf_range(-0.03, 0.03);
    seed = randf_range(0, 100.0);
    mesh_instance3d = $MeshInstance3D
    var p = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    #p.set_shader_parameter("radius", radius);
    area_3d = $Area3D
    collision_shape_3d = $Area3D/CollisionShape3D
    area_3d.connect("body_entered", _on_area_body_entered)

func _process(delta):
    pass


func _on_area_body_entered(body):
    if body.is_in_group("breaks_fluid"):
        queue_free()
                    
