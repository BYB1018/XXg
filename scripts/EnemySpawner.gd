extends Node2D

@export var enemy_scene: PackedScene
@export var base_spawn_interval: float = 0.8   # 初始0.8秒生成一次
@export var min_spawn_interval: float = 0.1    # 最快0.1秒生成一次
@export var spawn_decrease_rate: float = 0.4   # 保持0.4的递减速度
@export var min_spawn_distance: float = 300.0
@export var max_spawn_distance: float = 400.0
@export var base_spawn_count: int = 2         # 初始每次生成2个
@export var max_spawn_count: int = 6          # 最多同时生成6个

var current_spawn_interval: float
var next_spawn_time: float = 0.0
var game_time: float = 0.0  # 游戏运行时间
var player: Node2D

func _ready():
	print("EnemySpawner ready")
	call_deferred("_init_spawner")

func _init_spawner():
	# 等待一帧确保player已经准备好
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("Player found: ", player != null)
	if player:
		current_spawn_interval = base_spawn_interval
		spawn_enemy()  # 立即生成第一波敌人
	else:
		print("Failed to find player!")

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			print("Still no player found!")
			return
		
	if get_tree().paused:
		return
		
	# 更新游戏时间和生成间隔
	game_time += delta
	var minutes = game_time / 60.0
	current_spawn_interval = max(
		min_spawn_interval,
		base_spawn_interval - (minutes * spawn_decrease_rate)
	)
	
	# 计算当前应该生成的敌人数量
	var spawn_count = min(
		max_spawn_count,
		base_spawn_count + floor(minutes)  # 每分钟增加1个
	)
	
	# 生成敌人
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time >= next_spawn_time:
		for i in range(spawn_count):
			spawn_enemy()
		next_spawn_time = current_time + current_spawn_interval
		print("Spawning enemies: ", spawn_count)

func spawn_enemy():
	if player == null:
		print("Cannot spawn enemy: no player!")
		return
		
	# 在玩家周围随机位置生成敌人
	var angle = randf() * 2 * PI
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	var spawn_position = player.global_position + Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_position
	print("Enemy spawned at: ", spawn_position)  # 添加调试输出
