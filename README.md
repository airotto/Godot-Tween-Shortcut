[Japanese/日本語](README.ja.md)

# Godot Tween Shortcut

## Features of this plugin:
- You can select a graph from the visual interface and insert `set_ease()` or `set_trans()` into your code.
- You can preview the tween.

https://github.com/user-attachments/assets/5f6b8d64-48d1-424b-b79a-c273585d60b2

## Size settings
1. Open "res://addons/tween_shortcut/scene/graph_panel.gd".
- PIXEL_SIZE
  - Graph detail level.
  - Since changing this setting doesn't seem to make much of a difference, you might want to lower it.
  - You don't need to match it to GRAPH_SIZE.
- GRAPH_SIZE
  - This is the displayed size. Generally, this is the setting you should adjust.

2. Open "res://addons/tween_shortcut/scene/preview_container.gd".
- PREVIEW_SIZE
  - Preview size.

## 
Supported Versions (Previous versions are available on the branch):
- 4.7
- 4.6.3
- 4.6.2

Since it relies on undocumented internal nodes, it may stop working after an update.
