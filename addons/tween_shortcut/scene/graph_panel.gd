extends PanelContainer


@export var PIXEL_SIZE:int = 64
@export var GRAPH_SIZE := Vector2(90, 100)


const EaseButton = preload("uid://dps8vg50yh6xw")

var color_rect_list:Array[ColorRect]

var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]

var _transition_type:Tween.TransitionType : get = get_transition_type
func get_transition_type() -> Tween.TransitionType:
	return _transition_type




func _init(transition_type:Tween.TransitionType, _curve_texture_cache:Dictionary) -> void:
	_transition_type = transition_type
	curve_texture_cache = _curve_texture_cache
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(1, 1, 1, 0.1)
	stylebox.set_corner_radius_all(5)
	add_theme_stylebox_override(&"panel", stylebox)


func _ready() -> void:
	
	for _ease_type in EaseButton.EASE_COLOR_MAP.keys():
		create_graph(self, get_transition_type(), _ease_type)


##選択したグラフを光らせたりする
func select_graph(_ease_type:Tween.EaseType) -> void:
	for i:ColorRect in color_rect_list:
		if not i.has_meta(&"ease_type"):continue
		
		var selecting:bool = i.get_meta(&"ease_type") == _ease_type
		
		
		(i.material as ShaderMaterial).set_shader_parameter(&"selecting", selecting)
		if selecting:
			i.z_index = 1
		else:
			i.z_index = 0
		
		

func unselect_graph() -> void:
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	select_graph(-1)





func create_graph(parent:Control, __transition_type:Tween.TransitionType, _ease_type:Tween.EaseType) -> void:
	var curve_texture: CurveTexture
	
	if curve_texture_cache.has(__transition_type):
		if curve_texture_cache[__transition_type].has(_ease_type):
			curve_texture = curve_texture_cache[__transition_type][_ease_type]
	
	#curve_texture = null
	
	if curve_texture == null:
		curve_texture = create_curve_texture(__transition_type, _ease_type)
		
		if not curve_texture_cache.has(__transition_type):
			curve_texture_cache[__transition_type] = {}
		curve_texture_cache[__transition_type][_ease_type] = curve_texture
	
	
	var color_rect := ColorRect.new()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.custom_minimum_size = GRAPH_SIZE
	
	color_rect.set_meta(&"ease_type", _ease_type)
	
	const CURVE_GRAPH = preload("uid://cplgcjpyqxdgi")
	var mat:ShaderMaterial = CURVE_GRAPH.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	mat.set_shader_parameter("curve_texture", curve_texture)
	mat.set_shader_parameter("line_color", EaseButton.EASE_COLOR_MAP[_ease_type])
	
	color_rect.material = mat
	
	color_rect_list.append(color_rect)
	
	
	
	parent.add_child(color_rect)



func create_curve_texture(__transition_type:Tween.TransitionType, _ease_type:Tween.EaseType) -> CurveTexture:
	
	
	var points:Array[float]
	var tween := create_tween()
	
	tween.set_trans(__transition_type)
	tween.set_ease(_ease_type)
	
	tween.pause()
	tween.tween_method(points.append, 0.0, PIXEL_SIZE as float, PIXEL_SIZE as float)
	
	for i in PIXEL_SIZE:
		tween.custom_step(1)
	
	
	##ELASTICとかは1を超えてから戻る軌道なので表示範囲を調整できるように
	const OVER := Vector2(0.0, 0.7)
	
	var curve := Curve.new()
	curve.max_value = 1 + (OVER.y * 0.5)
	curve.min_value = 0 - (OVER.y * 0.5)
	
	
	
	var curve_texture := CurveTexture.new()
	curve_texture.width = PIXEL_SIZE
	curve_texture.curve = curve
	
	
	
	for i:int in points.size():
		
		var pos := Vector2(i as float, points[i])
		pos /= (PIXEL_SIZE as float)##0~1にする
		
		
		
		pos.x += OVER.x * 0.5
		pos.x /= 1 + OVER.x
		
		pos.y += OVER.y * 0.5
		pos.y /= 1 + OVER.y
		
		
		curve.add_point(pos)
	
	
	
	return curve_texture
