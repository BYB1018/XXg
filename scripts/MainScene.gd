extends Node2D

# 创建新的 Viewport
onready var mirror_viewport = $SubViewport  # 获取 SubViewport 节点
onready var mirror_texture = ImageTexture.new()  # 创建新的纹理
onready var mirror_material = ShaderMaterial.new()  # 创建新的材质

func _ready():
	print("MainScene is ready")
	print("Mirror Viewport: ", mirror_viewport)
	print("Mirror Material: ", mirror_material)

	# 设置 SubViewport 的 Render Target Update Mode
	mirror_viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS  # 始终更新

	# 创建并设置 Shader
	mirror_material.shader = preload("res://shaders/mirror_shader.gdshader")  # 加载自定义着色器
	mirror_material.set_shader_param("mirror_texture", mirror_texture)  # 设置纹理参数

	# 创建一个 Sprite 用于显示镜面效果
	var mirror_sprite = Sprite.new()
	mirror_sprite.texture = mirror_viewport.get_texture()  # 设置纹理为 SubViewport 的纹理
	mirror_sprite.scale = Vector2(1, 1)  # 设置缩放
	mirror_sprite.material = mirror_material  # 应用材质
	add_child(mirror_sprite)  # 将 Sprite 添加到场景中

	# 在场景中添加其他元素，例如星空背景
	_create_stars()

	# 创建主角
	var player = preload("res://scripts/Player.gd").new()
	add_child(player)

	# 创建敌人
	var enemy = preload("res://scripts/Enemy.gd").new()
	enemy.position = Vector2(400, 300)  # 设置敌人位置
	add_child(enemy)

func _create_stars():
	# 创建星空背景
	var star_background = ColorRect.new()
	star_background.color = Color(0, 0, 0)  # 设置背景为黑色
	star_background.rect_size = Vector2(800, 600)  # 设置大小
	add_child(star_background)  # 将背景添加到场景中

	# 添加星星
	for i in range(100):  # 添加100颗星星
		var star = CircleShape2D.new()
		star.radius = 2  # 星星半径
		var star_instance = CollisionShape2D.new()
		star_instance.shape = star
		star_instance.position = Vector2(randf() * 800, randf() * 600)  # 随机位置
		star_instance.set_deferred("disabled", false)  # 确保星星可见
		add_child(star_instance)  # 将星星添加到场景中 
