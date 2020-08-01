extends Node
#
# A YARN Importer for Godot
#
# Credits: 
# - Dave Kerr (http://www.naturallyintelligent.com)
# 
# Latest: https://github.com/naturally-intelligent/godot-yarn-importer
# 
# Yarn: https://github.com/InfiniteAmmoInc/Yarn
# Twine: http://twinery.org
# 
# Yarn: a ball of threads (Yarn file)
# Thread: a series of fibres (Yarn node)
# Fibre: a text or choice or logic (Yarn line)

var yarn = {}

# OVERRIDE METHODS
#
# called to request new dialog
func say(text):
	pass
	
# called to request new choice button
func choice(text, marker):
	pass

# called to request internal logic handling
func logic(instruction, command):
	pass
	
# called for each line of text
func yarn_text_variables(text):
	return text
	
# called when "settings" node parsed
func story_setting(setting, value):
	pass
	
# called for each node name
func yarn_custom_logic(to):
	pass

# called for each node name (after)
func yarn_custom_logic_after(to):
	pass

# START SPINNING YOUR YARN
#
func spin_yarn(file, start_thread = false):
	yarn = load_yarn(file)
	# Find the starting thread...
	if not start_thread:
		start_thread = yarn['start']
	# Load any scene-specific settings
	# (Not part of official Yarn standard)
	if 'settings' in yarn['threads']:
		var settings = yarn['threads']['settings']
		for fibre in settings['fibres']:
			var line = fibre['text']
			var split = line.split('=')
			var setting = split[0].strip_edges(true, true)
			var value = split[1].strip_edges(true, true)
			story_setting(setting, value)
	# First thread unravel...
	yarn_unravel(start_thread)

# Internally create a new thread (during loading)
func new_yarn_thread():
	var thread = {}
	thread['title'] = ''
	thread['kind'] = 'branch' # 'branch' for standard dialog, 'code' for gdscript
	thread['tags'] = [] # unused
	thread['fibres'] = []
	return thread

# Internally create a new fibre (during loading)
func new_yarn_fibre(line):
	# choice fibre
	if line.substr(0,2) == '[[':
		if line.find('|') != -1:
			var fibre = {}
			fibre['kind'] = 'choice'
			line = line.replace('[[', '')
			line = line.replace(']]', '')
			var split = line.split('|')
			fibre['text'] = split[0]
			fibre['marker'] = split[1]
			return fibre
	# logic instruction (not part of official Yarn standard)
	elif line.substr(0,2) == '<<':
		if line.find(':') != -1:
			var fibre = {}
			fibre['kind'] = 'logic'
			line = line.replace('<<', '')
			line = line.replace('>>', '')
			var split = line.split(':')
			fibre['instruction'] = split[0]
			fibre['command'] = split[1]
			#print(line, split[0], split[1])
			return fibre
	# text fibre
	var fibre = {}
	fibre['kind'] = 'text'
	fibre['text'] = line
	return fibre

# Create Yarn data structure from file (must be *.yarn.txt Yarn format)
func load_yarn(path):
	var yarn = {}
	yarn['threads'] = {}
	yarn['start'] = false
	yarn['file'] = path
	var file = File.new()
	file.open(path, file.READ)
	if file.is_open():
		# yarn reading flags
		var start = false
		var header = true
		var thread = new_yarn_thread()
		# loop
		while !file.eof_reached():
			# read a line
			var line = file.get_line()
			# header read mode
			if header:
				if line == '---':
					header = false
				else:
					var split = line.split(': ')
					if split[0] == 'title':
						var title_split = split[1].split(':')
						var thread_title = ''
						var thread_kind = 'branch'
						if len(title_split) == 1:
							thread_title = split[1]
						else:
							thread_title = title_split[1]
							thread_kind = title_split[0]
						thread['title'] = thread_title
						thread['kind'] = thread_kind
						if not yarn['start']:
							yarn['start'] = thread_title
			# end of thread
			elif line == '===':
				header = true
				yarn['threads'][thread['title']] = thread
				thread = new_yarn_thread()
			# fibre read mode
			else:
				var fibre = new_yarn_fibre(line)
				if fibre:
					thread['fibres'].append(fibre)
	else:
		print('ERROR: Yarn file missing: ', filename)
	return yarn

