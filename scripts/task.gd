extends Control

signal task_completed(task)

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("Spawn")
	
func _on_check_box_pressed() -> void:
	task_completed.emit(self) 

func _on_tree_exiting() -> void:
	animation_player.play("Spawn")
