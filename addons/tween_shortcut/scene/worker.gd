@tool
extends Node


@export var LOCAL_VARIABLE_TITLE_TEXT:String = "ローカル変数"
@export var TITLE_SLICE_CHAR:String = ":"
@export var TWEEN_CLASS_CHAR:String = " Tween"


var script_editor:ScriptEditor
var current_code_edit:CodeEdit


var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]




func _on_symbol_hovered(symbol: String, line: int, _column: int) -> void:
	##ツールチップに　tween　の奴を追加するのがこの関数です
	
	
	if current_code_edit == null:return
	#print(symbol)
	
	##表示時のみノードが生成されるのでホバーごとにトリガー
	##ツールチップを取得
	## 未公開のクラス EditorHelpBitTooltip
	var tooltip:PopupPanel = current_code_edit.find_child("*EditorHelpBitTooltip*", false, false)
	#current_code_edit.print_tree_pretty()
	if tooltip == null:return
	
	
	
	##背景としてのみの役割
	var _panel:Panel = tooltip.find_child("*Panel*", false, false)
	
	## 未公開のクラス EditorHelpBit
	##これが内容
	## 子ノードに RichTextLabelが0個以上
	var editor_help_bit:Control = tooltip.find_child("*EditorHelpBit*", false, false)
	
	var title:RichTextLabel = editor_help_bit.get_child(0)
	var _text:RichTextLabel = editor_help_bit.get_child(1)
	
	var title_text:String = title.get_parsed_text()
	
	#print(title_text.get_slice(":", 1))
	if not title_text.get_slice(TITLE_SLICE_CHAR, 1).begins_with(TWEEN_CLASS_CHAR) or not title_text.begins_with(LOCAL_VARIABLE_TITLE_TEXT):return
	
	if editor_help_bit.find_child("TweenShortcutContainer", true, false):return
	
	const TweenShortcutContainer = preload("uid://2b882ev7milk")
	const TWEEN_SHORTCUT_CONTAINER = preload("uid://x6aiyg6l6t6n")
	var tween_shortcut_container:TweenShortcutContainer = TWEEN_SHORTCUT_CONTAINER.instantiate()
	tween_shortcut_container.curve_texture_cache = curve_texture_cache
	tween_shortcut_container.instanced = true
	
	editor_help_bit.add_child(tween_shortcut_container, true)
	
	tween_shortcut_container.shortcut.connect(insert_shortcut.bind(symbol, line))
	
	tween_shortcut_container.tree_exited.connect(tooltip.reset_size)
	
	return
	



##グラフを選択した後にコードに挿入するやつ
func insert_shortcut(transition_name:String, ease_name:String, symbol: String, line:int) -> void:
	current_code_edit.begin_complex_operation()
	
	current_code_edit.set_caret_line(line)
	@warning_ignore("integer_division")
	var indent_level:int = current_code_edit.get_indent_level(line) / current_code_edit.get_tab_size()
	var indent:String = "	".repeat(indent_level)
	
	var insert_line:int
	
	##シンボルのみならそれを消して新しく作成
	if current_code_edit.get_line(line) == indent + symbol:
		insert_line = line
		current_code_edit.remove_line_at(insert_line, true)
		current_code_edit.insert_line_at(insert_line, indent)
	else:
		
		## 既存のtransとeaseの両方が並んだシンボルの場合置き換える
		var override:bool = false
		for i in 2:
			insert_line = line - i
			if (current_code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_trans(" )\
			and current_code_edit.get_line(insert_line + 1).begins_with(indent + symbol + ".set_ease(" ) )\
			
			or (current_code_edit.get_line(insert_line + 1).begins_with(indent + symbol + ".set_trans(" )\
			and current_code_edit.get_line(insert_line + 0).begins_with(indent + symbol + ".set_ease(" ) ):
			
				
				current_code_edit.remove_line_at(insert_line, false)
				current_code_edit.remove_line_at(insert_line, false)
				
				current_code_edit.insert_line_at(insert_line, indent)
				
				override = true
				break
		
		
		##transとease片方だけでも探し、あったらそれを置き換える
		if not override:
			insert_line = line
			if current_code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_trans(" ):
				current_code_edit.remove_line_at(insert_line, true)
			elif current_code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_ease(" ):
				current_code_edit.remove_line_at(insert_line, true)
			else:##なかったら　次の行に作成
				insert_line = line + 1
			
			
			
			
			current_code_edit.insert_line_at(insert_line, indent)
			
	
	
	
	##############
	##あとはコードをその位置に挿入するだけ
	###########
	
	var transition_code:String = symbol + ".set_trans(" + transition_name + ")"
	current_code_edit.insert_text(transition_code, insert_line, indent_level)
	
	insert_line += 1
	
	current_code_edit.insert_line_at(insert_line, indent)
	
	var ease_code:String = symbol + ".set_ease(" + ease_name +")"
	current_code_edit.insert_text(ease_code, insert_line, indent_level)
	
	current_code_edit.set_caret_line(insert_line)
	current_code_edit.set_caret_column(current_code_edit.get_line(insert_line).length())
	
	
	current_code_edit.end_complex_operation()




func _ready() -> void:
	
	##最初のこの関数では　スクリプトエディターのスクリプトエディット(テキストエディット(.txt等用)ではない)を取得する
	
	
	script_editor = EditorInterface.get_script_editor()
	
	if not script_editor.is_node_ready():
		await script_editor.ready
	
	script_editor.editor_script_changed.connect(_on_editor_script_changed)


func _on_editor_script_changed(_script:Script) -> void:
	##visibleが更新されるのを待つ
	await get_tree().process_frame
	await get_tree().process_frame
	print("changed")
	
	##開いたコードごとに独立したノードです
	## 未公開のクラス ScriptTextEditor
	for script_text_editor:Node in script_editor.find_children("*ScriptTextEditor*", "", true, false):
		#script_text_editor.print_tree_pretty()
		var code_edit:CodeEdit = script_text_editor.find_child("*CodeEdit*",true,false)
		
		if code_edit == null:return
		
		if not code_edit.symbol_hovered.is_connected(_on_symbol_hovered):
			code_edit.symbol_hovered.connect(_on_symbol_hovered)
		
		#print(code_edit.is_visible_in_tree())
		##見えてたらそれが今開いてるやつ
		if code_edit.is_visible_in_tree():
			current_code_edit = code_edit
