extends CharacterBody2D

@export var move_speed: float = 300.0
@export var max_health: float = 100.0

var current_health: float
var current_exp: float = 0
var level: int = 1
var exp_to_next_level: float = 100  # 升级所需经验
var game_start_time: float
var enemies_killed: int = 0

var obtained_upgrades = []  # 确保在 Player 中定义已获得的升级

@onready var level_up_ui = preload("res://scenes/LevelUpUI.tscn")
@onready var game_over_ui = preload("res://scenes/GameOverUI.tscn")  # 预加载GameOverUI场景
var ui_instance = null

func _ready():
	current_health = max_health
	
	# 设置碰撞层
	collision_layer = 1  # player层
	collision_mask = 6   # 与enemy层(2)和exp_orb层(4)碰撞
	
	# 延迟创建UI实例
	call_deferred("_setup_ui")
	
	# 检查武器节点
	var weapon = $WeaponHolder/Weapon  # 确保路径正确
	if weapon:
		print("Weapon node found")
		print("Weapon path: ", weapon.get_path())
	else:
		print("Weapon node missing!")
		print("Available children: ", get_children())
	
	game_start_time = Time.get_unix_time_from_system()
	
	# 创建GameOverUI
	var game_over_instance = game_over_ui.instantiate()
	add_child(game_over_instance)
	game_over_instance.restart_game.connect(_on_restart_game)
	game_over_instance.quit_game.connect(_on_quit_game)

	# 创建飞船形状
	var spaceship = Polygon2D.new()
	spaceship.polygon = [
		Vector2(0, -20),  # 顶部
		Vector2(-10, 10),  # 左下
		Vector2(10, 10),  # 右下
	]
	spaceship.color = Color(0.2, 0.5, 1)  # 设置颜色
	add_child(spaceship)  # 将飞船添加到场景中

func _setup_ui():
	print("Setting up UI manually...")
	
	# 创建一个新的CanvasLayer
	ui_instance = CanvasLayer.new()
	ui_instance.layer = 100
	ui_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 加载并附加脚本
	var script = load("res://scripts/LevelUpUI.gd")
	if script:
		ui_instance.set_script(script)
		print("Script attached successfully")
	else:
		print("Failed to load UI script")
		return
	
	get_tree().root.add_child(ui_instance)
	
	# 等待UI准备好
	await get_tree().create_timer(0.1).timeout
	
	# 连接信号
	if ui_instance and ui_instance.has_signal("upgrade_selected"):
		ui_instance.upgrade_selected.connect(_on_upgrade_selected)
		ui_instance.hide()
		print("UI setup complete")
	else:
		print("Failed to setup UI")

func _physics_process(_delta):
	# 获取输入
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("ui_left", "ui_right")
	input_direction.y = Input.get_axis("ui_up", "ui_down")
	input_direction = input_direction.normalized()
	
	# 设置速度和移动
	velocity = input_direction * move_speed
	move_and_slide()

func take_damage(damage: float):
	current_health -= damage
	if current_health <= 0:
		die()

func die():
	var survival_time = Time.get_unix_time_from_system() - game_start_time
	var score = level * 1000 + enemies_killed * 100
	
	# 显示结算界面
	var game_over_instance = $GameOverUI
	if game_over_instance:
		game_over_instance.show_game_over(score, survival_time, enemies_killed)
	else:
		print("Error: GameOverUI not found!")

func gain_exp(amount: float):
	current_exp += amount
	print("Gained exp: ", amount, ", Total: ", current_exp)
	
	while current_exp >= exp_to_next_level:
		level_up()

func level_up():
	level += 1
	current_exp -= exp_to_next_level
	exp_to_next_level *= 1.2
	
	print("Level up! Now level ", level)
	
	# 显示升级UI
	if ui_instance:
		ui_instance.show_upgrades(self)
	else:
		print("Error: UI instance is null!")

func _on_upgrade_selected(_upgrade: String, upgrade_name: String, description: String):
	print("Selected upgrade: ", upgrade_name, " (", description, ")")
	# 移除回血效果，升级时不再恢复生命值

func _on_restart_game():
	# 重置玩家属性
	current_health = max_health
	current_exp = 0
	level = 1
	exp_to_next_level = 100
	enemies_killed = 0
	
	# 清空已获得的升级
	obtained_upgrades.clear()  # 清空升级效果
	
	# 清除所有敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
		
	# 清除所有经验球
	var exp_orbs = get_tree().get_nodes_in_group("exp_orb")
	for orb in exp_orbs:
		orb.queue_free()
	
	# 重置武器
	var weapon_holder = $WeaponHolder
	var weapon = weapon_holder.get_node("Weapon")
	if weapon:
		weapon.queue_free()  # 确保旧武器被移除
	
	weapon = load("res://scenes/Weapon.tscn").instantiate()
	weapon_holder.add_child(weapon)
	weapon.name = "Weapon"
	weapon.reset_weapon()  # 确保武器属性被重置
	
	# 重置位置
	position = Vector2(576, 324)  # 屏幕中心
	
	# 隐藏游戏结束UI
	var game_over_instance = $GameOverUI
	if game_over_instance:
		game_over_instance.hide()

func _on_quit_game():
	get_tree().quit()

func _on_enemy_killed():
	enemies_killed += 1
