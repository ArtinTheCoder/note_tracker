extends Control

var task_scene = preload("res://scenes/task.tscn")
@onready var active_tasks_container = $ScrollContainer/VBoxContainer/Tasks/VBoxContainer
@onready var finished_tasks_container = $ScrollContainer/VBoxContainer/FinishedTasks/VBoxContainer

# Path to save the tasks data
const SAVE_PATH = "user://tasks.json"

# Timer for auto-save
var save_timer: Timer

func _ready():
	# Setup auto-save timer
	save_timer = Timer.new()
	save_timer.wait_time = 20.0
	save_timer.autostart = true
	save_timer.one_shot = false
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)
	
	# Load tasks on startup - with a brief delay to ensure the scene is fully ready
	await get_tree().create_timer(0.1).timeout
	load_tasks()
	
	# Set up any existing tasks that weren't cleared (though load_tasks should have cleared them)
	for task in active_tasks_container.get_children():
		task.task_completed.connect(move_task_to_finished)
		task.task_edited.connect(_on_task_edited)
		
	for task in finished_tasks_container.get_children():
		task.task_completed.connect(move_task_to_finished)
		task.task_edited.connect(_on_task_edited)

func add_task():
	var task_instance = task_scene.instantiate()
	active_tasks_container.add_child(task_instance)
	# Connect signals after the task is added to the scene tree
	task_instance.task_completed.connect(move_task_to_finished)
	task_instance.task_edited.connect(_on_task_edited)
	
func _on_add_task_pressed() -> void:
	add_task()
	save_tasks()

func move_task_to_finished(task):
	# Store reference to parent containers
	var tasks_container = active_tasks_container
	var finished_tasks_container = self.finished_tasks_container
	
	if task.get_parent() == tasks_container:
		tasks_container.remove_child(task)
		finished_tasks_container.add_child(task)
	else:
		finished_tasks_container.remove_child(task)
		tasks_container.add_child(task)
	
	# Set owner to ensure proper serialization
	task.set_owner(get_tree().current_scene)
	
	# Save after moving a task
	save_tasks()

# Save all tasks to a JSON file
func save_tasks():
	var tasks_data = []
	
	# Loop through all active tasks
	for task in active_tasks_container.get_children():
		if not task.has_method("get_task_data"):
			continue
		var task_data = task.get_task_data()
		task_data["finished"] = false  # Mark as active task
		tasks_data.append(task_data)
	
	# Loop through all finished tasks
	for task in finished_tasks_container.get_children():
		if not task.has_method("get_task_data"):
			continue
		var task_data = task.get_task_data()
		task_data["finished"] = true  # Mark as finished task
		tasks_data.append(task_data)
	
	# Create a JSON string from the tasks data
	var json_string = JSON.stringify(tasks_data)
	
	# Save to file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_string)
	file = null
	
	print("Tasks saved successfully!")

# Load tasks from JSON file
func load_tasks():
	# Check if save file exists
	if not FileAccess.file_exists(SAVE_PATH):
		print("No saved tasks found.")
		return
	
	# Open the file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file = null
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	
	# Check for errors
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
		
	var tasks_data = json.get_data()
	
	# Clear existing tasks
	for child in active_tasks_container.get_children():
		child.queue_free()
	for child in finished_tasks_container.get_children():
		child.queue_free()
	
	# Create new tasks based on saved data
	for task_data in tasks_data:
		var new_task = task_scene.instantiate()
		
		# Determine which container to use
		if task_data.get("finished", false):
			finished_tasks_container.add_child(new_task)
		else:
			active_tasks_container.add_child(new_task)
		
		# Now that the task is in the scene tree, connect signals
		new_task.task_completed.connect(move_task_to_finished)
		new_task.task_edited.connect(_on_task_edited)
		
		# Set data after adding to scene tree and connecting signals
		new_task.set_task_data(task_data)
	
	print("Tasks loaded successfully!")

# Auto-save function
func _on_save_timer_timeout():
	save_tasks()

# Called when a task is edited (and editing has stopped)
func _on_task_edited():
	save_tasks()

# Manual save method - connect this to your save button (if you have one)
func _on_save_button_pressed():
	save_tasks()
