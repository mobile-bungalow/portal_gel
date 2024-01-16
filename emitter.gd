extends Node3D

# Variables
var subsceneInstance = preload("res://Particle.tscn")
var spawnTimer: Timer

# Signal for surface and angle of impact
signal impact_detected(surface, angle)

func _ready():
    # Create and configure the timer
    spawnTimer = Timer.new()
    spawnTimer.wait_time = randf_range(0.0, 0.1)  # Adjust the time range as needed
    spawnTimer.connect("timeout", _on_spawn_timer_timeout)
    add_child(spawnTimer)
    spawnTimer.start()

func _on_spawn_timer_timeout():

    var off = Vector3(randf_range(-10.0, 10.0), randf_range(0.0, 10.0), randf_range(-10.0, 10.0)) / 40.0
    var newSubscene = subsceneInstance.instantiate()
    newSubscene.position +=  off
    add_child(newSubscene)

    # Restart the timer with a new random interval
    spawnTimer.wait_time = randf_range(0.0, 0.05)
    spawnTimer.start()

func _process(delta):
    # Your existing code for processing particles
    pass
