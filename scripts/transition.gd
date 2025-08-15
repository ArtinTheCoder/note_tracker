extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_timer_timeout() -> void:
	animation_player.play_backwards("intro")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(Global.next_scene_path)
