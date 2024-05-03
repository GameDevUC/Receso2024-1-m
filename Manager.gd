extends Node

@onready var player = %Player
@onready var enemies = $"../Enemies"

func _ready():
	for enemy in enemies.get_children():
		enemy.hit_player_signal.connect(_on_player_hitted)


func _process(delta):
	pass
	
func _on_player_hitted():
	player.reduce_life()
	print("Player hitted. Life: " + str(player.life))
