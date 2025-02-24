extends CharacterBody2D

@export var move_speed: float = 300.0
@export var max_health: float = 100.0

var current_health: float
var current_exp: float = 0
var level: int = 1
var exp_to_next_level: float = 100  # 升级所需经验

@onready var level_up_ui = preload("res://scenes/LevelUpUI.tscn")
var ui_instance = null

func _ready():
	current_health = max_health
	
	# 设置碰撞层
	collision_layer = 1  # player层
	collision_mask = 2   # 只与enemy层碰撞
	
	# 延迟创建UI实例
	call_deferred("_setup_ui")
	
	# 检查武器节点
	var weapon = %Weapon
	if weapon:
		print("Weapon node found")
		print("Weapon path: ", weapon.get_path())
	else:
		print("Weapon node missing!")
		print("Available children: ", get_children())

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
	# TODO: 实现游戏结束逻辑
	queue_free()

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
		ui_instance.show_upgrades()
	else:
		print("Error: UI instance is null!")

func _on_upgrade_selected(upgrade: String, upgrade_name: String, description: String):
	print("Selected upgrade: ", upgrade_name, " (", description, ")")
	current_health = max_health  # 升级后恢复生命值
