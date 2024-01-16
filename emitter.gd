extends Node3D

# Variables
var subsceneInstance = preload("res://Particle.tscn")
var spawnTimer: Timer
var maxParticles: int = 50  # Maximum number of particles

# Data texture to store particle positions
var dataTexture: Image = Image.create(1024, 1, false, Image.FORMAT_RGBAF)
var tc: ImageTexture;

func _ready():
    # Create and configure the timer
    tc = ImageTexture.new()
    tc.set_image(dataTexture)
    spawnTimer = Timer.new()
    spawnTimer.wait_time = randf_range(0.0, 0.1)  # Adjust the time range as needed
    spawnTimer.connect("timeout", _on_spawn_timer_timeout)
    add_child(spawnTimer)
    spawnTimer.start()

func _on_spawn_timer_timeout():
    var particleCount = len(get_children())
    if particleCount < maxParticles:
        var off = Vector3(randf_range(-10.0, 10.0), randf_range(0.0, 10.0), randf_range(-10.0, 10.0)) / 20.0
        var newSubscene = subsceneInstance.instantiate()
        newSubscene.position += off
        add_child(newSubscene)

    # Restart the timer with a new random interval
    spawnTimer.wait_time = randf_range(0.0, 0.05)
    spawnTimer.start()

func update_data_texture():
    # Map the position to data texture coordinates
    var i = 0;
    var last_child: Particle;
    for child in get_children():
        if !child is Particle:
            continue
        var pos = child.global_position
        var color: Color = Color(pos.x, pos.y, pos.z)
        dataTexture.set_pixel(i, 0, color)
        last_child = child;
        i += 1
    if last_child:
        tc.update(dataTexture)
        last_child.update_n_particles(i)
        last_child.set_particle_image(tc)
    

func _process(delta):
    update_data_texture()
    # Your existing code for processing particles
    pass

