extends CharacterBody2D

signal dead_signal

# Animations names
const walk = "walk"
const dead_animation = "dead"

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var direction = 1
var dead = false

@onready var animated_sprite = $AnimatedSprite2D

@onready var ray_cast_direction = $RayCastDirection
@onready var ray_cast_up = $RayCastUp


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animated_sprite.animation = walk
	animated_sprite.play()
	if ray_cast_direction.target_position.x * direction < 0:
		ray_cast_direction.target_position.x *= -1
	
func _process(delta):
	if ray_cast_up.is_colliding() and not dead:
		direction = 0
		animated_sprite.animation = dead_animation
		dead = true
		$CollisionShape2D.disabled = true # DELETE THIS when throw added
		$LifeTime.start()
	
func _physics_process(delta):
	if not dead:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		if ray_cast_direction.is_colliding():
			direction *= -1
			ray_cast_direction.target_position.x *= -1
			
			if direction > 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
			
		velocity.x = direction * SPEED

		move_and_slide()


func _on_life_time_timeout():
	queue_free()