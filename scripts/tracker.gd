extends Control
var task_scene = preload("res://scenes/task.tscn")
@onready var active_tasks_container = $ScrollContainer/VBoxContainer/Tasks/VBoxContainer
@onready var finished_tasks_container = $ScrollContainer/VBoxContainer/FinishedTasks/VBoxContainer
const SAVE_PATH = "user://tasks.json"

func _ready():
	# Setup auto-save timer
	var save_timer = Timer.new()
	save_timer.wait_time = 20.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_tasks)
	add_child(save_timer)
	await get_tree().create_timer(0.1).timeout  # Ensure scene is ready before loading tasks
	load_tasks()
	
func add_task():
	var task_instance = task_scene.instantiate()
	active_tasks_container.add_child(task_instance)
	task_instance.task_completed.connect(move_task_to_finished)
	task_instance.task_edited.connect(save_tasks)
	task_instance.task_deleted.connect(delete_task)  # Connect the task_deleted signal
	
func _on_add_task_pressed():
	add_task()
	save_tasks()
	
func move_task_to_finished(task):
	var from_container = active_tasks_container if task.get_parent() == active_tasks_container else finished_tasks_container
	var to_container = finished_tasks_container if from_container == active_tasks_container else active_tasks_container
	
	from_container.remove_child(task)
	to_container.add_child(task)
	task.set_owner(get_tree().current_scene)
	save_tasks()

func delete_task(task):
	# Remove the task from its parent container
	if task.get_parent() == active_tasks_container:
		active_tasks_container.remove_child(task)
	elif task.get_parent() == finished_tasks_container:
		finished_tasks_container.remove_child(task)
	
	task.queue_free()
	
	# update the JSON file
	save_tasks()
	
func save_tasks():
	var tasks_data = []
	for task in active_tasks_container.get_children() + finished_tasks_container.get_children():
		if task.has_method("get_task_data"):
			var task_data = task.get_task_data()
			task_data["task_moved"] = task.get_parent() == finished_tasks_container
			tasks_data.append(task_data)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(tasks_data))
	print("Tasks saved!")
	
func load_tasks():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved tasks found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	
	for child in active_tasks_container.get_children() + finished_tasks_container.get_children():
		child.queue_free()
	for task_data in json.get_data():
		var new_task = task_scene.instantiate()
		var container = finished_tasks_container if task_data.get("task_moved", false) else active_tasks_container
		container.add_child(new_task)
		new_task.task_completed.connect(move_task_to_finished)
		new_task.task_edited.connect(save_tasks)
		new_task.task_deleted.connect(delete_task)  # Connect the deleted signal for loaded tasks
		new_task.set_task_data(task_data)
	print("Tasks loaded!")
	
func _on_save_button_pressed():
	save_tasks()
