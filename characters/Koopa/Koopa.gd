extends CharacterBody2D

signal dead_signal
signal hit_player_signal

# Animations names
const walk = "walk"
const dead_animation = "dead"
const atack_animation = "atack"

const SPEED = 250.0
const SLIDE_SPEED = 2 * SPEED
const JUMP_VELOCITY = -400.0

var direction = 1
var dead = false
var atacking = false

@onready var life_time = $LifeTime

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var dead_collision_shape = $DeadArea/CollisionShape2D

@onready var ray_cast_direction = $RayCastDirection
@onready var ray_cast_up = $RayCastUp
@onready var ray_cast_atack = $RayCastAtack


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	dead_collision_shape.disabled = true
	if direction > 0:
		animated_sprite.flip_h = true
	animated_sprite.animation = walk
	animated_sprite.play()
	if ray_cast_direction.target_position.x * direction < 0:
		ray_cast_direction.target_position.x *= -1
		
	if ray_cast_atack.target_position.x * direction < 0:
		ray_cast_atack.target_position.x *= -1
	
func _process(delta):
	if ray_cast_up.is_colliding() and not dead:
		direction = 0
		animated_sprite.animation = dead_animation
		dead = true
		collision_shape.disabled = true
		$ActiveDeadArea.start()
		life_time.start()

	
func _physics_process(delta):
	if not dead:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta

		if ray_cast_direction.is_colliding():
			if ray_cast_direction.get_collider().name == "Player":
				hit_player_signal.emit()
			direction *= -1
			ray_cast_direction.target_position.x *= -1
			ray_cast_atack.target_position.x *= -1
			
			if direction > 0:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
			
		if ray_cast_atack.is_colliding() or atacking:
			animated_sprite.animation = atack_animation
			velocity.x = direction * SLIDE_SPEED
			if not atacking:
				$AtackTime.start()
			atacking = true
		else:
			animated_sprite.animation = walk
			if not animated_sprite.is_playing():
				animated_sprite.play()
			velocity.x = direction * SPEED

		move_and_slide()
		
	else:
		if ray_cast_direction.is_colliding():
			if ray_cast_direction.get_collider().name == "Player":
				hit_player_signal.emit()
			direction *= -1
			ray_cast_direction.target_position.x *= -1
		velocity.x = direction * SLIDE_SPEED
		move_and_slide()


func _on_life_time_timeout():
	queue_free()	


func _on_animated_sprite_2d_frame_changed():
	if animated_sprite.animation == atack_animation and animated_sprite.frame == 1:
		animated_sprite.pause()


func _on_atack_time_timeout():
	atacking = false


func _on_dead_area_body_entered(body):
	if body.name == "Player" and not dead_collision_shape.disabled:
		collision_shape.disabled = false
		dead_collision_shape.disabled = true
		direction = randi_range(1, 2)
		if direction == 2:
			direction = -1
		life_time.start()
		


func _on_active_dead_area_timeout():
	dead_collision_shape.disabled = false
