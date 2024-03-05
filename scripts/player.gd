extends CharacterBody2D

const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ducking: bool = false
var jumping: bool = false
var playing: bool = false
var playing_position_x: int = 24

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var duck_collider: Resource = preload("res://resources/dino/duck-collider.tres")
var idle_collider: Resource = preload("res://resources/dino/idle-collider.tres")
var idle_collider_position_y: float = -23.5
var duck_collider_position_y: int = -15

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumping = false

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumping = true
		velocity.y = JUMP_VELOCITY

		if not playing:
			await get_tree().create_timer(0.9).timeout
			var tween: Tween = create_tween()
			tween.tween_property(self, "position:x", playing_position_x, 0.25)
			playing = true
	
	if Input.is_action_pressed("duck") and is_on_floor() and playing:
		ducking = true
		collider.shape = duck_collider
		collider.position.y = duck_collider_position_y
	else:
		ducking = false
		collider.shape = idle_collider
		collider.position.y = idle_collider_position_y

	animate()
	move_and_slide()

func animate():
	if playing:
		if ducking:
			animated_sprite.play("Duck")
		elif jumping:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("Run")
