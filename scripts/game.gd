extends Node2D

const ACCELERATION: float = 0.04
const CACTUS_TIMER_MIN_WAIT_TIME: int = 16
const CACTUS_TIMER_MAX_WAIT_TIME: int = 32
const CACTUS_POSITION_THRESHOLD: int = -1300

var is_playing: bool = false
var speed: float = 8
var cactus_big_position_y: int = -35
var cactus_small_position_y: float = -27.5
var cactus_timer_started: bool = false
var cactus_positions: Dictionary = {}

@onready var level: ParallaxBackground = $Level
@onready var level_parallax_layer: ParallaxLayer = $Level/ParallaxLayer
@onready var cactus_timer: Timer = $CactusTimer

var cactus_scene: PackedScene = preload("res://scenes/cactus.tscn")

func _process(delta):
	if is_playing:
		speed += ACCELERATION * delta
		level.scroll_base_offset.x -= speed
		
		if not cactus_timer_started:
			cactus_timer.wait_time = cactus_timer_wait_time()
			cactus_timer.start()
			cactus_timer_started = true

		for child in level_parallax_layer.get_children():
			if cactus_positions.has(child):
				if level.scroll_base_offset.x < cactus_positions[child] + CACTUS_POSITION_THRESHOLD:
					child.queue_free()
	
		print(cactus_positions)

func cactus_timer_wait_time() -> float:
	return randf_range(CACTUS_TIMER_MIN_WAIT_TIME, CACTUS_TIMER_MAX_WAIT_TIME) / speed

func spawn_cactus():
	var cactus_instance: Node = cactus_scene.instantiate()
	cactus_positions[cactus_instance] = level.scroll_base_offset.x
	level_parallax_layer.add_child(cactus_instance)

func _on_cactus_timer_timeout():
	spawn_cactus()
	cactus_timer.wait_time = cactus_timer_wait_time()
	cactus_timer.start()

func _on_dino_playing():
	is_playing = true
