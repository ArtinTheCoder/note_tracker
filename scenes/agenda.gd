extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var delete_button: Button = $DeleteButton
@onready var panel_container_button: Button = $PanelContainer

var timer : Timer
var printed_once : bool = false
var button_disabled : bool = false

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1

	timer.one_shot = true
	add_child(timer)

	timer.timeout.connect(_on_timer_timeout)

func _on_panel_container_button_down() -> void:
	delete_button.hide()
	printed_once = false
	timer.start()
	
func _on_panel_container_button_up() -> void:
	timer.stop()
	button_disabled = true
	
	if printed_once:
		await get_tree().create_timer(1).timeout
		animation_player.play_backwards("delete_stayed")
		await animation_player.animation_finished
		delete_button.hide()
		button_disabled = false
		
func _on_timer_timeout():
	if not printed_once:
		printed_once = true
	
	delete_button.show()
	animation_player.play("delete_stayed")
	await animation_player.animation_finished
