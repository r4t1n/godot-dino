extends Node2D

const ACCELERATION: float = 0.04
const OUT_OF_BOUNDS_POSITION_X: int = -725
const CACTUS_SMALL_POSITION_Y: float = -27.5
const CACTUS_TIMER_MAX_WAIT_TIME: int = 24
const CACTUS_TIMER_MIN_WAIT_TIME: int = 12
const CLOUD_TIMER_MAX_WAIT_TIME: int = 48
const CLOUD_TIMER_MIN_WAIT_TIME: int = 32
const CLOUD_SPEED: float = 0.1

var cactus_timer_started: bool = false
var cloud_timer_started: bool = false
var is_playing: bool = false
var speed: float = 6

@onready var background: ParallaxBackground = $Background
@onready var cacti: Node2D = $Cacti
@onready var cactus_timer: Timer = $CactusTimer
@onready var clouds: Node2D = $Clouds
@onready var cloud_timer: Timer = $CloudTimer

var cactus_scene: PackedScene = preload("res://scenes/cactus.tscn")
var cloud_scene: PackedScene = preload("res://scenes/cloud.tscn")

func _process(delta):
	if is_playing:
		speed += ACCELERATION * delta
		background.scroll_base_offset.x -= speed
		
		if not cactus_timer_started:
			cactus_timer.wait_time = cactus_timer_wait_time()
			cactus_timer.start()
			cactus_timer_started = true
		
		if not cloud_timer_started:
			cloud_timer.wait_time = cloud_timer_wait_time()
			cloud_timer.start()
			cloud_timer_started = true

		for cactus in cacti.get_children():
			cactus.position.x -= speed
			if cactus.position.x < OUT_OF_BOUNDS_POSITION_X:
				cactus.queue_free()
		
		for cloud in clouds.get_children():
			cloud.position.x -= speed * CLOUD_SPEED
			if cloud.position.x < OUT_OF_BOUNDS_POSITION_X:
				cloud.queue_free()

func cactus_timer_wait_time() -> float:
	return randf_range(CACTUS_TIMER_MIN_WAIT_TIME, CACTUS_TIMER_MAX_WAIT_TIME) / speed

func cloud_timer_wait_time() -> float:
	return randf_range(CLOUD_TIMER_MIN_WAIT_TIME, CLOUD_TIMER_MAX_WAIT_TIME) / speed

func spawn_cactus():
	var cactus_instance: Node = cactus_scene.instantiate()
	var cactus_collider: CollisionShape2D = cactus_instance.get_node("CollisionShape2D")
	var cactus_sprite: Sprite2D = cactus_instance.get_node("Sprite2D")
	var cactus_size: int = randi_range(0, 1)
	var cactus_number: int = randi_range(1, 3)
	cactus_collider.shape = load("res://resources/cactus/collisionshape2d/" + str(cactus_size) + str(cactus_number) + ".tres")
	cactus_sprite.texture = load("res://graphics/sprites/cactus/" + str(cactus_size) + str(cactus_number) + ".png")
	if cactus_size == 1:
		cactus_collider.position.y = CACTUS_SMALL_POSITION_Y
		cactus_sprite.position.y = CACTUS_SMALL_POSITION_Y
	cacti.add_child(cactus_instance)

func spawn_cloud():
	var cloud_instance: Node = cloud_scene.instantiate()
	var cloud_position_y = randi_range(-75, -150)
	cloud_instance.position.y = cloud_position_y
	clouds.add_child(cloud_instance)

func _on_cactus_timer_timeout():
	spawn_cactus()
	cactus_timer.wait_time = cactus_timer_wait_time()
	cactus_timer.start()

func _on_cloud_timer_timeout():
	spawn_cloud()
	cloud_timer.wait_time = cloud_timer_wait_time()
	cloud_timer.start()

func _on_dino_playing():
	is_playing = true
