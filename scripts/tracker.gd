extends Control

var task_scene = preload("res://scenes/task.tscn")

func _ready():
	await get_tree().create_timer(0.1).timeout
	for task in $"ScrollContainer/VBoxContainer/Tasks/VBoxContainer".get_children():
		task.task_completed.connect(move_task_to_finished)
		
func add_task():
	var task_instance = task_scene.instantiate()
	task_instance.task_completed.connect(move_task_to_finished)
	$ScrollContainer/VBoxContainer/Tasks/VBoxContainer.add_child(task_instance)

func _on_add_task_pressed() -> void:
	add_task()

func move_task_to_finished(task):
	var tasks_container = $"ScrollContainer/VBoxContainer/Tasks/VBoxContainer"
	var finished_tasks_container = $"ScrollContainer/VBoxContainer/FinishedTasks/VBoxContainer"

	if task.get_parent() == tasks_container:
		tasks_container.remove_child(task)
		finished_tasks_container.add_child(task)
		task.set_owner(get_tree().current_scene)
	
	else:
		finished_tasks_container.remove_child(task)
		tasks_container.add_child(task)
		task.set_owner(get_tree().current_scene)
