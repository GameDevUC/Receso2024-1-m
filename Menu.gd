extends Node

# Path to main game
const path = "res://test_scene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarioAnimatedSprite.play("walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	get_tree().change_scene_to_file(path)
