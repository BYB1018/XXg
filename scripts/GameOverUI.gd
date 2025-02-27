extends CanvasLayer

signal restart_game
signal quit_game

var final_score: int = 0
var survival_time: float = 0
var enemies_killed: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 500)
	panel.position = Vector2(-200, -250)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# 标题
	var title = Label.new()
	title.text = "游戏结束"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)
	
	# 统计信息
	var stats = VBoxContainer.new()
	stats.add_theme_constant_override("separation", 10)
	
	var time_label = Label.new()
	time_label.text = "生存时间: %.1f 秒" % survival_time
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_child(time_label)
	
	var score_label = Label.new()
	score_label.text = "最终得分: %d" % final_score
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_child(score_label)
	
	var kills_label = Label.new()
	kills_label.text = "消灭敌人: %d" % enemies_killed
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_child(kills_label)
	
	vbox.add_child(stats)
	
	# 按钮容器
	var button_container = VBoxContainer.new()
	button_container.add_theme_constant_override("separation", 10)
	
	var restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.custom_minimum_size.y = 50
	restart_button.pressed.connect(_on_restart_pressed)
	button_container.add_child(restart_button)
	
	var quit_button = Button.new()
	quit_button.text = "退出游戏"
	quit_button.custom_minimum_size.y = 50
	quit_button.pressed.connect(_on_quit_pressed)
	button_container.add_child(quit_button)
	
	vbox.add_child(button_container)
	
	hide()

func show_game_over(score: int, time: float, kills: int):
	final_score = score
	survival_time = time
	enemies_killed = kills
	get_tree().paused = true
	show()

func _on_restart_pressed():
	hide()  # 先隐藏UI
	get_tree().paused = false
	restart_game.emit()

func _on_quit_pressed():
	quit_game.emit() 