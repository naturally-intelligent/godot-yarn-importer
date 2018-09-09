extends "res://yarn/yarn-importer.gd"

# An example extended class of "yarn-importer"
#
# It is recommended you create your own based on this example.
#
# It is easier to just tie "yarn-importer" directly into your scene,
#  but in time you will likely reuse this class many times, 
#  and it can grow overly complicated merged in your scene

var scene
var dialog
var choices

func connect_scene(parent, scene_dialog, scene_choices):
	scene = parent
	dialog = scene_dialog
	choices = scene_choices

func yarn_text_variables(text):
	if text.find('$') != -1:
		text = text.replace('$PlayerFirst', game.data['first'])
		text = text.replace('$PlayerLast', game.data['last'])
		text = text.replace('$PlayerFull', game.data['full'])
	return text

func story_setting(setting, value):
	pass

func say(text):
	scene.create_dialog(text)
	
func choice(text, marker):
	scene.create_choice(text, marker)

func logic(instruction, command):
	pass
	
func action(text):
	pass
	
func yarn_custom_logic(to):
	if not to in game.counters:
		game.counters[to] = 0
	game.counters[to] = game.counters[to] + 1
	scene.set_visit_label("STATS: You've visited '"+to+"' "+str(game.counters[to])+" times.")
	
func yarn_code_replace(code, parent='parent.', next_func="yarn_unravel"):
	code = .yarn_code_replace(code, parent, next_func)
	# replace convenience variables (examples)
	code = code.replace('if stage', "if game.data['stage']")
	code = code.replace("action(", parent+"action(")
	if code.find("fact['") != -1:
		if code.find("==") != -1:
			code = code.replace("fact['", "game.world_fact('")
			code = code.replace("']", "')")
		elif code.find("=") != -1:
			code = code.replace("fact['", "game.set_world_fact('")
			code = code.replace("'] = ", "', ")
			code = code + ")"
	return code
	