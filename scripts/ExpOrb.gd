extends Area2D

var value: float = 10.0
var move_speed: float = 200.0
var attraction_range: float = 100.0
var attraction_speed: float = 400.0

var target_player: Node2D = null

func _ready():
	add_to_group("exp_orb")
	
	# 设置碰撞
	collision_layer = 4  # 经验豆层
	collision_mask = 1   # 只与玩家层碰撞
	
	# 创建视觉效果
	var sprite = $Sprite2D
	if sprite:
		# 创建一个小的白色圆形纹理
		var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)  # 减小纹理大小
		image.fill(Color.WHITE)
		var texture = ImageTexture.create_from_image(image)
		sprite.texture = texture
		sprite.modulate = Color(0, 1, 0.5, 0.8)  # 半透明的绿色
	
	# 连接信号
	body_entered.connect(_on_body_entered)
	
	# 获取玩家引用
	target_player = get_tree().get_first_node_in_group("player")
	
	print("ExpOrb created at: ", global_position)  # 调试输出

func _physics_process(delta):
	if target_player:
		var distance = global_position.distance_to(target_player.global_position)
		if distance <= attraction_range:
			# 在吸引范围内时移向玩家
			var direction = global_position.direction_to(target_player.global_position)
			var speed = lerp(move_speed, attraction_speed, 1.0 - (distance / attraction_range))
			global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("gain_exp"):
		print("Player collected ExpOrb worth: ", value)  # 调试输出
		body.gain_exp(value)
		queue_free() 
