@tool
extends PanelContainer


##シーン編集時にreadyを動かしたくないので
var instanced:bool = false
##キャッシュ
var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]
var tooltip:PopupPanel

@onready var grid_container: GridContainer = %GridContainer
@onready var ease_select_container: HBoxContainer = %EaseSelectContainer

const PreviewContainer = preload("uid://fqyeyjng43x3")
@onready var preview_container: PreviewContainer = %PreviewContainer

const EaseButton = preload("uid://dps8vg50yh6xw")
var ease_button_list:Array[EaseButton]
const GraphPanel = preload("uid://bpiu3qcp52hx7")
var hovering_graph_panel:GraphPanel

signal shortcut(transition_name:String, ease_name:String)

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
	Tween.EaseType.EASE_OUT : "Tween.EaseType.EASE_OUT",
	Tween.EaseType.EASE_IN_OUT : "Tween.EaseType.EASE_IN_OUT",
	Tween.EaseType.EASE_OUT_IN : "Tween.EaseType.EASE_OUT_IN",
	Tween.EaseType.EASE_IN : "Tween.EaseType.EASE_IN",
}



func _ready() -> void:
	if not instanced:return
	
	ease_select_container.hide()
	
	for _transition_type:Tween.TransitionType in TRANSITION_TYPE_NAME_MAP.keys():
		create_graph_panel(_transition_type)
	
	
	for _ease_type:Tween.EaseType in EASE_TYPE_NAME_MAP.keys():
		var ease_button := EaseButton.new(_ease_type)
		ease_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		
		ease_button.pressed.connect(_on_ease_button_pressed.bind(ease_button.ease_type))
		ease_button.preview_pressed.connect(_on_ease_button_preview_pressed)
		
		ease_select_container.add_child(ease_button)
		ease_button_list.append(ease_button)
	


func _on_ease_button_preview_pressed(ease_type:Tween.EaseType) -> void:
	if hovering_graph_panel == null:return
	preview_container.play(hovering_graph_panel.get_transition_type(), ease_type)

func _on_ease_button_pressed(ease_type:Tween.EaseType) -> void:
	shortcut.emit(TRANSITION_TYPE_NAME_MAP[hovering_graph_panel.get_transition_type()], EASE_TYPE_NAME_MAP[ease_type])
	
	hide()
	##待たないとアーティファクトが見える シェーダーのバグ？
	##無くても動作するが、見た目がきもすぎる
	await get_tree().process_frame
	await get_tree().process_frame
	queue_free()



func _on_graph_panel_mouse_entered(graph_panel:GraphPanel) -> void:
	if hovering_graph_panel:
		##全てのグラフ選択を解除
		hovering_graph_panel.unselect_graph()
		
		for ease_button:EaseButton in ease_button_list:
			if ease_button.mouse_entered.is_connected(hovering_graph_panel.select_graph):
				ease_button.mouse_entered.disconnect(hovering_graph_panel.select_graph)
	
	
	ease_select_container.reparent(graph_panel, false)
	ease_select_container.show()
	
	hovering_graph_panel = graph_panel
	
	
	##ease_button ホバー時にグラフを選択する（光らせたりする）
	for ease_button:EaseButton in ease_button_list:
		if not ease_button.mouse_entered.is_connected(hovering_graph_panel.select_graph):
			ease_button.mouse_entered.connect(hovering_graph_panel.select_graph.bind(ease_button.ease_type))




func create_graph_panel(_transition_type:Tween.TransitionType) -> void:
	var graph_panel:GraphPanel = GraphPanel.new(_transition_type, curve_texture_cache)
	grid_container.add_child(graph_panel)
	
	graph_panel.mouse_entered.connect(_on_graph_panel_mouse_entered.bind(graph_panel))



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				preview_container.type_next()
			if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
				preview_container.type_previous()
