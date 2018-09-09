extends Control

onready var dialog = $PageVBox/PageHBox/DialogVBox/DialogScroll/Dialog/Margin/VBox
onready var choices = $PageVBox/PageHBox/ChoicesVBox/Choices/Margin/VBox

var yarn

func _ready():
	var yarn_gd = load('res://my-yarn.gd')
	yarn = yarn_gd.new()
	yarn.connect_scene(self, dialog, choices)
	yarn.spin_yarn('res://data/scene-example.yarn.txt')
	populate_settings()

func create_dialog(text):
	add_separator(dialog)
	var label = Label.new()
	label.set_text(text)
	label.autowrap = true
	dialog.add_child(label)
	# hack to autoscroll vbox
	$PageVBox/PageHBox/DialogVBox/DialogScroll.scroll_vertical = 10000
	
func create_choice(text, marker):
	var button = Button.new()
	button.set_text(text)
	button.connect('pressed', self, 'on_choice_press', [marker])
	choices.add_child(button)
	
func on_choice_press(marker):
	# clear old choices
	for child in choices.get_children():
		child.queue_free()
	# jump to next node
	yarn.yarn_unravel(marker)
	
func add_separator(to):
	if to.get_child_count()>0:
		var separator = HSeparator.new()
		to.add_child(separator)
	
func populate_settings():
	pass

func set_visit_label(text):
	$PageVBox/Bottom/VBoxContainer/VisitLabel.set_text(text)