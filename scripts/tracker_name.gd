extends Control

@onready var line_edit: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/LineEdit
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_button_pressed() -> void:
	Global.tracker_name = line_edit.text
	animation_player.play_backwards("intro")
	await animation_player.animation_finished
	
	Global.next_scene_path = "res://scenes/tracker.tscn"
	get_tree().change_scene_to_file("res://scenes/transition.tscn")
