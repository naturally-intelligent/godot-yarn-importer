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
	