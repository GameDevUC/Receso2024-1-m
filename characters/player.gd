extends CharacterBody2D

# Animation names
const crouch = "crouch"
const idle = "idle"
const jump = "jump"
const movement = "movement"

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@onready var animated_sprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	animated_sprite.animation = idle
	animated_sprite.play()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if not Input.is_action_pressed("crouch"):
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			#animated_sprite.animation = jump
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			#animated_sprite.animation = movement
			if direction < 0: animated_sprite.flip_h = true
			else: animated_sprite.flip_h = false
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	else:
		#animated_sprite.animation = crouch
		velocity.x = move_toward(velocity.x, 0, SPEED)
		pass

	move_and_slide()
