extends Node2D

const ACCELERATION: float = 0.1

var is_playing: bool = false
var speed: float = 8

@onready var level: ParallaxBackground = $Level
@onready var level_parallax_layer: ParallaxLayer = $Level/ParallaxLayer
@onready var cactus_scene: PackedScene = preload("res://scenes/cactus.tscn")
@onready var cactus_timer: Timer = $CactusTimer

var cactus_big_position_y: int = -35
var cactus_small_position_y: float = -27.5

func _process(delta):
	if is_playing:
		speed += ACCELERATION * delta
		level.scroll_base_offset.x -= speed

func _on_dino_playing():
	is_playing = true
