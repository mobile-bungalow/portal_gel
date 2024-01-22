extends Node3D

# Variables
var subsceneInstance = preload("res://Particle.tscn")
var decal_scene = preload("res://jelly_decal.tscn")
var first_decal
var spawnTimer: Timer
var maxParticles: int = 50  # Maximum number of particles

# Data texture to store particle positions
var dataTexture: Image = Image.create(1024, 1, false, Image.FORMAT_RGBAF)
var tc: ImageTexture

var splatPos: Image = Image.create(1024, 1, false, Image.FORMAT_RGBAF)
var splat_tex: ImageTexture
var splat_count: float = 0

# Circle motion parameters
var circleRadius: float = 30.0
var angularSpeed: float = 1.5
var angle: float = 0.0
var time = 0.0

var emitter: GPUParticles3D

func _ready():
    # Create and configure the timer
    tc = ImageTexture.new()
    tc.set_image(dataTexture)

    splat_tex = ImageTexture.new()
    splat_tex.set_image(splatPos)

    emitter = get_node("%splat_emitter")

    spawnTimer = Timer.new()
    spawnTimer.wait_time = randf_range(0.0, 0.1)  # Adjust the time range as needed
    spawnTimer.connect("timeout", _on_spawn_timer_timeout)
    add_child(spawnTimer)
    spawnTimer.start()

func _on_spawn_timer_timeout():
    var particleCount = len(get_children())
    if particleCount < maxParticles:
        var x = circleRadius * cos(angle)
        var z = circleRadius * sin(angle)
        var off = Vector3(randf_range(-10.0, 10.0) + x, randf_range(0.0, 10.0), randf_range(-10.0, 10.0) + z) / 20.0
        var newSubscene = subsceneInstance.instantiate()
        newSubscene.connect("spawn_decal", spawn_decal)
        newSubscene.connect("spawn_splat", spawn_splat)
        newSubscene.position += off;
        add_child(newSubscene)

    # Restart the timer with a new random interval
    spawnTimer.wait_time = randf_range(0.0, 0.05)
    spawnTimer.start()

func spawn_splat(pos: Vector3):
    if first_decal:
        #emitter.hide()
        var node = emitter.duplicate();
        emitter.position = pos;
        emitter.emitting = true;
        #emitter.show()
    pass

func spawn_decal(pos: Vector3):
    var color: Color = Color(pos.x, pos.y, pos.z, time)
    splatPos.set_pixel(splat_count, 0, color)
    splat_count += 1
    var newSubscene = decal_scene.instantiate()
    newSubscene.position = pos
    get_node("%decals").add_child(newSubscene)
    if not first_decal:
        first_decal = newSubscene
    else:
        newSubscene.not_first()

func update_data_texture():
    # Map the position to data texture coordinates
    var i = 0
    var last_child: Particle
    for child in get_children():
        if !child is Particle:
            continue
        var pos = child.global_position
        var color: Color = Color(pos.x, pos.y, pos.z)
        dataTexture.set_pixel(i, 0, color)
        last_child = child
        i += 1
    if first_decal:
        splat_tex.update(splatPos)
        first_decal.set_n_decals(splat_count)
        first_decal.set_pos_tex(splat_tex)
    if last_child:
        tc.update(dataTexture)
        last_child.update_n_particles(i)
        last_child.set_particle_image(tc)

func _process(delta):
    time += delta
    angle += angularSpeed * delta

    update_data_texture()
    # Your existing code for processing particles
    pass
