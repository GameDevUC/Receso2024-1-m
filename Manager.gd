extends Node

var points = 0

@onready var player = %Player
@onready var enemies = $"../Enemies"

func add_points(points_value):
	points += points_value
	print("Points: " + str(points))

func _ready():
	for enemy in enemies.get_children():
		enemy.hit_player_signal.connect(_on_player_hitted)
		enemy.give_points_signal.connect(add_points)


func _process(delta):
	pass
	
func _on_player_hitted():
	player.reduce_life()
	print("Player hitted. Life: " + str(player.life))
