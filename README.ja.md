# Godot Tween Shortcut

https://github.com/user-attachments/assets/0d3d7167-8f7f-4e1f-81d5-5f261299ddb0

## セットアップ

1. 新しくスクリプトを作成し、以下のコードを貼り付けてください。
```gdscript
extends Node

func _ready() -> void:
	var tween : Tween
	tween ##この行をホバー
```
2. 5行目の “tween” にマウスをホバーさせてください。
3. ツールチップのタイトルを覚えてください。
   - 日本語だとツールチップはこのように見えるはずです: `ローカル変数 tween: Tween`

4. このスクリプトを開いてください: “res://addons/tween_shortcut/scene/worker.gd”
5. あなたの言語に合わせて以下の変数を設定してください。.

- LOCAL_VARIABLE_TITLE_TEXT
  - ツールチップのタイトルの青い部分の文字を設定してください. (日本語の場合:`"ローカル変数"`)
- TITLE_SLICE_CHAR
  - ツールチップのタイトルでクラス名とその他を分ける文字を設定してください. (日本語の場合:`":"`)
- TWEEN_CLASS_CHAR
  - “Tween”クラスだと判別するための文字を設定してください. (日本語の場合:`" Tween"`)
  - “注意！ `" Tween"`です！ `"Tween"`ではありません！スペースが必要です。　`":"`の後ろにスペースがありますので

6. ステップ1で作成したスクリプトは削除しても大丈夫です.



## サイズ設定
1. このスクリプトを開いてください: "res://addons/tween_shortcut/scene/graph_panel.gd"
- PIXEL_SIZE
  - グラフの詳細度
  - 変更してもあまり変わらないので、下げとくのがいいかも。
  - GRAPH_SIZEと合わせる必要はありません。
- GRAPH_SIZE
  - 表示されるサイズです。通常、ここを変更するのがよいでしょう

## 
Godot 4.6.2で作成されました。

公開されていない内部ノードを多数使用しているため、アップデートで動作しなくなる可能性があります。