# Main logic for node handling
#
func yarn_unravel(to, from=false):
	yarn_custom_logic(to)
	if to in yarn['threads']:
		var thread = yarn['threads'][to]
		match thread['kind']:
			'branch':
				for fibre in thread['fibres']:
					match fibre['kind']:
						'text':
							var text = yarn_text_variables(fibre['text'])
							say(text)
						'choice':
							var text = yarn_text_variables(fibre['text'])
							choice(text, fibre['marker'])
						'logic':
							var instruction = fibre['instruction']
							var command = fibre['command']
							logic(instruction, command)
			'code':
				yarn_code(to)
	else:
		print('WARNING: Missing Yarn thread: ', to, ' in file ',yarn['file'])
	yarn_custom_logic_after(to)

#
# RUN GDSCRIPT CODE FROM YARN NODE - Special node = code:title
# - Not part of official Yarn standard
#
func yarn_code(title, run=true, parent='parent.', tabs="\t", next_func="yarn_unravel"):
	if title in yarn['threads']:
		var thread = yarn['threads'][title]
		var code = ''
		for fibre in thread['fibres']:
			match fibre['kind']:
				'text':
					var line = yarn_text_variables(fibre['text'])
					line = yarn_code_replace(line, parent, next_func)
					code += tabs + line + "\n"
				'choice':
					var line = parent+next_func+"('"+fibre['marker']+"')"
					print(line)
					code += tabs + line + "\n"
		if run:
			run_yarn_code(code)
		else:
			return code
	else:
		print('WARNING: Title missing in yarn ball: ', title)

# override to replace convenience variables
func yarn_code_replace(code, parent='parent.', next_func="yarn_unravel"):
	if code.find("[[") != -1:
		code = code.replace("[[", parent+next_func+"('")
		code = code.replace("]]", "')")
	code = code.replace("say(", parent+"say(")
	code = code.replace("choice(", parent+"choice(")
	return code

func run_yarn_code(code):
	var front = "extends Node\n"
	front += "func dynamic_code():\n"
	front += "\tvar parent = get_parent()\n\n"
	code = front + code
	#print("CODE BLOCK: \n", code)

	var script = GDScript.new()
	script.set_source_code(code)
	script.reload()

	#print("Executing code...")
	var node = Node.new()
	node.set_script(script)
	add_child(node)
	var result = node.dynamic_code()
	remove_child(node)

	return result

# EXPORTING TO GDSCRIPT
#
# This code may not be directly usable
# Use if you need an exit from Yarn

func export_to_gdscript():
	var script = ''
	script += "func start_story():\n\n"
	if 'settings' in yarn['threads']:
		var settings = yarn['threads']['settings']
		for fibre in settings['fibres']:
			var line = fibre['text']
			var split = line.split('=')
			var setting = split[0].strip_edges(true, true)
			var value = split[1].strip_edges(true, true)
			script += "\t" + 'story_setting("' + setting + '", "' + value + '")' + "\n"
	script += "\tstory_logic('" + yarn['start'] + "')\n\n"
	# story logic choice/press event
	script += "func story_logic(marker):\n\n"
	script += "\tmatch marker:\n"
	for title in yarn['threads']:
		var thread = yarn['threads'][title]
		match thread['kind']:
			'branch':
				var code = "\n\t\t'" + thread['title'] + "':"
				var tabs = "\n\t\t\t"
				for fibre in thread['fibres']:
					match fibre['kind']:
						'text':
							code += tabs + 'say("' + fibre['text'] + '")'
						'choice':
							code += tabs + 'choice("' + fibre['text'] + '", "' + fibre['marker'] + '")'
						'logic':
							code += tabs + 'logic("' + fibre['instruction'] + '", "' + fibre['command'] + '")'
				script += code + "\n"
			'code':
				var code = "\n\t\t'" + thread['title'] + "':"
				var tabs = "\n\t\t\t"
				code += "\n"
				code += yarn_code(thread['title'], false, '', "\t\t\t", "story_logic")
				script += code + "\n"
	# done
	return script

func print_gdscript_to_console():
	print(export_to_gdscript())

func save_to_gdscript(filename):
	var script = export_to_gdscript()
	# write to file
	var file = File.new()
	file.open(filename, file.WRITE)
	if not file.is_open():
		print('ERROR: Cant open file ', filename)
		return false
	file.store_string(script)
	file.close()

