extends Node2D

@export var damage: float = 10.0
@export var attack_speed: float = 2.0  # 每秒攻击次数
@export var attack_range: float = 500.0  # 增加射程

# 新增属性的默认值
var default_shot_count: int = 1
var default_shot_spread: float = 0
var default_damage: float = 20.0
var default_attack_speed: float = 2.0
var default_attack_range: float = 500.0

# 新增属性
var shot_count: int = default_shot_count
var shot_spread: float = default_shot_spread
var piercing: bool = false
var bounce_count: int = 0
var homing: bool = false
var homing_strength: float = 5.0  # 新增：追踪强度
var explosive: bool = false
var explosion_radius: float = 0
var split_shot: bool = false
var is_laser: bool = false
var laser_width: float = 2.0

var target: Node2D = null
var can_attack: bool = true

@onready var bullet_scene = preload("res://scenes/Bullet.tscn")

func _enter_tree():
	print("Weapon entering tree")

func _ready():
	print("Weapon node initialized")
	
	# 检查必要的节点
	var timer = $AttackTimer
	if timer:
		print("All weapon components found")
	else:
		print("Timer missing!")
	
	reset_weapon()

func reset_weapon():
	# 重置所有属性到默认值
	shot_count = default_shot_count
	shot_spread = default_shot_spread
	damage = default_damage
	attack_speed = default_attack_speed
	attack_range = default_attack_range
	
	# 重置特殊效果
	piercing = false
	bounce_count = 0
	homing = false
	homing_strength = 5.0
	explosive = false
	explosion_radius = 0
	split_shot = false
	is_laser = false
	laser_width = 2.0
	
	# 重置计时器
	$AttackTimer.wait_time = 1.0 / attack_speed
	can_attack = true

func _physics_process(_delta):
	if !can_attack:
		print("Cannot attack yet")  # 新增
		return
		
	# 获取最近的敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Found enemies: ", enemies.size(), ", can_attack: ", can_attack)  # 修改
	if enemies.size() > 0:
		target = find_nearest_enemy(enemies)
		if target != null:
			print("Found target at distance: ", global_position.distance_to(target.global_position))
			attack()
		else:
			print("No target in range")  # 新增

func find_nearest_enemy(enemies: Array) -> Node2D:
	var nearest = null
	var min_distance = attack_range
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		print("Enemy distance: ", distance)  # 新增
		if distance < min_distance:
			min_distance = distance
			nearest = enemy
			
	return nearest

func attack():
	if target == null:
		return
		
	print("Attacking target!")
	can_attack = false
	$AttackTimer.start()
	
	for i in range(shot_count):
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		# 计算子弹角度
		var base_angle = global_position.direction_to(target.global_position).angle()
		var spread = 0.0
		if shot_count > 1:
			spread = shot_spread * (float(i) / (shot_count - 1) - 0.5)
		var direction = Vector2.RIGHT.rotated(base_angle + deg_to_rad(spread))
		
		# 计算子弹生成位置：从角色边缘发射
		var spawn_offset = direction * 32  # 32是角色半径
		bullet.global_position = global_position + spawn_offset
		
		# 设置子弹属性
		bullet.direction = direction
		bullet.damage = damage
		bullet.piercing = piercing
		bullet.bounce_count = bounce_count
		bullet.homing = homing
		bullet.homing_strength = homing_strength
		bullet.target = target if homing else null
		bullet.split_shot = split_shot
		bullet.is_laser = is_laser
		bullet.laser_width = laser_width
		
		if explosive:
			bullet.connect("tree_exiting", _on_bullet_explode.bind(bullet))

func _on_bullet_explode(bullet):
	if !explosive:
		return
		
	var explosion_targets = get_tree().get_nodes_in_group("enemy")
	for enemy in explosion_targets:
		var distance = enemy.global_position.distance_to(bullet.global_position)
		if distance <= explosion_radius:
			enemy.take_damage(damage * 0.5)  # 爆炸伤害为50%

func _on_attack_timer_timeout():
	can_attack = true
	print("Can attack again!")  # 调试输出5 

func _apply_multi_shot(weapon):
	weapon.shot_count += 1  # 每次叠加增加1发子弹
	weapon.shot_spread = 360.0 / weapon.shot_count  # 更新子弹散布

func apply_damage_boost(amount: float):
	damage += amount  # 增加伤害
	print("New damage: ", damage)

func _apply_attack_speed_boost(weapon):
	weapon.attack_speed *= 1.1  # 每次叠加增加10%攻击速度 
