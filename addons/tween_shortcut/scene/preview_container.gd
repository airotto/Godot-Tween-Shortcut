@tool
extends PanelContainer

@onready var type_select_container: VBoxContainer = $VBoxContainer/TypeSelectContainer
@onready var type_control_container: PanelContainer = %TypeControlContainer
@onready var preview: ColorRect = %Preview

var button_group := ButtonGroup.new()


func _ready() -> void:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(1, 1, 1, 0.1)
	stylebox.set_corner_radius_all(5)
	type_control_container.add_theme_stylebox_override(&"panel", stylebox)
	
	type_control_container.custom_minimum_size = Vector2.ONE * 200
	
	preview.material = ShaderMaterial.new()
	create_type(get_theme_icon(&"ToolMove", &"EditorIcons"), "Move", preload("uid://4ue0l4kul2fu"), true)
	create_type(get_theme_icon(&"ToolRotate", &"EditorIcons"), "Position", preload("uid://b4ix0rv64onu6"))
	create_type(get_theme_icon(&"ToolScale", &"EditorIcons"), "Scale", preload("uid://cyee3qbm4fxju"))
	

func type_next() -> void:
	var button_count:int = type_select_container.get_child_count()
	for i in button_count:
		var button:Button = type_select_container.get_child(i)
		if button.button_pressed:
			var next_button:Button
			if i == button_count - 1:
				next_button = type_select_container.get_child(0)
			else:
				next_button = type_select_container.get_child(i + 1)
			next_button.button_pressed = true
			next_button.pressed.emit()
			return

func type_previous() -> void:
	var button_count:int = type_select_container.get_child_count()
	for i in button_count:
		var button:Button = type_select_container.get_child(i)
		if button.button_pressed:
			var previous_button:Button
			if i == 0:
				previous_button = type_select_container.get_child(button_count - 1)
			else:
				previous_button = type_select_container.get_child(i - 1)
			previous_button.button_pressed = true
			previous_button.pressed.emit()
			return



func create_type(icon:Texture2D, mode_name:String, shader:Shader, press:bool = false) -> void:
	var button := Button.new()
	button.toggle_mode = true
	button.button_group = button_group
	button.icon = icon
	button.tooltip_text = "Preview mode : "
	button.tooltip_text += mode_name
	button.tooltip_text += "\nCan be switched using the wheel"
	
	button.pressed.connect(_on_type_button_pressed.bind(shader))
	
	type_select_container.add_child(button)
	
	if press:
		button.button_pressed = true
		button.pressed.emit()


func _on_type_button_pressed(shader:Shader) -> void:
	if preview_tween:
		preview_tween.kill()
	
	var mat:ShaderMaterial = preview.material
	mat.shader = shader
	mat.set_shader_parameter(&"progress", 0.0)
	preview.material = mat


var preview_tween:Tween
func play(_transition_type:Tween.TransitionType, ease_type:Tween.EaseType) -> void:
	var mat:ShaderMaterial = preview.material
	if mat.shader == null:return
	
	if preview_tween:
		preview_tween.kill()
	
	preview_tween = create_tween()
	preview_tween.set_trans(_transition_type)
	preview_tween.set_ease(ease_type)
	
	mat.set_shader_parameter(&"progress", 0.0)
	preview_tween.tween_method(set_preview_progress, 0.0, 1.0, 1)
	

func set_preview_progress(progress:float) -> void:
	var mat:ShaderMaterial = preview.material
	if mat.shader == null:return
	
	mat.set_shader_parameter(&"progress", progress)
