extends Node2D

const ACCELERATION: float = 0.04
const CACTUS_OUT_OF_BOUNDS_POSITION_X: int = -725
const CACTUS_SMALL_POSITION_Y: float = -27
const CACTUS_TIMER_MAX_WAIT_TIME: int = 16
const CACTUS_TIMER_MIN_WAIT_TIME: int = 4
const CLOUD_TIMER_MAX_WAIT_TIME: int = 24
const CLOUD_TIMER_MIN_WAIT_TIME: int = 20
const CLOUD_SPEED: float = 0.15
const CLOUD_OUT_OF_BOUNDS_POSITION_X: int = -686
const POINT_INTERVAL: float = 0.1
const PLAYING_POSITION_X: int = 26
const JUMP_VELOCITY: int = -680

var cactus_timer_started: bool = false
var cloud_timer_started: bool = false
var is_dead: bool = false
var is_playing: bool = false
var playing_timer: float = 0
var points: int = 0
var speed: float = 6
var ones: int = 0
var tens: int = 0
var hundreds: int = 0
var thousands: int = 0
var ten_thousands: int = 0
var can_restart: bool = false
var is_night: bool = false
var has_started: bool = false

@onready var dino: CharacterBody2D = $Dino
@onready var dino_animated_sprite: AnimatedSprite2D = $Dino/AnimatedSprite2D
@onready var ground: ParallaxBackground = $Ground
@onready var cacti: Node2D = $Cacti
@onready var cactus_timer: Timer = $Timers/CactusTimer
@onready var clouds: Node2D = $Clouds
@onready var cloud_timer: Timer = $Timers/CloudTimer
@onready var game_over: Node2D = $UI/GameOver
@onready var game_over_restart: AnimatedSprite2D = $UI/GameOver/Restart
@onready var restart_timer: Timer = $Timers/RestartTimer
@onready var score_ones: Sprite2D = $UI/Score/Ones
@onready var score_tens: Sprite2D = $UI/Score/Tens
@onready var score_hundreds: Sprite2D = $UI/Score/Hundreds
@onready var score_thousands: Sprite2D = $UI/Score/Thousands
@onready var score_ten_thousands: Sprite2D = $UI/Score/TenThousands
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var cactus_scene: PackedScene = preload("res://scenes/cactus.tscn")
var cloud_scene: PackedScene = preload("res://scenes/cloud.tscn")
var hit_audio: AudioStreamWAV = preload("res://audio/hit.wav")
var press_audio: AudioStreamWAV = preload("res://audio/press.wav")
var reached_audio: AudioStreamWAV = preload("res://audio/reached.wav")

signal dead
signal playing

func _process(delta):
	if Input.is_action_pressed("Jump") and not has_started:
		has_started = true
		dino.velocity.y = JUMP_VELOCITY
		await get_tree().create_timer(0.65).timeout
		var tween: Tween = create_tween()
		tween.tween_property(dino, "position:x", PLAYING_POSITION_X, 0.35)
		dino_animated_sprite.play("Run")
		await get_tree().create_timer(0.35).timeout
		is_playing = true
		playing.emit()

	if is_playing:
		speed += ACCELERATION * delta
		ground.scroll_base_offset.x -= speed
		playing_timer += delta
		set_score()
		point_events()

		if not cactus_timer_started:
			cactus_timer.wait_time = cactus_timer_wait_time()
			cactus_timer.start()
			cactus_timer_started = true

		if not cloud_timer_started:
			_on_cloud_timer_timeout()
			cloud_timer_started = true

		for cactus in cacti.get_children():
			cactus.position.x -= speed
			if cactus.position.x < CACTUS_OUT_OF_BOUNDS_POSITION_X:
				cactus.queue_free()

		for cloud in clouds.get_children():
			cloud.position.x -= speed * CLOUD_SPEED
			if cloud.position.x < CLOUD_OUT_OF_BOUNDS_POSITION_X:
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
	cactus_instance.body_entered.connect(_on_cactus_body_entered)
	cacti.add_child(cactus_instance)

func spawn_cloud():
	var cloud_instance: Node = cloud_scene.instantiate()
	var cloud_position_y = randi_range(-75, -150)
	cloud_instance.position.y = cloud_position_y
	clouds.add_child(cloud_instance)

func set_score():
	points = int(playing_timer / POINT_INTERVAL)
	ones = points % 10
	tens = (points % 100) / 10
	hundreds = (points % 1000) / 100
	thousands = (points % 10000) / 1000
	ten_thousands = (points % 100000) / 10000
	score_ones.texture = load("res://graphics/text/numbers/" + str(ones) + ".png")
	score_tens.texture = load("res://graphics/text/numbers/" + str(tens) + ".png")
	score_hundreds.texture = load("res://graphics/text/numbers/" + str(hundreds) + ".png")
	score_thousands.texture = load("res://graphics/text/numbers/" + str(thousands) + ".png")
	score_ten_thousands.texture = load("res://graphics/text/numbers/" + str(ten_thousands) + ".png")

func point_events():
	if points == 700 and not is_night:
		is_night = true
		RenderingServer.set_default_clear_color(Color.BLACK)

func _on_cactus_body_entered(body):
	if body.name == "Dino":
		is_dead = true
		is_playing = false
		dead.emit()
		game_over.visible = true
		game_over_restart.play("Restart")
		restart_timer.start()
		audio_stream_player.stream = hit_audio
		audio_stream_player.play()

func _on_cactus_timer_timeout():
	spawn_cactus()
	cactus_timer.wait_time = cactus_timer_wait_time()
	cactus_timer.start()

func _on_cloud_timer_timeout():
	spawn_cloud()
	cloud_timer.wait_time = cloud_timer_wait_time()
	cloud_timer.start()

func _on_dino_jumping():
	audio_stream_player.stream = press_audio
	audio_stream_player.play()

func _on_restart_timer_timeout():
	can_restart = true
