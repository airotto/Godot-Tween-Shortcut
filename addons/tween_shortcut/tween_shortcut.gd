@tool
extends EditorPlugin

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass
	initialized()



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


#####################################
#####################################

func initialized() -> void:
	var script_editor:ScriptEditor = EditorInterface.get_script_editor()
	if not script_editor.is_node_ready():
		await script_editor.ready
	
	script_editor.editor_script_changed.connect(update_code_edits.bind(script_editor).unbind(1))
	update_code_edits(script_editor)



var curve_texture_cache:Dictionary[Tween.TransitionType, Dictionary]



##ツールチップに　tween　の奴を追加するのがこの関数です
func _on_symbol_hovered(symbol: String, line: int, _column: int, code_edit:CodeEdit) -> void:
	if code_edit == null:return
	
	##表示時のみノードが生成されるのでホバーごとにトリガー
	##ツールチップを取得
	## 未公開のクラス EditorHelpBitTooltip
	var tooltip:PopupPanel = code_edit.find_child("*EditorHelpBitTooltip*", false, false)
	#code_edit.print_tree_pretty()
	if tooltip == null:return
	if tooltip.has_meta(&"_triggered"):return
	tooltip.set_meta(&"_triggered", true)
	
	
	##背景としてのみの役割
	var _panel:Panel = tooltip.find_child("*Panel*", false, false)
	
	## 未公開のクラス EditorHelpBit
	##これが内容
	## 子ノードに RichTextLabelが0個以上
	var editor_help_bit:Control = tooltip.find_child("*EditorHelpBit*", false, false)
	
	var title_label:RichTextLabel = editor_help_bit.get_child(0)
	var _text_label:RichTextLabel = editor_help_bit.get_child(1)
	
	
	##SymbolType symbol_name: Type = variant
	var title_text:String = title_label.get_parsed_text()
	
	if "(" in title_text:## function
		return
	elif ":" in title_text:## property
		pass
	else: ## class
		return
	
	var type_name:String = title_text.get_slice(":", 1).get_slice(" ", 1)
	#print(type_name)
	if not type_name == "Tween":return
	
	#######################
	#######################
	#######################
	
	const TweenShortcutContainer = preload("uid://2b882ev7milk")
	const TWEEN_SHORTCUT_CONTAINER = preload("uid://x6aiyg6l6t6n")
	var tween_shortcut_container:TweenShortcutContainer = TWEEN_SHORTCUT_CONTAINER.instantiate()
	tween_shortcut_container.curve_texture_cache = curve_texture_cache
	tween_shortcut_container.instanced = true
	tween_shortcut_container.tooltip = tooltip
	
	editor_help_bit.add_child(tween_shortcut_container, true)
	
	tween_shortcut_container.shortcut.connect(insert_shortcut.bind(symbol, line, code_edit))
	
	tween_shortcut_container.tree_exited.connect(tooltip.reset_size)


##グラフを選択した後にコードに挿入するやつ
func insert_shortcut(transition_name:String, ease_name:String, symbol: String, line:int, code_edit:CodeEdit) -> void:
	code_edit.begin_complex_operation()
	
	code_edit.set_caret_line(line)
	@warning_ignore("integer_division")
	var indent_level:int = code_edit.get_indent_level(line) / code_edit.get_tab_size()
	var indent:String = "	".repeat(indent_level)
	
	var insert_line:int
	
	##シンボルのみならそれを消して新しく作成
	if code_edit.get_line(line) == indent + symbol:
		insert_line = line
		code_edit.remove_line_at(insert_line, true)
		code_edit.insert_line_at(insert_line, indent)
	else:
		
		## 既存のtransとeaseの両方が並んだシンボルの場合置き換える
		var override:bool = false
		for i in 2:
			insert_line = line - i
			if (code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_trans(" )\
			and code_edit.get_line(insert_line + 1).begins_with(indent + symbol + ".set_ease(" ) )\
			
			or (code_edit.get_line(insert_line + 1).begins_with(indent + symbol + ".set_trans(" )\
			and code_edit.get_line(insert_line + 0).begins_with(indent + symbol + ".set_ease(" ) ):
			
				
				code_edit.remove_line_at(insert_line, false)
				code_edit.remove_line_at(insert_line, false)
				
				code_edit.insert_line_at(insert_line, indent)
				
				override = true
				break
		
		
		##transとease片方だけでも探し、あったらそれを置き換える
		if not override:
			insert_line = line
			if code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_trans(" ):
				code_edit.remove_line_at(insert_line, true)
			elif code_edit.get_line(insert_line).begins_with(indent + symbol + ".set_ease(" ):
				code_edit.remove_line_at(insert_line, true)
			else:##なかったら　次の行に作成
				insert_line = line + 1
			
			
			
			
			code_edit.insert_line_at(insert_line, indent)
			
	
	
	
	##############
	##あとはコードをその位置に挿入するだけ
	###########
	
	var transition_code:String = symbol + ".set_trans(" + transition_name + ")"
	code_edit.insert_text(transition_code, insert_line, indent_level)
	
	insert_line += 1
	
	code_edit.insert_line_at(insert_line, indent)
	
	var ease_code:String = symbol + ".set_ease(" + ease_name +")"
	code_edit.insert_text(ease_code, insert_line, indent_level)
	
	code_edit.set_caret_line(insert_line)
	code_edit.set_caret_column(code_edit.get_line(insert_line).length())
	
	
	code_edit.end_complex_operation()


func update_code_edits(script_editor:ScriptEditor) -> void:
	
	##開いたコードごとに独立したノードです
	## 未公開のクラス ScriptTextEditor
	for script_text_editor:Node in script_editor.find_children("*ScriptTextEditor*", "", true, false):
		#script_text_editor.print_tree_pretty()
		var code_edit:CodeEdit = script_text_editor.find_child("*CodeEdit*",true,false)
		
		if code_edit == null:continue
		
		if not code_edit.symbol_hovered.is_connected(_on_symbol_hovered):
			code_edit.symbol_hovered.connect(_on_symbol_hovered.bind(code_edit))
