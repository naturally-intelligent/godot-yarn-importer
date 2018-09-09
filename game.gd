extends Node

var data = {}
var world = {}
var counters = {}

func _ready():
	init_game_data()
	
func init_game_data():
	# player
	data['first'] = 'Ihor'
	data['last'] = 'Motuz'
	data['full'] = data['first'] + ' ' + data['last']
	# stage
	data['stage'] = 1
	# world facts
	world = {}
	
#  WORLD FACT
func world_fact(fact):
	if fact in game.world:
		return game.world[fact]
	else:
		return false

func flip_world_fact(fact, default=false):
	if fact in game.world:
		game.world[fact] = not game.world[fact]
	else:
		game.world[fact] = default
	return game.world[fact]

func set_world_fact(fact, state):
	game.world[fact] = state
