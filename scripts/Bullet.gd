extends Area2D

var speed: float = 500.0
var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var piercing: bool = false
var bounce_count: int = 0
var homing: bool = false
var homing_strength: float = 5.0
var target: Node2D = null
var split_shot: bool = false
var split_count: int = 2
var has_split: bool = false
var is_laser: bool = false
var laser_width: float = 2.0
var explosive: bool = true
var explosion_radius: float = 100.0
var chain_length: int = 3  # 闪电链跳跃次数
var chain_range: float = 100.0  # 闪电链跳跃范围

# 新增属性
var max_bounces: int = 3  # 最大弹射次数
var current_bounces: int = 0  # 当前弹射次数

# Line2D 节点
var lightning_line: Line2D

func _ready():
	$Sprite2D.queue_redraw()
	if is_laser:
		$Sprite2D.scale = Vector2(2.0, laser_width * 0.25)
		$Sprite2D.modulate = Color(0.5, 1, 1, 1)

	# 创建并添加 Line2D 节点
	lightning_line = Line2D.new()
	lightning_line.default_color = Color(1, 1, 0)  # 设置颜色为黄色
	lightning_line.width = 2  # 设置线宽
	add_child(lightning_line)  # 将 Line2D 添加为子节点

func _process(delta):
	if homing and target and is_instance_valid(target):
		var target_dir = global_position.direction_to(target.global_position)
		direction = direction.lerp(target_dir, homing_strength * delta)
	
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			_chain_lightning(body, chain_length)  # 调用闪电链逻辑
			queue_free()  # 销毁子弹
	elif current_bounces > 0:
		current_bounces -= 1
		direction = direction.bounce(body.get_collision_normal())
	else:
		queue_free()

func _on_life_timer_timeout():
	queue_free()

func _draw():
	if is_laser:
		draw_line(Vector2.ZERO, Vector2.RIGHT * 16, Color(0.5, 1, 1, 1), laser_width)
	else:
		draw_circle(Vector2.ZERO, 4, Color(1, 0.8, 0.2))

func _chain_lightning(hit_target, remaining_jumps):
	if remaining_jumps <= 0:
		return  # 如果没有剩余跳跃次数，停止递归

	var enemies = get_tree().get_nodes_in_group("enemy")
	var next_target = null
	var closest_distance = chain_range

	# 寻找下一个目标
	for enemy in enemies:
		if enemy != hit_target and is_instance_valid(enemy):
			var distance = hit_target.global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				next_target = enemy

	# 如果找到下一个目标，造成伤害
	if next_target:
		next_target.take_damage(damage * 0.5)  # 闪电链造成50%伤害
		_draw_lightning(hit_target.global_position, next_target.global_position)  # 绘制闪电效果
		_chain_lightning(next_target, remaining_jumps - 1)  # 递归调用以继续链跳，减少跳跃次数

func _draw_lightning(start_pos, end_pos):
	lightning_line.clear_points()  # 清除之前的点
	lightning_line.add_point(start_pos)  # 添加起始点
	lightning_line.add_point(end_pos)  # 添加结束点
