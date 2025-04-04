extends Control
@export var task_line_edit: LineEdit  # Change this if you're using TextEdit instead
@export var completed_checkbox: CheckBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal task_edited
signal task_completed(task)

func _ready() -> void:
	task_line_edit.text_submitted.connect(_on_text_submitted)
	task_line_edit.focus_exited.connect(_on_focus_exited)
	completed_checkbox.toggled.connect(_on_check_box_toggled)
	animation_player.play("Spawn")

func _on_text_submitted(_new_text):
	task_edited.emit()
	
func _on_focus_exited():
	task_edited.emit()
	
func _on_check_box_toggled(button_pressed: bool) -> void:
	task_completed.emit(self)
	task_edited.emit()
	
func get_task_data() -> Dictionary:
	return {
		"text": task_line_edit.text,
		"completed": completed_checkbox.button_pressed
	}

func set_task_data(data: Dictionary) -> void:
	task_line_edit.text = data.get("text", "")
	# Set the checkbox state without triggering the toggled signal
	completed_checkbox.set_pressed_no_signal(data.get("completed", false))
