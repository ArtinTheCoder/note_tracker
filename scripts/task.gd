extends Control

@export var task_line_edit: LineEdit
@export var completed_checkbox: CheckBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal task_edited
signal task_completed(task)

var timer : Timer
var printed_once : bool = false

func _ready() -> void:
	task_line_edit.text_submitted.connect(task_edited.emit)
	task_line_edit.focus_exited.connect(task_edited.emit)
	completed_checkbox.toggled.connect(_on_check_box_toggled)
	animation_player.play("Spawn")

	timer = Timer.new()
	timer.wait_time = 0.5
	timer.one_shot = true
	add_child(timer)

	# Connect timer signal
	timer.timeout.connect(_on_timer_timeout)

func _on_check_box_toggled(_pressed: bool) -> void:
	task_completed.emit(self)
	task_edited.emit()

func get_task_data() -> Dictionary:
	return {
		"text": task_line_edit.text,
		"checkbox_ticked": completed_checkbox.button_pressed
	}

func set_task_data(data: Dictionary) -> void:
	task_line_edit.text = data.get("text", "")
	completed_checkbox.set_pressed_no_signal(data.get("checkbox_ticked", false))

func _on_panel_container_button_down() -> void:
	printed_once = false
	timer.start()
	
func _on_panel_container_button_up() -> void:
	timer.stop()
	if printed_once:
		animation_player.play_backwards("delete_stayed")
	
func _on_timer_timeout():
	if not printed_once:
		print("TIMER FINISHED")
		printed_once = true
	
	animation_player.play("delete")
	await animation_player.animation_finished
	
func _on_delete_button_pressed() -> void:
	print("delete")
