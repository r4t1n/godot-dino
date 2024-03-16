extends CharacterBody2D

const JUMP_VELOCITY: int = -680

var duck_collider_position_y: int = -25
var ducking: bool = false
var idle_collider_position_y: float = -33.5
var is_dead: bool = false
var is_playing: bool = false
var is_jumping: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var duck_collider_resource: Resource = preload("res://resources/dino/duck-collider.tres")
var idle_collider_resource: Resource = preload("res://resources/dino/idle-collider.tres")

signal jumping

func _physics_process(delta):
	if not is_on_floor():
		if ducking:
			velocity.y += 2.5 * gravity * delta
		else:
			velocity.y += gravity * delta
	else:
		is_jumping = false

	if is_playing:
		if Input.is_action_pressed("Jump") and is_on_floor() and not ducking:
			is_jumping = true
			jumping.emit()
			velocity.y = JUMP_VELOCITY

		if Input.is_action_pressed("Duck"):
			ducking = true
			collider.shape = duck_collider_resource
			collider.position.y = duck_collider_position_y
		else:
			ducking = false
			collider.shape = idle_collider_resource
			collider.position.y = idle_collider_position_y
	elif is_dead:
		velocity.y = 0

	animate()
	move_and_slide()

func animate():
	if is_playing:
		if ducking:
			animated_sprite.play("Duck")
		elif is_jumping:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("Run")
	elif is_dead:
		animated_sprite.play("Die")

func _on_game_dead():
	is_dead = true
	is_playing = false

func _on_game_playing():
	is_playing = true
	is_dead = false
