extends Control

@onready var root: Control = $"."

func _on_add_task_pressed() -> void:
	var tracker_name_scene = load("res://scenes/tracker_name.tscn")
	var tracker_name = tracker_name_scene.instantiate()
	root.add_child(tracker_name)
	
