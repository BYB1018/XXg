extends CanvasLayer

signal upgrade_selected(upgrade: String, upgrade_name: String, description: String)

# 记录已获得的升级
var obtained_upgrades = []

# 预定义所有效果函数
func _apply_nuclear_shot(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.explosive = true
		weapon.explosion_radius *= 2  # 增大爆炸范围
		weapon.damage *= 2           # 增加伤害
		weapon.attack_speed *= 0.7   # 略微降低攻击速度作为平衡
	else:
		print("Error: Weapon not found!")

func _apply_star_shot(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.shot_count += 2       # 增加2发子弹，而不是设为固定值
		weapon.shot_spread = 360.0 / weapon.shot_count  # 均匀分布
		weapon.homing = true
		weapon.homing_strength = 8.0
		weapon.split_shot = true     # 添加分裂效果
	else:
		print("Error: Weapon not found!")

func _apply_laser_grid(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.piercing = true
		weapon.bounce_count += 3
		weapon.is_laser = true
		weapon.laser_width = 4.0
		if weapon.shot_count > 1:
			weapon.laser_width *= 1.5
	else:
		print("Error: Weapon not found!")

func _apply_multi_shot(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.shot_count += 1  # 每次叠加增加1发子弹
		weapon.shot_spread = 360.0 / weapon.shot_count  # 更新子弹散布
	else:
		print("Error: Weapon not found!")

func _apply_piercing(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.piercing = true
	else:
		print("Error: Weapon not found!")

func _apply_bounce(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.bounce_count = 2
	else:
		print("Error: Weapon not found!")

func _apply_homing(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.homing = true
	else:
		print("Error: Weapon not found!")

func _apply_explosive(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.explosive = true
		weapon.explosion_radius = 100
	else:
		print("Error: Weapon not found!")

func _apply_rapid_fire(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.attack_speed *= 1.5
		weapon.get_node("AttackTimer").wait_time = 1.0 / weapon.attack_speed
	else:
		print("Error: Weapon not found!")

func _apply_damage_boost(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.damage += 5
	else:
		print("Error: Weapon not found!")

func _apply_attack_speed_boost(player):
	var weapon = player.get_node("WeaponHolder/Weapon")
	if weapon:
		weapon.attack_speed *= 1.1  # 每次叠加增加10%攻击速度
		weapon.get_node("AttackTimer").wait_time = 1.0 / weapon.attack_speed
	else:
		print("Error: Weapon not found!")

# 组合升级规则
var combo_upgrades = {
	"nuclear_shot": {
		"name": "核爆强化",
		"description": "增强爆炸范围和伤害",
		"requires": ["explosive", "piercing"],
		"effect": "_apply_nuclear_shot"
	},
	"star_shot": {
		"name": "星辰强化",
		"description": "增加子弹数量并添加分裂效果",
		"requires": ["multi_shot", "homing"],
		"effect": "_apply_star_shot"
	},
	"laser_grid": {
		"name": "光网强化",
		"description": "增加弹射次数，子弹变为激光",
		"requires": ["piercing", "bounce"],
		"effect": "_apply_laser_grid"
	}
}

# 基础升级
var base_upgrades = {
	"multi_shot": {
		"name": "三重射击",
		"description": "同时发射多发子弹，效果叠加",
		"effect": "_apply_multi_shot"
	},
	"piercing": {
		"name": "穿透射击",
		"description": "子弹可以穿透敌人",
		"effect": "_apply_piercing"
	},
	"homing": {
		"name": "追踪射击",
		"description": "子弹会自动追踪敌人",
		"effect": "_apply_homing"
	},
	"explosive": {
		"name": "爆炸射击",
		"description": "子弹击中敌人时产生爆炸",
		"effect": "_apply_explosive"
	},
	"rapid_fire": {
		"name": "急速射击",
		"description": "大幅提升攻击速度",
		"effect": "_apply_rapid_fire"
	},
	"damage_boost": {
		"name": "伤害提升",
		"description": "每次升级增加子弹伤害，效果叠加",
		"effect": "_apply_damage_boost"
	},
	"attack_speed_boost": {
		"name": "攻击速度提升",
		"description": "每次升级提高攻击速度，效果叠加",
		"effect": "_apply_attack_speed_boost"
	}
}

var panel: Panel
var options_container: VBoxContainer

func _ready():
	print("LevelUpUI _ready called")
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 300)
	panel.position = Vector2(-200, -150)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Level Up!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)
	
	options_container = VBoxContainer.new()
	options_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	options_container.add_theme_constant_override("separation", 10)
	vbox.add_child(options_container)
	
	print("LevelUpUI setup complete")
	hide()

func show_upgrades(player):
	print("Showing upgrades")
	get_tree().paused = true
	
	var available_upgrades = []
	
	# 检查是否有可用的组合升级
	for combo_id in combo_upgrades.keys():
		var requirements = combo_upgrades[combo_id]["requires"]
		var can_combo = true
		for req in requirements:
			if req not in player.obtained_upgrades:
				can_combo = false
				break
		if can_combo and combo_id not in player.obtained_upgrades:
			available_upgrades.append(combo_id)
	
	# 添加基础升级
	for upgrade_id in base_upgrades.keys():
		if upgrade_id not in player.obtained_upgrades:
			available_upgrades.append(upgrade_id)
	
	# 如果没有可用的升级，隐藏 UI
	if available_upgrades.size() == 0:
		print("No available upgrades.")
		hide()
		get_tree().paused = false  # 解除暂停
		return
	
	available_upgrades.shuffle()
	var selected_upgrades = available_upgrades.slice(0, 3)
	
	for child in options_container.get_children():
		child.queue_free()
	
	for upgrade in selected_upgrades:
		var button = Button.new()
		var vbox = VBoxContainer.new()
		
		var title = Label.new()
		var description = Label.new()
		
		if upgrade in combo_upgrades:
			title.text = "【组合】" + combo_upgrades[upgrade]["name"]
			description.text = combo_upgrades[upgrade]["description"]
		else:
			title.text = base_upgrades[upgrade]["name"]
			description.text = base_upgrades[upgrade]["description"]
		
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(title)
		
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(description)
		
		button.custom_minimum_size.y = 80
		button.add_child(vbox)
		button.pressed.connect(_on_upgrade_selected.bind(upgrade))
		options_container.add_child(button)
	
	show()

func _on_upgrade_selected(upgrade: String):
	print("Upgrade selected: ", upgrade)
	hide()
	get_tree().paused = false  # 解除暂停
	
	# 获取升级信息
	var upgrade_info = combo_upgrades[upgrade] if upgrade in combo_upgrades else base_upgrades[upgrade]
	
	# 获取当前玩家对象
	var player = get_tree().get_first_node_in_group("player")  # 获取玩家对象
	
	# 检查是否已经获得该升级
	if upgrade in player.obtained_upgrades:
		print("Upgrade already obtained: ", upgrade)
		return  # 如果已经获得该升级，则不再处理
	
	player.obtained_upgrades.append(upgrade)  # 记录已获得的升级
	
	# 应用升级效果到武器
	var effect_name = upgrade_info["effect"]
	call(effect_name, player)  # 将 player 作为参数传递
	
	# 发送更详细的升级信息
	upgrade_selected.emit(upgrade, upgrade_info["name"], upgrade_info["description"])

func reset_upgrades():
	obtained_upgrades.clear()
	print("Upgrades reset")
