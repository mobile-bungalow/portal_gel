extends Node3D

var mesh_instance3d: MeshInstance3D

# only the first decal on any surface should render textures
func not_first():
	mesh_instance3d.visible = false;
    

func set_pos_tex(image: ImageTexture):
	var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
	mat.set_shader_parameter("position_tex", image)

func set_n_decals(n: int):
	var mat = mesh_instance3d.get_active_material(0) as ShaderMaterial;
	mat.set_shader_parameter("num_decals", n)

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_instance3d = $MeshInstance3D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
