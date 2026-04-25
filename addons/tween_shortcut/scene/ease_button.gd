extends Button


var ease_type:Tween.EaseType:
	set(new):
		ease_type = new
		_update_ease_button_color()

const EASE_COLOR_MAP:Dictionary[Tween.EaseType, Color] = {
	Tween.EaseType.EASE_OUT : Color.ORANGE_RED,
	Tween.EaseType.EASE_IN_OUT : Color.DARK_VIOLET,
	Tween.EaseType.EASE_OUT_IN : Color.DEEP_PINK,
	Tween.EaseType.EASE_IN : Color.LAWN_GREEN,
}


func _init(_ease_type:Tween.EaseType) -> void:
	ease_type = _ease_type


func _update_ease_button_color() -> void:
	
	var color:Color = EASE_COLOR_MAP[ease_type]
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = color
	add_theme_stylebox_override(&"normal", stylebox)
	
	var hover_stylebox:StyleBoxFlat = stylebox.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	hover_stylebox.bg_color = hover_stylebox.bg_color.lightened(0.3)
	add_theme_stylebox_override(&"hover", hover_stylebox)
	
	var pressed_stylebox:StyleBoxFlat = stylebox.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	pressed_stylebox.bg_color = pressed_stylebox.bg_color.lightened(0.5)
	add_theme_stylebox_override(&"pressed", pressed_stylebox)


signal preview_pressed(ease_type:Tween.EaseType)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == MOUSE_BUTTON_RIGHT:
			preview_pressed.emit(ease_type)
