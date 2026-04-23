@tool
extends PanelContainer





##シーン編集時にreadyを動かしたくないので
var instanced:bool = false

##キャッシュ
var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]

@onready var grid_container: GridContainer = %GridContainer
@onready var ease_select_container: HBoxContainer = %EaseSelectContainer

@onready var button_ease_in: Button = %ButtonEaseIn
@onready var button_ease_out: Button = %ButtonEaseOut
@onready var button_ease_in_out: Button = %ButtonEaseInOut
@onready var button_ease_out_in: Button = %ButtonEaseOutIn


var selecting_tt:Tween.TransitionType

var hovering_graph_panel:GraphPanel

signal shortcut(transition_name:String, ease_name:String)

const TRANSITION_TYPE_LIST:Array[Tween.TransitionType] = [
	Tween.TransitionType.TRANS_BACK,
	Tween.TransitionType.TRANS_BOUNCE,
	Tween.TransitionType.TRANS_CIRC,
	Tween.TransitionType.TRANS_CUBIC,
	Tween.TransitionType.TRANS_ELASTIC,
	Tween.TransitionType.TRANS_EXPO,
	Tween.TransitionType.TRANS_LINEAR,
	Tween.TransitionType.TRANS_QUAD,
	Tween.TransitionType.TRANS_QUART,
	Tween.TransitionType.TRANS_QUINT,
	Tween.TransitionType.TRANS_SINE,
	Tween.TransitionType.TRANS_SPRING,
]



const TRANSITION_TYPE_NAME_MAP:Dictionary[Tween.TransitionType, String] = {
	Tween.TransitionType.TRANS_BACK : "Tween.TransitionType.TRANS_BACK",
	Tween.TransitionType.TRANS_BOUNCE : "Tween.TransitionType.TRANS_BOUNCE",
	Tween.TransitionType.TRANS_CIRC : "Tween.TransitionType.TRANS_CIRC",
	Tween.TransitionType.TRANS_CUBIC : "Tween.TransitionType.TRANS_CUBIC",
	Tween.TransitionType.TRANS_ELASTIC : "Tween.TransitionType.TRANS_ELASTIC",
	Tween.TransitionType.TRANS_EXPO : "Tween.TransitionType.TRANS_EXPO",
	Tween.TransitionType.TRANS_LINEAR : "Tween.TransitionType.TRANS_LINEAR",
	Tween.TransitionType.TRANS_QUAD : "Tween.TransitionType.TRANS_QUAD",
	Tween.TransitionType.TRANS_QUART : "Tween.TransitionType.TRANS_QUART",
	Tween.TransitionType.TRANS_QUINT : "Tween.TransitionType.TRANS_QUINT",
	Tween.TransitionType.TRANS_SINE : "Tween.TransitionType.TRANS_SINE",
	Tween.TransitionType.TRANS_SPRING : "Tween.TransitionType.TRANS_SPRING",
}


const EASE_TYPE_NAME_MAP:Dictionary[Tween.EaseType, String] = {
	Tween.EaseType.EASE_IN : "Tween.EaseType.EASE_IN",
	Tween.EaseType.EASE_OUT : "Tween.EaseType.EASE_OUT",
	Tween.EaseType.EASE_IN_OUT : "Tween.EaseType.EASE_IN_OUT",
	Tween.EaseType.EASE_OUT_IN : "Tween.EaseType.EASE_OUT_IN",
}



var ease_button_list:Array[Button]

func _ready() -> void:
	if not instanced:return
	
	ease_select_container.hide()
	
	for t:Node in grid_container.get_children():
		t.queue_free()
	
	
	for tt:Tween.TransitionType in TRANSITION_TYPE_LIST:
		create_graph_panel(tt)
	
	
	button_ease_in.set_meta(&"ease_type", Tween.EaseType.EASE_IN)
	button_ease_out.set_meta(&"ease_type", Tween.EaseType.EASE_OUT)
	button_ease_in_out.set_meta(&"ease_type", Tween.EaseType.EASE_IN_OUT)
	button_ease_out_in.set_meta(&"ease_type", Tween.EaseType.EASE_OUT_IN)
	
	ease_button_list = [button_ease_in, button_ease_out, button_ease_in_out, button_ease_out_in]
	for ease_button:Button in ease_button_list:
		set_ease_button_color(ease_button)
		ease_button.pressed.connect(_on_ease_button_pressed.bind(ease_button))
	




func _on_ease_button_pressed(button:Button) -> void:
	if not button.has_meta(&"ease_type"):return
	
	var te:Tween.EaseType = button.get_meta(&"ease_type")
	
	shortcut.emit(TRANSITION_TYPE_NAME_MAP[selecting_tt], EASE_TYPE_NAME_MAP[te])
	
	hide()
	##待たないとアーティファクトが見える シェーダーのバグ？
	##無くても動作するが、見た目がきもすぎる
	await get_tree().process_frame
	await get_tree().process_frame
	queue_free()



func set_ease_button_color(button:Button) -> void:
	if not button.has_meta(&"ease_type"):return
	
	var te:Tween.EaseType = button.get_meta(&"ease_type")
	
	var color:Color = GraphPanel.EASE_COLOR_MAP[te]
	
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = color
	button.add_theme_stylebox_override(&"normal", stylebox)
	
	var hover_stylebox:StyleBoxFlat = stylebox.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	hover_stylebox.bg_color = hover_stylebox.bg_color.lightened(0.3)
	button.add_theme_stylebox_override(&"hover", hover_stylebox)
	
	var pressed_stylebox:StyleBoxFlat = stylebox.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	pressed_stylebox.bg_color = pressed_stylebox.bg_color.lightened(0.5)
	button.add_theme_stylebox_override(&"pressed", pressed_stylebox)



const GraphPanel = preload("uid://bpiu3qcp52hx7")

func create_graph_panel(tt:Tween.TransitionType) -> void:
	var graph_panel:GraphPanel = GraphPanel.new()
	graph_panel.tt = tt
	graph_panel.curve_texture_cache = curve_texture_cache
	grid_container.add_child(graph_panel)
	
	graph_panel.button.mouse_entered.connect(_on_graph_panel_button_mouse_entered.bind(graph_panel, tt))


func _on_graph_panel_button_mouse_entered(graph_panel:GraphPanel, tt:Tween.TransitionType) -> void:
	if hovering_graph_panel:##全てのグラフ選択を解除
		_on_ease_button_mouse_entered(button_ease_in, true)
	
	
	ease_select_container.reparent(graph_panel, false)
	ease_select_container.show()
	selecting_tt = tt
	
	hovering_graph_panel = graph_panel
	
	
	for ease_button:Button in ease_button_list:
		if not ease_button.mouse_entered.is_connected(_on_ease_button_mouse_entered):
			ease_button.mouse_entered.connect(_on_ease_button_mouse_entered.bind(ease_button))


##選択したグラフを光らせたりする
func _on_ease_button_mouse_entered(button:Button, all_unselect:bool = false) -> void:
	if not button.has_meta(&"ease_type"):return
	
	var te:Tween.EaseType = button.get_meta(&"ease_type")
	
	var graph_panel:GraphPanel = hovering_graph_panel
	
	for i:ColorRect in graph_panel.color_rect_list:
		if not i.has_meta(&"ease_type"):continue
		var selecting:bool = i.get_meta(&"ease_type") == te and not all_unselect
		(i.material as ShaderMaterial).set_shader_parameter(&"selecting", selecting)
		if selecting:
			i.z_index = 1
		else:
			i.z_index = 0
		
		
