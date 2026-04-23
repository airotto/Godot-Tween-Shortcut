extends PanelContainer


@export var PIXEL_SIZE:int = 64
@export var GRAPH_SIZE := Vector2(90, 100)

var color_rect_list:Array[ColorRect]

var tt:Tween.TransitionType

var button:Button

var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]



const EASE_COLOR_MAP:Dictionary[Tween.EaseType, Color] = {
	Tween.EaseType.EASE_IN : Color.LAWN_GREEN,
	Tween.EaseType.EASE_OUT : Color.ORANGE_RED,
	Tween.EaseType.EASE_IN_OUT : Color.DARK_VIOLET,
	Tween.EaseType.EASE_OUT_IN : Color.DEEP_PINK,
}



func _ready() -> void:
	
	button = Button.new()
	
	add_child(button)
	
	
	
	create_graph(self, tt, Tween.EaseType.EASE_IN)
	
	if tt != Tween.TransitionType.TRANS_LINEAR:
		create_graph(self, tt, Tween.EaseType.EASE_OUT)
		create_graph(self, tt, Tween.EaseType.EASE_IN_OUT)
		create_graph(self, tt, Tween.EaseType.EASE_OUT_IN)
	
	
	


func create_graph(parent:Control, _tt:Tween.TransitionType, te:Tween.EaseType) -> void:
	var curve_texture: CurveTexture
	
	if curve_texture_cache.has(_tt):
		if curve_texture_cache[_tt].has(te):
			curve_texture = curve_texture_cache[_tt][te]
	
	#curve_texture = null
	
	if curve_texture == null:
		curve_texture = create_curve_texture(_tt, te)
		
		if not curve_texture_cache.has(_tt):
			curve_texture_cache[_tt] = {}
		curve_texture_cache[_tt][te] = curve_texture
	
	
	var color_rect := ColorRect.new()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.custom_minimum_size = GRAPH_SIZE
	
	color_rect.set_meta(&"ease_type", te)
	
	const CURVE_GRAPH = preload("uid://cplgcjpyqxdgi")
	var mat:ShaderMaterial = CURVE_GRAPH.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	mat.set_shader_parameter("curve_texture", curve_texture)
	mat.set_shader_parameter("line_color", EASE_COLOR_MAP[te])
	
	color_rect.material = mat
	
	color_rect_list.append(color_rect)
	
	
	
	parent.add_child(color_rect)



func create_curve_texture(_tt:Tween.TransitionType, te:Tween.EaseType) -> CurveTexture:
	
	
	var points:Array[float]
	var tween := create_tween()
	
	tween.set_trans(_tt)
	tween.set_ease(te)
	
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
