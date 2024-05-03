extends CharacterBody2D

signal dead_signal

# Animation names
const idle = "idle"
const walk = "walk"
const run = "run"
const jump = "jump"
const fall = "fall"
const crouch = "crouch"

const BASE_SPEED = 300.0
const TRANSITION_SPEED = (1.8*BASE_SPEED)
const MAX_SPEED = (3*BASE_SPEED)
const JUMP_VELOCITY = -500.0
const TIEMPO1 = 0.3
const TIEMPO2 = 1.7
var current_speed = float(0)
var coyote_time = 0.1

const BASE_LIFE = 3

var life = BASE_LIFE
var dead = false

@onready var animated_sprite = $AnimatedSprite2D
var direction = 0
var speed_level = 0
var time_running = 0

var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func should_jump():
	return (coyote_time > 0)
	
func reduce_life(value = 1):
	life -= value
	if life <= 0:
		dead_signal.emit()



func _ready():
	animated_sprite.animation = idle
	animated_sprite.play()

func _physics_process(delta):
	if not dead:
		# Add the gravity.
		if not is_on_floor():
			coyote_time -= delta
			if velocity.y >= 0:
				animated_sprite.animation = fall
			velocity.y += gravity * delta
		else: coyote_time = 0.1

		if not Input.is_action_pressed("crouch"):			
			# Handle jump.
			if Input.is_action_pressed("jump") and (is_on_floor() or should_jump()):
				animated_sprite.animation = jump
				velocity.y = JUMP_VELOCITY
				jumping = true
			if not Input.is_action_pressed("jump") and not is_on_floor() and jumping == true:
				velocity.y = 0
				jumping = false

			# Get the input direction and handle the movement/deceleration.
			direction = Input.get_axis("move_left", "move_right")
			
			# Animations
			if is_on_floor() and not velocity.y < 0:
				if direction == 0:
					animated_sprite.animation = idle
					current_speed = 0
				else:
					if speed_level > 1:
						animated_sprite.animation = run
					else:
						animated_sprite.animation = walk
				
				
			if direction:
				if is_on_floor(): time_running += delta
				if time_running > 0:
					if current_speed == 0:
						current_speed = BASE_SPEED
					elif time_running > TIEMPO1 and BASE_SPEED <= current_speed and current_speed < TRANSITION_SPEED:
						current_speed += 0.1*BASE_SPEED
					elif time_running > TIEMPO2 and TRANSITION_SPEED <= current_speed and current_speed < MAX_SPEED:
						current_speed += 0.05*BASE_SPEED 
				if direction < 0: animated_sprite.flip_h = true
				else: animated_sprite.flip_h = false
				velocity.x = direction * current_speed
			else:
				velocity.x = move_toward(velocity.x, 0, BASE_SPEED*0.1)
				time_running = float(0)
				
		else:
			if not Input.is_action_pressed("jump") and not is_on_floor() and jumping:
				velocity.y = 0
				jumping = false
			velocity.y += gravity * delta
			animated_sprite.animation = crouch
			
			direction = Input.get_axis("move_left", "move_right")
			if direction:
				if is_on_floor(): time_running += delta
				if time_running > 0: current_speed = BASE_SPEED
				if direction < 0: animated_sprite.flip_h = true
				else: animated_sprite.flip_h = false
				velocity.x = direction * current_speed
			else: velocity.x = move_toward(velocity.x, 0, BASE_SPEED*0.1)

		move_and_slide()


func _on_dead_signal():
	dead = true
