extends CharacterBody2D

const JUMP_VELOCITY: int = -680
const GRAVITY: int = 2600

var duck_collider_position_y: int = -25
var ducking: bool = false
var idle_collider_position_y: float = -33.5
var is_dead: bool = false
var is_playing: bool = false
var jumping: bool = false
var playing_position_x: int = 26

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var duck_collider_resource: Resource = preload("res://resources/dino/duck-collider.tres")
var idle_collider_resource: Resource = preload("res://resources/dino/idle-collider.tres")

signal dead
signal playing

func _physics_process(delta):
	if not is_on_floor():
		if ducking:
			velocity.y += 2.5 * GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta
	else:
		jumping = false

	if Input.is_action_pressed("jump") and is_on_floor() and not ducking:
		if is_dead:
			is_playing = true
			playing.emit()
		else:
			jumping = true
			velocity.y = JUMP_VELOCITY

		if not is_playing:
			await get_tree().create_timer(0.7).timeout
			var tween: Tween = create_tween()
			tween.tween_property(self, "position:x", playing_position_x, 0.3)
			animated_sprite.play("Run")
			await get_tree().create_timer(0.3).timeout
			is_playing = true
			playing.emit()

	if Input.is_action_pressed("duck") and is_playing:
		ducking = true
		collider.shape = duck_collider_resource
		collider.position.y = duck_collider_position_y
	else:
		ducking = false
		collider.shape = idle_collider_resource
		collider.position.y = idle_collider_position_y

	animate()
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i).get_collider()
		if collision.is_in_group("Obstacle"):
			is_dead = true
			is_playing = false
			dead.emit()
			animated_sprite.play("Die")

func animate():
	if ducking:
		animated_sprite.play("Duck")
	elif jumping:
		animated_sprite.play("Idle")
	elif is_playing:
		animated_sprite.play("Run")
