[Japanese/日本語](README.ja.md)

# Godot Tween Shortcut

https://github.com/user-attachments/assets/147f1904-99fb-49b5-a17c-6e14e44f2bbe

## Setup

1. Please create a new script and paste the following code into it.

```gdscript
extends Node

func _ready() -> void:
	var tween : Tween
	tween ##Hover here line
```

2. Hover your mouse over “tween” on line 5.
3. Please remember the title of the tooltip.
   - In English, the tooltip title should read: `Local Variable tween: Tween`

4. Open “res://addons/tween_shortcut/scene/worker.gd”.
5. Please configure the following variables to match your language.

- LOCAL_VARIABLE_TITLE_TEXT
  - Please set the text displayed in blue in the tooltip title. (Use `"Local Variable"` for English.)
- TITLE_SLICE_CHAR
  - Please set the character used to separate class names from other elements. (Use `":"` for English.)
- TWEEN_CLASS_CHAR
  - Please specify the character used to determine whether a class name is “Tween”. (Use `" Tween"` for English.)
  - “It's `" Tween"`, not `"Tween"`. You need a space.” There's a space after the `":"`

6. You can safely delete the script you created in Step 1.



## Size settings
1. Open "res://addons/tween_shortcut/scene/graph_panel.gd".
- PIXEL_SIZE
  - Graph detail level.
  - Since changing this setting doesn't seem to make much of a difference, you might want to lower it.
  - You don't need to match it to GRAPH_SIZE.
- GRAPH_SIZE
  - This is the displayed size. Generally, this is the setting you should adjust.

## 
This was created using Godot 4.6.2.

Since it relies on undocumented internal nodes, it may stop working after an update.
