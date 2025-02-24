extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: float = 20.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var experience_value: float = 10.0

var current_health: float
var target_player: Node2D  # 改名避免shadowing
var last_attack_time: float = 0.0

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

func take_damage(incoming_damage: float):
	current_health -= incoming_damage
	print("Enemy health: ", current_health)
	
	# 添加受击效果
	modulate = Color(1, 0.5, 0.5)  # 变红
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)  # 恢复正常颜色
	
	if current_health <= 0:
		die()

func die():
	# 掉落经验值
	var exp_receiver = get_tree().get_first_node_in_group("player")
	if exp_receiver and exp_receiver.has_method("gain_exp"):
		exp_receiver.gain_exp(experience_value)
	queue_free()
