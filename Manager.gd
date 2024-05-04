extends Node

var score = 0

@onready var player = %Player
@onready var enemies = $"../Enemies"
@onready var player_interface = %PlayerInterface

func add_points(points):
	score += points
	player_interface.get_node("ScoreText").get_node("Score").set_text(str(score))

func _ready():
	player_interface.get_node("ScoreText").get_node("Score").set_text(str(score))
	player_interface.get_node("LifeRepresentation").get_node("Life").set_text(str(player.life))
	for enemy in enemies.get_children():
		enemy.hit_player_signal.connect(_on_player_hitted)
		enemy.give_points_signal.connect(add_points)


func _process(delta):
	pass
	
func _on_player_hitted():
	player.reduce_life()
	player_interface.get_node("LifeRepresentation").get_node("Life").set_text(str(player.life))
