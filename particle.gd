extends Node3D

class_name Particle;

# Define global variables for child nodes
var mesh_instance3d: MeshInstance3D
var area_3d: Area3D
# for proximity checks for the closest blobs
var collision_shape_3d: CollisionShape3D


signal spawn_decal(pos: Vector3)
signal spawn_splat(pos: Vector3)

func set_particle_image(image: ImageTexture):
    var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    mat.set_shader_parameter("particles", image)

func update_n_particles(n: int):
    var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    mat.set_shader_parameter("n_particles", n)

# Called when the node enters the scene tree for the first time.
func _ready():
    # Reference the child nodes using get_node
    mesh_instance3d = $MeshInstance3D
    var p = mesh_instance3d.get_active_material(0) as ShaderMaterial;
    area_3d = $Area3D
    collision_shape_3d = $Area3D/CollisionShape3D
    area_3d.connect("body_entered", _on_area_body_entered)

func _process(delta):
    pass


func _on_area_body_entered(body):
    if body.is_in_group("breaks_fluid"):
        var overlapped_bodies = area_3d.get_overlapping_areas()
        var in_decal = false
        print("work")
        emit_signal("spawn_splat", position)
        for b in overlapped_bodies:
            if b.is_in_group("decals"):
                in_decal = true
        if not in_decal:
            emit_signal("spawn_decal", position)
        queue_free()			
