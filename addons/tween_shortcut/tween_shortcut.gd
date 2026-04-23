@tool
extends EditorPlugin

const Worker = preload("uid://birxtrlkcvvcc")
var worker:Worker

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
	
	
	if worker:
		worker.queue_free()
	
	worker = Worker.new()
	EditorInterface.get_base_control().add_child(worker)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
	
	if worker:
		worker.queue_free()
