extends Control

@export var task_line_edit: LineEdit
@export var completed_checkbox: CheckBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal task_edited
signal task_completed(task)

func _ready() -> void:
	task_line_edit.text_submitted.connect(task_edited.emit)
	task_line_edit.focus_exited.connect(task_edited.emit)
	completed_checkbox.toggled.connect(_on_check_box_toggled)
	animation_player.play("Spawn")

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
