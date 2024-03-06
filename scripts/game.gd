extends Node2D

const ACCELERATION: float = 0.1
const MIN_SPAWN_INTERVAL_SECONDS: float = 0.5
const MAX_SPAWN_INTERVAL_SECONDS: float = 3.0

var is_playing: bool = false
var speed: float = 8

@onready var level: ParallaxBackground = $Level
@onready var level_parallax_layer: ParallaxLayer = $Level/ParallaxLayer
@onready var cactus_scene: PackedScene = preload("res://scenes/cactus.tscn")

var cactus_big_position_y: int = -35
var cactus_small_position_y: float = -27.5

func _process(delta):
	if is_playing:
		speed += ACCELERATION * delta
		level.scroll_base_offset.x -= speed
		var cactus_instance = cactus_scene.instantiate()
		level_parallax_layer.add_child(cactus_instance)

func calculate_spawn_interval() -> float:
	return lerp(MIN_SPAWN_INTERVAL_SECONDS, MAX_SPAWN_INTERVAL_SECONDS, speed / 20.0)

func _on_dino_playing():
	is_playing = true
