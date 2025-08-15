extends Control
var task_scene = preload("res://scenes/task.tscn")
@onready var active_tasks_container = $Tasks/VBoxContainer
@onready var finished_tasks_container = $FinishedTasks/VBoxContainer
@onready var agenda_title: LineEdit = $Title/TitleText
const SAVE_PATH = "user://tasks.json"

# Spacer references
var active_spacer: Control
var finished_spacer: Control

func _ready():
	# Setup auto-save timer
	var save_timer = Timer.new()
	save_timer.wait_time = 20.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_tasks)
	add_child(save_timer)
	
	# Create spacers first
	create_spacers()
	
	await get_tree().create_timer(0.1).timeout  # Ensure scene is ready before loading tasks
	load_tasks()

func create_spacers():
	# Create spacer for active tasks
	active_spacer = Control.new()
	active_spacer.name = "Spacer"
	active_spacer.custom_minimum_size = Vector2(0, 20)  # 20px height spacer
	active_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_tasks_container.add_child(active_spacer)
	
	# Create spacer for finished tasks
	finished_spacer = Control.new()
	finished_spacer.name = "Spacer"
	finished_spacer.custom_minimum_size = Vector2(0, 20)  # 20px height spacer
	finished_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	finished_tasks_container.add_child(finished_spacer)

func ensure_spacer_at_end(container: VBoxContainer, spacer: Control):
	# Remove spacer from current position
	if spacer.get_parent() == container:
		container.remove_child(spacer)
	
	# Add spacer at the end
	container.add_child(spacer)
	
func add_task():
	var task_instance = task_scene.instantiate()
	# Add task before the spacer (at second-to-last position)
	var insert_position = active_tasks_container.get_child_count() - 1
	active_tasks_container.add_child(task_instance)
	active_tasks_container.move_child(task_instance, insert_position)
	
	task_instance.task_completed.connect(move_task_to_finished)
	task_instance.task_edited.connect(save_tasks)
	task_instance.task_deleted.connect(delete_task)
	
	# Ensure spacer is at the end
	ensure_spacer_at_end(active_tasks_container, active_spacer)
	
func move_task_to_finished(task):
	var from_container = active_tasks_container if task.get_parent() == active_tasks_container else finished_tasks_container
	var to_container = finished_tasks_container if from_container == active_tasks_container else active_tasks_container
	var from_spacer = active_spacer if from_container == active_tasks_container else finished_spacer
	var to_spacer = finished_spacer if to_container == finished_tasks_container else active_spacer
	
	from_container.remove_child(task)
	to_container.add_child(task)
	
	# Move to the very top (index 0)
	to_container.move_child(task, 0)
	
	task.set_owner(get_tree().current_scene)
	
	# Ensure spacers are at the end of both containers
	ensure_spacer_at_end(from_container, from_spacer)
	ensure_spacer_at_end(to_container, to_spacer)
	
	save_tasks()

func delete_task(task):
	var parent_container = task.get_parent()
	
	# Remove the task from its parent container
	if parent_container == active_tasks_container:
		active_tasks_container.remove_child(task)
		ensure_spacer_at_end(active_tasks_container, active_spacer)
	elif parent_container == finished_tasks_container:
		finished_tasks_container.remove_child(task)
		ensure_spacer_at_end(finished_tasks_container, finished_spacer)
	
	task.queue_free()
	
	# update the JSON file
	save_tasks()
	
func get_real_tasks_from_container(container: VBoxContainer):
	# Filter out spacer objects when getting tasks
	var real_tasks = []
	for child in container.get_children():
		if child.name != "Spacer":
			real_tasks.append(child)
	return real_tasks
	
func save_tasks():
	# Create a data structure that includes both tasks and the title
	var save_data = {
		"agenda_title": agenda_title.text,  # Save the title text
		"tasks": [], # Array to hold task data
	}
	
	# Collect all tasks (excluding spacers)
	var all_real_tasks = get_real_tasks_from_container(active_tasks_container) + get_real_tasks_from_container(finished_tasks_container)
	
	for task in all_real_tasks:
		if task.has_method("get_task_data"):
			var task_data = task.get_task_data()
			task_data["task_moved"] = task.get_parent() == finished_tasks_container
			save_data["tasks"].append(task_data)
	
	# Save everything to the JSON file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	print("Tasks and title saved!")
	
func load_tasks():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved tasks found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	
	var save_data = json.get_data()
	
	# Load the agenda title if it exists in the saved data
	if save_data.has("agenda_title"):
		agenda_title.text = save_data["agenda_title"]
	
	# Clear existing tasks (but keep spacers)
	for child in get_real_tasks_from_container(active_tasks_container) + get_real_tasks_from_container(finished_tasks_container):
		child.queue_free()
	
	await get_tree().process_frame  # Wait for tasks to be freed
	
	# Load tasks if they exist
	if save_data.has("tasks"):
		for task_data in save_data["tasks"]:
			var new_task = task_scene.instantiate()
			var container = finished_tasks_container if task_data.get("task_moved", false) else active_tasks_container
			var spacer = finished_spacer if container == finished_tasks_container else active_spacer
			
			# Insert before the spacer
			var insert_position = container.get_child_count() - 1
			container.add_child(new_task)
			container.move_child(new_task, insert_position)
			
			new_task.task_completed.connect(move_task_to_finished)
			new_task.task_edited.connect(save_tasks)
			new_task.task_deleted.connect(delete_task)
			new_task.set_task_data(task_data)
	
	# Ensure spacers are at the end
	ensure_spacer_at_end(active_tasks_container, active_spacer)
	ensure_spacer_at_end(finished_tasks_container, finished_spacer)
	
	print("Tasks and title loaded!")
	
func on_save_button_pressed():
	save_tasks()

func _on_add_task_pressed() -> void:
	add_task()
	save_tasks()

func _on_back_pressed() -> void:
	Global.next_scene_path = "res://scenes/main.tscn"
	get_tree().change_scene_to_file("res://scenes/transition.tscn")
