extends CharacterBody2D

const JUMP_VELOCITY: int = -500

var duck_collider_position_y: int = -25
var ducking: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
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

var silly_timer: bool = false
var timer: float = 0

func _physics_process(delta):
	if is_playing or is_dead: # Hack fix for colliders applying physics
		position.x = playing_position_x
		timer += delta

	if not is_on_floor():
		if ducking:
			velocity.y += 2.5 * gravity * delta
		else:
			velocity.y += gravity * delta
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
			silly_timer = true
			await get_tree().create_timer(0.6).timeout
			var tween: Tween = create_tween()
			tween.tween_property(self, "position:x", playing_position_x, 0.3)
			animated_sprite.play("Run")
			await get_tree().create_timer(0.25).timeout
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
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.name == "Cactus":
			is_dead = true
			is_playing = false
			dead.emit()
			animated_sprite.play("Die")
		if body.name == "GroundCollider" and silly_timer:
			silly_timer = false
			print(timer)

func animate():
	if ducking:
		animated_sprite.play("Duck")
	elif jumping:
		animated_sprite.play("Idle")
	elif is_playing:
		animated_sprite.play("Run")
