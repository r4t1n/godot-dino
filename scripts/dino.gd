extends CharacterBody2D

const JUMP_VELOCITY: int = -580

var duck_collider_position_y: int = -25
var ducking: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var idle_collider_position_y: float = -33.5
var is_playing: bool = false
var jumping: bool = false
var playing_position_x: int = 24

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var duck_collider_resource: Resource = preload("res://resources/dino/duck-collider.tres")
var idle_collider_resource: Resource = preload("res://resources/dino/idle-collider.tres")

signal playing

func _physics_process(delta):
	if not is_on_floor():
		if ducking:
			velocity.y += 2.5 * gravity * delta
		else:
			velocity.y += gravity * delta
	else:
		jumping = false

	if Input.is_action_pressed("jump") and is_on_floor() and not ducking:
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

func animate():
	if ducking:
		animated_sprite.play("Duck")
	elif jumping:
		animated_sprite.play("Idle")
	elif is_playing:
		animated_sprite.play("Run")
