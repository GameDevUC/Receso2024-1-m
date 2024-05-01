extends CharacterBody2D

# Animation names
const idle = "idle"
const walk = "walk"
const run = "run"
const jump = "jump"
const fall = "fall"
const crouch = "crouch"

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var animated_sprite = $AnimatedSprite2D
var direction = 0
var speed_level = 0
var time_running = 0

var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	animated_sprite.animation = idle
	animated_sprite.play()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			animated_sprite.animation = fall
		velocity.y += gravity * delta

	if not Input.is_action_pressed("crouch"):			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
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
			else:
				if speed_level > 1:
					animated_sprite.animation = run
				else:
					animated_sprite.animation = walk
			
		if direction:
			if speed_level == 0: speed_level = 1
			if is_on_floor(): time_running += delta
			if time_running > 1 and speed_level < 3:
				time_running = 0
				speed_level += 1
			if direction < 0: animated_sprite.flip_h = true
			else: animated_sprite.flip_h = false
			velocity.x = direction * SPEED * speed_level
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			speed_level = 0
			
	else:
		if not Input.is_action_pressed("jump") and not is_on_floor() and jumping:
			velocity.y = 0
			jumping = false
		velocity.y += gravity * delta
		animated_sprite.animation = crouch
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
