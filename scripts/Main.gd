extends Node2D

func _ready():
	# 允许在暂停时处理输入
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	# 防止暂停时的输入传递到游戏中
	if get_tree().paused:
		if event is InputEvent:
			get_viewport().set_input_as_handled()
