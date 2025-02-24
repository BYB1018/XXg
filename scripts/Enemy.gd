extends CharacterBody2D

@export var move_speed: float = 112.5
@export var max_health: float = 30.0
@export var attack_damage: float = 15.0
@export var attack_cooldown: float = 1.0
@export var experience_value: float = 15.0

var current_health: float
var target_player: Node2D  # 改名避免shadowing
var last_attack_time: float = 0.0

signal enemy_killed

func _ready():
	add_to_group("enemy")
	print("Enemy added to group")
	current_health = max_health
	target_player = get_tree().get_first_node_in_group("player")
	
	# 设置碰撞层
	collision_layer = 2  # enemy层
	collision_mask = 1   # 只与player层碰撞

func _physics_process(_delta):
	if target_player == null:
		return
	
	# 移动向玩家
	var direction = global_position.direction_to(target_player.global_position)
	velocity = direction * move_speed
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time >= last_attack_time + attack_cooldown:
			last_attack_time = current_time
			body.take_damage(attack_damage)

func take_damage(amount: float):
	current_health -= amount
	if current_health <= 0:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player._on_enemy_killed()
		die()

func die():
	print("Enemy died at position: ", global_position)
	
	# 生成经验豆
	var exp_orb = preload("res://scenes/ExpOrb.tscn").instantiate()
	exp_orb.value = experience_value
	exp_orb.global_position = global_position
	
	# 使用call_deferred来延迟添加经验豆和删除敌人
	get_tree().root.call_deferred("add_child", exp_orb)
	call_deferred("queue_free")
	
	print("ExpOrb spawned with value: ", experience_value)
