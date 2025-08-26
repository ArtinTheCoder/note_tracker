extends Control

@onready var root: Control = $"."
@onready var trackers_vbox: VBoxContainer = $TrackersScroll/TrackersVBox

var save_path = "user://"

var json_files = []
var agenda_titles_array = []

func _ready() -> void:
	get_files()
	get_agenda_title()
	set_agenda_title()
	connect_tracker_signal()
	
func get_files():
	var dir = DirAccess.open(save_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "json":
				json_files.append(file_name)
			file_name = dir.get_next()
		
	else:
		print("Can't access dir")

func get_agenda_title():
	for file_name in json_files:
		var file = FileAccess.open("user://" + str(file_name), FileAccess.READ)
		var content = file.get_as_text()
		file.close()
	
		var parse_result = JSON.parse_string(content)

		agenda_titles_array.append(parse_result["agenda_title"])

func set_agenda_title():
	var agenda_title_scene = load("res://scenes/agenda.tscn")
	
	for agenda in agenda_titles_array:
		var agenda_title = agenda_title_scene.instantiate()
		trackers_vbox.add_child(agenda_title)
		var title_label = agenda_title.get_node("PanelContainer/Label")
		title_label.text = str(agenda)

func connect_tracker_signal():
	for tracker in trackers_vbox.get_children():
		for child in tracker.get_children():
			if child is Button:
				child.pressed.connect(change_scene_to_tracker.bind(child.get_parent().get_instance_id()))
		
func change_scene_to_tracker(id):
	for tracker in trackers_vbox.get_children():
		if tracker.get_instance_id() == id:
			Global.selected_tracker_json_file = json_files[tracker.get_index()]
			Global.next_scene_path = "res://scenes/tracker.tscn"
			get_tree().change_scene_to_file("res://scenes/transition.tscn")
			
func _on_add_task_pressed() -> void:
	var tracker_name_scene = load("res://scenes/tracker_name.tscn")
	var tracker_name = tracker_name_scene.instantiate()
	root.add_child(tracker_name)
	
